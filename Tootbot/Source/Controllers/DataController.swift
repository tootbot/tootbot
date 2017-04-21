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

class DataController {
    enum Error: Swift.Error {
        case loadFailure(Swift.Error)
        case saveFailure(Swift.Error)
        case invalidStore
    }

    let container: NSPersistentContainer

    fileprivate init(userAccount: UserAccount) {
        let name = String(describing: userAccount)

        let modelURL = Bundle.main.url(forResource: "Tootbot", withExtension: "momd")!
        let model = NSManagedObjectModel(contentsOf: modelURL)!

        self.container = NSPersistentContainer(name: name, managedObjectModel: model)
    }

    static func load(forAccount userAccount: UserAccount) -> SignalProducer<DataController, Error> {
        return SignalProducer.deferred {
            let dataController = DataController(userAccount: userAccount)
            return dataController.load()
                .observe(on: QueueScheduler.main)
                .flatMap(.latest) { _ -> SignalProducer<Account, Error> in
                    do {
                        if let account = try dataController.account() {
                            return dataController.setUpAccount(account)
                        } else {
                            return SignalProducer(error: .invalidStore)
                        }
                    } catch {
                        return SignalProducer(error: .loadFailure(error))
                    }
                }
                .observe(on: QueueScheduler.main)
                .map { _ in dataController }
        }
    }

    static func create(forAccount accountModel: API.Account, instanceURI: String) -> SignalProducer<DataController, Error> {
        return SignalProducer.deferred {
            let userAccount = UserAccount(instanceURI: instanceURI, username: accountModel.username)
            let dataController = DataController(userAccount: userAccount)
            return dataController.load()
                .flatMap(.latest) { _ in dataController.insertAccount(from: accountModel, instanceURI: instanceURI) }
                .observe(on: QueueScheduler.main)
                .map { _ in dataController }
        }
    }

    fileprivate func insertAccount(from accountModel: API.Account, instanceURI: String) -> SignalProducer<Account, Error> {
        return SignalProducer { observer, disposable in
            self.perform(backgroundTask: { context in
                guard !disposable.isDisposed else { return }

                let account = Account(context: context)
                account.instanceURI = instanceURI
                account.update(with: accountModel)

                _ = self.performSetup(for: account)

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

    fileprivate func performSetup(for account: Account) -> Bool {
        let context = account.managedObjectContext!

        var needsSave = false
        for timelineType in TimelineType.all {
            if account.timeline(ofType: timelineType) == nil {
                let timeline = Timeline(context: context)
                timeline.account = account
                timeline.timelineTypeValue = timelineType
                needsSave = true
            }
        }

        return needsSave
    }

    fileprivate func setUpAccount(_ account: Account) -> SignalProducer<Account, Error> {
        let managedObjectID = account.objectID
        return SignalProducer { observer, disposable in
            self.perform(backgroundTask: { context in
                guard !disposable.isDisposed else { return }

                let account = context.object(with: managedObjectID) as! Account
                if self.performSetup(for: account) {
                    do {
                        try context.save()
                    } catch {
                        observer.send(error: .saveFailure(error))
                    }
                }

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

    func account() throws -> Account? {
        let fetchRequest: NSFetchRequest<Account> = Account.fetchRequest()
        fetchRequest.fetchLimit = 1

        let results = try viewContext.fetch(fetchRequest)
        return results.first
    }

    fileprivate func load() -> SignalProducer<NSPersistentStoreDescription, Error> {
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
