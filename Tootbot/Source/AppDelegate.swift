//
// Copyright (C) 2017 Alexsander Akers and Tootbot Contributors
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

import ReactiveSwift
import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    let disposable = ScopedDisposable(CompositeDisposable())
    let rootViewController = RootViewController()
    let viewModel = AppDelegateViewModel(dataController: DataController(), networkingController: NetworkingController())

    func handle(url: URL) -> Bool {
        guard let applicationProperties = Bundle.main.applicationProperties,
            url.absoluteString.hasPrefix(applicationProperties.redirectURI),
            let components = URLComponents(url: url, resolvingAgainstBaseURL: true),
            let queryItems = components.queryItems,
            !queryItems.isEmpty,
            let authorizationCode = queryItems.first(where: { $0.name == "code" })?.value,
            let instanceURI = queryItems.first(where: { $0.name == "state" })?.value
        else {
            return false
        }

        viewModel.networkingController.handleLoginCallback(instanceURI: instanceURI, authorizationCode: authorizationCode, redirectURI: applicationProperties.redirectURI)
        return true
    }

    func loadUI() {
        let accounts = viewModel.accounts()
        if let account = accounts.first {
            let tabBarController = UIStoryboard(name: "Main", bundle: nil).instantiateInitialViewController() as! UITabBarController
            for viewController in tabBarController.viewControllers ?? [] {
                guard let navigationController = viewController as? UINavigationController,
                    let rootViewController = navigationController.viewControllers.first
                    else { continue }

                switch rootViewController {
                case is HomeTimelineViewController:
                    let homeTimelineViewController = rootViewController as! HomeTimelineViewController
                    homeTimelineViewController.viewModel = viewModel.homeTimelineViewModel(account: account)
                default:
                    break
                }
            }

            rootViewController.transition(to: tabBarController)
        } else {
            let addAccount = UIStoryboard(name: "AddAccount", bundle: nil).instantiateInitialViewController() as! AddAccountViewController
            addAccount.viewModel = viewModel.addAccountViewModel()
            rootViewController.transition(to: addAccount)
        }
    }

    // MARK: - App Delegate

    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        let window = UIWindow(frame: UIScreen.main.bounds)
        window.rootViewController = rootViewController
        window.makeKeyAndVisible()
        self.window = window

        disposable += viewModel.initializeDataController()
            .startWithCompleted(loadUI)

        if let url = launchOptions?[.url] as? URL {
            return handle(url: url)
        } else {
            return true
        }
    }

    func application(_ app: UIApplication, open url: URL, options: [UIApplicationOpenURLOptionsKey: Any]) -> Bool {
        return handle(url: url)
    }
}
