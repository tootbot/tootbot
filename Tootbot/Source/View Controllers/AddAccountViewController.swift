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
    var loginAction: Action<String, DataController, AddAccountError>!
    var viewModel: AddAccountViewModel!

    let doneSignal: Signal<DataController, NoError>
    let doneObserver: Observer<DataController, NoError>

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

        disposable += loginAction.apply(instanceURI).start()
    }

    // MARK: - 

    func configureLayout() {
        keyboardLayoutGuide.centerYAnchor.constraint(equalTo: containerStackView.centerYAnchor).isActive = true
    }

    func configureReactivity() {
        // Set up action
        loginAction = Action { [unowned self] instanceURI in
            let replacement = self.viewModel.loginResult(on: instanceURI)
                .on(value: { [unowned self] signal in
                    // Credential verification began
                    self.dismiss(animated: true)
                })
                .flatten(.latest)

            return self.viewModel.loginURL(on: instanceURI)
                .on(value: { [unowned self] loginURL in
                    let safariViewController = SFSafariViewController(url: loginURL)
                    self.present(safariViewController, animated: true)
                })

                // fatalError is NOT called; `filter()` passes through no values
                .filter { _ in false }
                .map { _ in fatalError() }

                .take(untilReplacement: replacement)
        }

        // Pass login results through to `doneSignal`
        loginAction.values.take(first: 1).observe(doneObserver)

        // Toggle activity view animating
        disposable += activityIndicatorView.reactive.isAnimating <~ loginAction.isExecuting
        // Toggle button enabled
        disposable += logInButton.reactive.isEnabled <~ loginAction.isExecuting.negate()
    }

    // MARK: - View Life Cycle

    override func viewDidLoad() {
        super.viewDidLoad()

        configureLayout()
        configureReactivity()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        if !loginAction.isExecuting.value {
            instanceTextField.becomeFirstResponder()
            instanceTextField.selectedTextRange = instanceTextField.fullTextRange
        }
    }
}
