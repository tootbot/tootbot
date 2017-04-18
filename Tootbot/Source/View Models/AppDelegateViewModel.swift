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

import Foundation
import ReactiveSwift
import Result
import UIKit

class AppDelegateViewModel {
    enum Error: Swift.Error {
        case dataController(DataController.Error)
    }

    let networkingController: NetworkingController

    init(networkingController: NetworkingController) {
        self.networkingController = networkingController
    }

    func handleURL(_ url: URL) -> Bool {
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

    fileprivate func loggedInUI(homeTimelineViewModel: HomeTimelineViewModel) -> UIViewController {
        let tabBarController = UIStoryboard(name: "Main", bundle: nil).instantiateInitialViewController() as! UITabBarController
        for viewController in tabBarController.viewControllers ?? [] {
            guard let navigationController = viewController as? UINavigationController,
                let rootViewController = navigationController.viewControllers.first
                else { continue }

            switch rootViewController {
            case let homeTimelineViewController as HomeTimelineViewController:
                homeTimelineViewController.viewModel = homeTimelineViewModel
            default:
                break
            }
        }

        return tabBarController
    }

    func loadLoggedInUI(forAccount userAccount: UserAccount) -> SignalProducer<UIViewController, Error> {
        return DataController.load(forAccount: userAccount)
            .mapError(Error.dataController)
            .map(homeTimelineViewModel(dataController:))
            .map(loggedInUI(homeTimelineViewModel:))
    }

    func loadLoggedOutUI() -> SignalProducer<UIViewController, NoError> {
        return SignalProducer { observer, disposable in
            let addAccount = UIStoryboard(name: "AddAccount", bundle: nil).instantiateInitialViewController() as! AddAccountViewController
            addAccount.viewModel = AddAccountViewModel(networkingController: self.networkingController)
            observer.send(value: addAccount)

            disposable += addAccount.doneSignal
                .map(self.homeTimelineViewModel(dataController:))
                .map(self.loggedInUI(homeTimelineViewModel:))
                .observeValues { viewController in
                    observer.send(value: viewController)
                }
        }
    }

    fileprivate func homeTimelineViewModel(dataController: DataController) -> HomeTimelineViewModel {
        let account = try! dataController.account()!
        let timeline = account.timeline(ofType: .home)!
        return HomeTimelineViewModel(timeline: timeline, dataController: dataController, networkingController: self.networkingController)!
    }

    func loadUI() -> SignalProducer<UIViewController, NoError> {
        // TODO: Hack until we have some kind of last used account / multiple user support
        // https://github.com/tootbot/tootbot/issues/28
        //
        // Loads UI for first non-erroring data controller, otherwise the logged out UI
        return SignalProducer(networkingController.allAccounts())
            .map { userAccount in
                self.loadLoggedInUI(forAccount: userAccount)
                    .on(failed: { error in
                        print("Could not load UI for \(userAccount) -> \(error)")
                    })
                    .flatMapError { _ in SignalProducer<UIViewController, NoError>.empty }
            }
            .concat(value: loadLoggedOutUI())
            .flatten(.concat)
            .take(first: 1)
    }
}
