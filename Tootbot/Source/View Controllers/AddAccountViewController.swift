//
// Copyright (C) 2017 Tootbot Contributors
//
// This program is free software: you can redistribute it and/or modify
// it under the terms of the GNU Affero General Public License as published
// by the Free Software Foundation, either version 3 of the License, or
// (at your option) any later version.
//
// This program is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
// GNU Affero General Public License for more details.
//
// You should have received a copy of the GNU Affero General Public License
// along with this program.  If not, see <http://www.gnu.org/licenses/>.
//

import KeyboardLayoutGuide
import ReactiveCocoa
import ReactiveSwift
import Result
import SafariServices
import UIKit

class AddAccountViewController: UIViewController {
    @IBOutlet var activityIndicatorView: UIActivityIndicatorView!
    @IBOutlet var containerStackView: UIStackView!
    @IBOutlet var instanceTextField: UITextField!
    @IBOutlet var logInButton: UIButton!

    let disposable = ScopedDisposable(CompositeDisposable())
    var loginURLAction: Action<String, URL, AddAccountError>!
    var viewModel: AddAccountViewModel!

    let doneSignal: Signal<DataController, NoError>
    private let doneObserver: Observer<DataController, NoError>

    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        (self.doneSignal, self.doneObserver) = Signal.pipe()
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
    }

    required init?(coder aDecoder: NSCoder) {
        (self.doneSignal, self.doneObserver) = Signal.pipe()
        super.init(coder: aDecoder)
    }

    // MARK: - Actions

    @IBAction func logIn(_ sender: AnyObject?) {
        instanceTextField.resignFirstResponder()

        let instanceURI: String
        if let text = instanceTextField.text?.trimmingCharacters(in: .whitespaces), !text.isEmpty {
            instanceURI = text
        } else {
            instanceURI = "mastodon.social"
        }

        disposable += loginURLAction.apply(instanceURI).start()
        disposable += viewModel.loginResult(on: instanceURI)
            .observe(Observer(value: doneObserver.send(value:), failed: { error in
                print("Login result failed -> \(error)")
                self.dismiss(animated: true)
            }, completed: {
                // Dismiss Safari view controller
                self.dismiss(animated: true)
            }))
    }

    // MARK: - 

    func configureLayout() {
        keyboardLayoutGuide.centerYAnchor.constraint(equalTo: containerStackView.centerYAnchor).isActive = true
    }

    func configureReactivity() {
        // Set up action
        loginURLAction = Action(viewModel.loginURL)

        // Show Safari view controller with login URLs
        disposable += loginURLAction.values.observeValues { loginURL in
            let safariViewController = SFSafariViewController(url: loginURL)
            self.present(safariViewController, animated: true)
        }

        // Toggle activity view animating
        disposable += activityIndicatorView.reactive.isAnimating <~ loginURLAction.isExecuting
        // Toggle button enabled
        disposable += logInButton.reactive.isEnabled <~ loginURLAction.isExecuting.negate()
    }

    // MARK: - View Life Cycle

    override func viewDidLoad() {
        super.viewDidLoad()

        configureLayout()
        configureReactivity()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        instanceTextField.becomeFirstResponder()
        instanceTextField.selectedTextRange = instanceTextField.fullTextRange
    }
}
