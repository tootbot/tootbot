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

enum AddAccountError: Error {
    case invalidApplicationProperties
    case applicationRegistrationFailure
    case loginURLGenerationFailure
    case authenticationFailure
    case coreDataFetchError
    case coreDataSaveError
}

class AddAccountViewModel {
    let dataController: DataController
    let networkingController: NetworkingController

    init(dataController: DataController, networkingController: NetworkingController) {
        self.dataController = dataController
        self.networkingController = networkingController
    }

    func loginURL(on instanceURI: String) -> SignalProducer<URL, AddAccountError> {
        guard let properties = Bundle.main.applicationProperties else {
            return SignalProducer(error: .invalidApplicationProperties)
        }

        return networkingController.applicationCredentials(for: properties, on: instanceURI)
            .mapError { _ in .applicationRegistrationFailure }
            .flatMap(.latest) { credentials -> SignalProducer<URL, AddAccountError> in
                if let loginURL = self.networkingController.loginURL(applicationProperties: properties, applicationCredentials: credentials) {
                    return SignalProducer(value: loginURL)
                } else {
                    return SignalProducer(error: .loginURLGenerationFailure)
                }
            }
    }

    func loginResult(on instanceURI: String) -> Signal<JSONEntity.Account, AddAccountError> {
        return networkingController.loginResult(for: instanceURI).mapError { _ in .authenticationFailure }
    }

    func newOrExistingAccount(from jsonAccount: JSONEntity.Account, instanceURI: String) -> SignalProducer<Account, AddAccountError> {
        return SignalProducer { observer, disposable in
            self.dataController.perform { context in
                guard !disposable.isDisposed else { return }

                let fetchRequest: NSFetchRequest<Account> = Account.fetchRequest()
                fetchRequest.fetchLimit = 1
                fetchRequest.predicate = NSPredicate(format: "username == %@ AND instanceURI == %@", jsonAccount.username, instanceURI)
                fetchRequest.returnsObjectsAsFaults = true

                let existingAccounts: [Account]
                do {
                    existingAccounts = try context.fetch(fetchRequest)
                }  catch {
                    observer.send(error: .coreDataFetchError)
                    return
                }

                let account: Account
                if let existingAccount = existingAccounts.first {
                    account = existingAccount
                } else {
                    account = Account(context: context)
                    account.instanceURI = instanceURI
                    account.username = jsonAccount.username

                    do {
                        try context.save()
                    } catch {
                        observer.send(error: AddAccountError.coreDataSaveError)
                    }
                }

                let objectID = account.objectID
                DispatchQueue.main.async {
                    let accountOnMainQueue = self.dataController.viewContext.object(with: objectID) as! Account
                    observer.send(value: accountOnMainQueue)
                    observer.sendCompleted()
                }
            }
        }
    }
}
