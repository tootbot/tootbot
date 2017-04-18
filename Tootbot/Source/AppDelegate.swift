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

import CoreData
import ReactiveSwift
import Result
import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    let disposable = ScopedDisposable(CompositeDisposable())
    let rootViewController = RootViewController()
    let viewModel = AppDelegateViewModel(networkingController: NetworkingController(keychain: Keychain()))

    // MARK: - App Delegate

    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        let window = UIWindow(frame: UIScreen.main.bounds)
        window.rootViewController = rootViewController
        window.makeKeyAndVisible()
        self.window = window

        disposable += viewModel.loadUI()
            .startWithValues { [unowned self] viewController in
                self.rootViewController.transition(to: viewController)
            }

        if let url = launchOptions?[.url] as? URL {
            return viewModel.handleURL(url)
        } else {
            return true
        }
    }

    func application(_ app: UIApplication, open url: URL, options: [UIApplicationOpenURLOptionsKey: Any]) -> Bool {
        return viewModel.handleURL(url)
    }
}
