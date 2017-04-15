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

import CoreData
import ReactiveSwift
import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    let disposable = ScopedDisposable(CompositeDisposable())
    let rootViewController = RootViewController()
    let viewModel = AppDelegateViewModel(dataController: DataController(), networkingController: NetworkingController())

    private func handle(url: URL) -> Bool {
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
        do {
            if try viewModel.hasAccounts() {
                let tabBarController = UIStoryboard(name: "Main", bundle: nil).instantiateInitialViewController() as! UITabBarController
                rootViewController.transition(to: tabBarController)
            } else {
                let addAccount = UIStoryboard(name: "AddAccount", bundle: nil).instantiateInitialViewController() as! AddAccountViewController
                addAccount.viewModel = viewModel.addAccountViewModel()
                rootViewController.transition(to: addAccount)
            }
        } catch {
            print("viewModel.hasAccounts() -> \(error)")
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

    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }
}
