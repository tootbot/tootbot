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

enum DataControllerError: Error {
    case loadFailure(Error)
    case saveFailure(Error)
}

class DataController {
    let container: NSPersistentContainer

    fileprivate init(userAccount: UserAccount) {
        let name = String(describing: userAccount)

        let modelURL = Bundle.main.url(forResource: "Tootbot", withExtension: "momd")!
        let model = NSManagedObjectModel(contentsOf: modelURL)!

        self.container = NSPersistentContainer(name: name, managedObjectModel: model)
    }

    static func load(forAccount userAccount: UserAccount) -> SignalProducer<DataController, DataControllerError> {
        return SignalProducer.deferred {
            let dataController = DataController(userAccount: userAccount)
            return dataController.load()
                .observe(on: QueueScheduler.main)
                .map { _ in dataController }
        }
    }

    static func create(forAccount accountModel: API.Account, instanceURI: String) -> SignalProducer<DataController, DataControllerError> {
        return SignalProducer.deferred {
            let userAccount = UserAccount(instanceURI: instanceURI, username: accountModel.username)
            let dataController = DataController(userAccount: userAccount)
            return dataController.load()
                .flatMap(.latest) { _ in dataController.insertAccount(from: accountModel, instanceURI: instanceURI) }
                .observe(on: QueueScheduler.main)
                .map { _ in dataController }
        }
    }

    fileprivate func insertAccount(from accountModel: API.Account, instanceURI: String) -> SignalProducer<Account, DataControllerError> {
        return SignalProducer { observer, disposable in
            self.perform(backgroundTask: { context in
                guard !disposable.isDisposed else { return }

                let account = Account(context: context)
                account.instanceURI = instanceURI
                account.update(with: accountModel)

                let timeline = Timeline(context: context)
                timeline.account = account
                timeline.timelineTypeValue = .home

                do {
                    try context.save()
                } catch {
                    observer.send(error: .saveFailure(error))
                }

                let managedObjectID = account.objectID
                DispatchQueue.main.async {
                    guard !disposable.isDisposed else { return }

                    let viewContext = self.viewContext
                    let account = viewContext.object(with: managedObjectID) as! Account
                    observer.send(value: account)
                    observer.sendCompleted()
                }
            })
        }
    }

    func account() throws -> Account {
        let fetchRequest: NSFetchRequest<Account> = Account.fetchRequest()
        fetchRequest.fetchLimit = 1

        let results = try viewContext.fetch(fetchRequest)
        return results[0]
    }

    fileprivate func load() -> SignalProducer<NSPersistentStoreDescription, DataControllerError> {
        return SignalProducer { observer, disposable in
            self.container.loadPersistentStores { storeDescription, error in
                observer.send(value: storeDescription)

                if let error = error {
                    observer.send(error: .loadFailure(error))
                } else {
                    observer.sendCompleted()
                }
            }
        }
    }

    var viewContext: NSManagedObjectContext {
        return container.viewContext
    }

    func newBackgroundContext() -> NSManagedObjectContext {
        return container.newBackgroundContext()
    }

    func perform(backgroundTask: @escaping (NSManagedObjectContext) -> Void) {
        container.performBackgroundTask(backgroundTask)
    }
}
