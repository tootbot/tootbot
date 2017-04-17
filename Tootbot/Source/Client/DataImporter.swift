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

import ReactiveSwift

enum DataImporterError: Error {
    case coreData(Error)
}

struct DataImporter<ManagedObject> where ManagedObject: APIImportable, ManagedObject.T == ManagedObject {
    let dataController: DataController
    let beforeSaveHandler: ([ManagedObject]) -> Void

    init(dataController: DataController, beforeSaveHandler: @escaping ([ManagedObject]) -> Void = { _ in }) {
        self.beforeSaveHandler = beforeSaveHandler
        self.dataController = dataController
    }

    func importModels(collection: JSONCollection<ManagedObject.JSONModel>) -> SignalProducer<[ManagedObject], DataImporterError> {
        return SignalProducer { observer, disposable in
            self.dataController.perform(backgroundTask: { context in
                guard !disposable.isDisposed else { return }

                let managedObjects = collection.elements.map { model in ManagedObject.upsert(model: model, in: context) }
                self.beforeSaveHandler(managedObjects)

                do {
                    try context.save()
                } catch {
                    observer.send(error: .coreData(error))
                    return
                }

                let managedObjectIDs = managedObjects.map { $0.objectID }
                DispatchQueue.main.async {
                    guard !disposable.isDisposed else { return }

                    let viewContext = self.dataController.viewContext
                    let managedObjects = managedObjectIDs.map { objectID in viewContext.object(with: objectID) as! ManagedObject }
                    observer.send(value: managedObjects)
                    observer.sendCompleted()
                }
            })
        }
    }
}
