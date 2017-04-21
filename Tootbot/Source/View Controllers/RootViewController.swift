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

import UIKit

class RootViewController: UIViewController {
    var childViewController: UIViewController = UIViewController() {
        willSet {
            childViewController.view.removeFromSuperview()
            childViewController.removeFromParentViewController()
        }
        didSet {
            setNeedsStatusBarAppearanceUpdate()
        }
    }

    // MARK: - Public API

    func transition(to viewController: UIViewController, duration: TimeInterval = 0.3, completion: @escaping (Bool) -> Void = { _ in }) {
        addFullSizeChildViewController(viewController)
        transition(from: childViewController, to: viewController, duration: duration, options: .transitionCrossDissolve, animations: {}, completion: { finished in
            if finished {
                self.childViewController = viewController
            }

            completion(finished)
        })
    }

    // MARK: - Helpers

    private func addFullSizeChildViewController(_ viewController: UIViewController) {
        addChildViewController(viewController)
        view.addSubview(viewController.view)
        viewController.view.autoresizingMask = .flexibleSize
        viewController.view.frame = view.bounds
    }

    // MARK: - View Life Cycle

    override func viewDidLoad() {
        super.viewDidLoad()

        addFullSizeChildViewController(childViewController)
    }

    // MARK: - Status Bar

    override var childViewControllerForStatusBarHidden: UIViewController? {
        return childViewController
    }

    override var childViewControllerForStatusBarStyle: UIViewController? {
        return childViewController
    }
}
