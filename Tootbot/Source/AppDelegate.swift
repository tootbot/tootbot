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
    let networkingController = NetworkingController(keychain: Keychain())
    let rootViewController = RootViewController()

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

        networkingController.handleLoginCallback(instanceURI: instanceURI, authorizationCode: authorizationCode, redirectURI: applicationProperties.redirectURI)
        return true
    }

    func homeTimelineViewModel(dataController: DataController) -> HomeTimelineViewModel {
        let account = try! dataController.account()!
        let timeline = account.timeline(ofType: .home)!
        return HomeTimelineViewModel(timeline: timeline, dataController: dataController, networkingController: self.networkingController)!
    }

    func loadLoggedInStoryboard(homeTimelineViewModel: HomeTimelineViewModel) {
        let tabBarController = UIStoryboard(name: "Main", bundle: nil).instantiateInitialViewController() as! UITabBarController
        for viewController in tabBarController.viewControllers ?? [] {
            guard let navigationController = viewController as? UINavigationController,
                let rootViewController = navigationController.viewControllers.first
                else { continue }

            switch rootViewController {
            case is HomeTimelineViewController:
                let homeTimelineViewController = rootViewController as! HomeTimelineViewController
                homeTimelineViewController.viewModel = homeTimelineViewModel
            default:
                break
            }
        }

        rootViewController.transition(to: tabBarController)
    }

    func loadLoggedInUI(forAccount userAccount: UserAccount) -> SignalProducer<Void, NSError> {
        return DataController.load(forAccount: userAccount)
            .mapError { $0 as NSError }
            .map(homeTimelineViewModel(dataController:))
            .on(value: { viewModel in self.loadLoggedInStoryboard(homeTimelineViewModel: viewModel) })
            .ignoreValues()
    }

    func loadLoggedOutUI() {
        let addAccount = UIStoryboard(name: "AddAccount", bundle: nil).instantiateInitialViewController() as! AddAccountViewController
        addAccount.viewModel = AddAccountViewModel(networkingController: networkingController)

        disposable += addAccount.doneSignal.observeValues { [unowned self] dataController in
            let viewModel = self.homeTimelineViewModel(dataController: dataController)
            self.loadLoggedInStoryboard(homeTimelineViewModel: viewModel)
        }

        rootViewController.transition(to: addAccount)
    }

    // MARK: - App Delegate

    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        let window = UIWindow(frame: UIScreen.main.bounds)
        window.rootViewController = rootViewController
        window.makeKeyAndVisible()
        self.window = window

        // Temporary hack until we have some kind of last used account / multiple user support
        func loadAccount(atIndex index: Int, fromAccounts userAccounts: [UserAccount]) {
            guard index < userAccounts.count else {
                loadLoggedOutUI()
                return
            }

            let userAccount = userAccounts[index]
            loadLoggedInUI(forAccount: userAccount).startWithFailed { error in
                print("Could not load UI for \(userAccount) -> \(error)")
                loadAccount(atIndex: index + 1, fromAccounts: userAccounts)
            }
        }

        loadAccount(atIndex: 0, fromAccounts: networkingController.allAccounts())

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
