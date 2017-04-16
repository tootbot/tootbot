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
import Moya
import ReactiveSwift

enum HomeTimelineError: Swift.Error {
    case invalidTimeline
    case networkingError
    case coreDataFetchError
}

class HomeTimelineViewModel {
    let dataController: DataController
    let networkController: NetworkingController
    let timeline: Timeline

    var statuses = [Status]()
    var statusViewModels: LazyMapCollection<[Status], StatusViewModel> {
        return statuses.lazy.map { status in StatusViewModel(status: status, managedObjectContext: self.dataController.viewContext) }
    }

    init(timeline: Timeline, dataController: DataController, networkController: NetworkingController) {
        self.dataController = dataController
        self.networkController = networkController
        self.timeline = timeline

        let fetchRequest: NSFetchRequest<Status> = Status.fetchRequest()
        fetchRequest.fetchBatchSize = 20
        fetchRequest.predicate = NSPredicate(format: "timelines CONTAINS %@", timeline)
        fetchRequest.sortDescriptors = [NSSortDescriptor.init(key: "createdAt", ascending: false)]

        do {
            self.statuses = try dataController.viewContext.fetch(fetchRequest)
        } catch {
            print("Could not fetch statuses -> \(error)")
        }
    }

    func fetchNewestToots() -> SignalProducer<[Status], HomeTimelineError> {
        return SignalProducer { observer, disposable in
            guard let account = self.timeline.account.flatMap(UserAccount.init)
            else {
                observer.send(error: .invalidTimeline)
                return
            }

            disposable += self.networkController.request(.homeTimeline, authentication: .authenticated(account: account))
                .mapFreddyJSONDecodedArray(JSONEntity.Status.self)
                .startWithResult { result in
                    switch result {
                    case .success(let statuses):
                        self.dataController.perform { context in
                            guard !disposable.isDisposed else { return }

                            let statusIDs = statuses.map { $0.id }
                            let fetchRequest: NSFetchRequest<Status> = Status.fetchRequest()
                            fetchRequest.predicate = NSPredicate(format: "statusID in %@", statusIDs)

                            var statusEntities: [Status]
                            do {
                                statusEntities = try context.fetch(fetchRequest)
                            } catch {
                                observer.send(error: .coreDataFetchError)
                                return
                            }

                            let now = NSDate()

                            var userEntites = [Int64: User]()

                            for jsonStatus in statuses {
                                let statusEntity: Status
                                if let existingStatus = statusEntities.first(where: { $0.statusID == Int64(jsonStatus.id) }) {
                                    statusEntity = existingStatus
                                } else {
                                    statusEntity = Status(context: context)
                                    statusEntity.applicationName = jsonStatus.application?.name
                                    statusEntity.applicationURL = jsonStatus.application?.websiteURL
                                    statusEntity.content = jsonStatus.content
                                    statusEntity.createdAt = jsonStatus.createdAt as NSDate?
                                    statusEntity.isFavorited = jsonStatus.isFavorited
                                    statusEntity.isReblogged = jsonStatus.isReblogged
                                    statusEntity.isSensitive = jsonStatus.isSensitive
                                    statusEntity.spoilerText = jsonStatus.spoilerText
                                    statusEntity.statusID = Int64(jsonStatus.id)

                                    statusEntities.append(statusEntity)
                                }

                                statusEntity.updatedAt = now

                                let userEntity: User
                                if let existingUser = userEntites[Int64(jsonStatus.account.id)] {
                                    userEntity = existingUser
                                } else if let existingUser = statusEntity.user {
                                    userEntity = existingUser
                                } else {
                                    let fetchRequest: NSFetchRequest<User> = User.fetchRequest()
                                    fetchRequest.fetchLimit = 1
                                    fetchRequest.predicate = NSPredicate(format: "userID == %@", jsonStatus.account.id as NSNumber)

                                    if let existingUser = (try? context.fetch(fetchRequest))?.first {
                                        userEntity = existingUser
                                    } else {
                                        userEntity = User(context: context)
                                    }
                                }

                                userEntity.updatedAt = now
                                userEntity.userID = Int64(jsonStatus.account.id)
                                userEntity.username = jsonStatus.account.username
                                userEntity.accountName = jsonStatus.account.accountName
                                userEntity.displayName = jsonStatus.account.displayName
                                userEntity.statusesCount = Int64(jsonStatus.account.statusesCount)
                                userEntity.followersCount = Int64(jsonStatus.account.followersCount)
                                userEntity.followingCount = Int64(jsonStatus.account.followingCount)
                                userEntity.createdAt = jsonStatus.account.createdAt as NSDate
                                userEntity.isLocked = jsonStatus.account.isLocked
                                userEntity.note = jsonStatus.account.note
                                userEntity.websiteURL = jsonStatus.account.websiteURL
                                userEntity.avatarURL = jsonStatus.account.avatarURL
                                userEntity.headerURL = jsonStatus.account.headerURL

                                userEntites[userEntity.userID] = userEntity
                            }

                            _ = try? context.save()

                            let objectIDs = statusEntities.map { $0.objectID }

                            DispatchQueue.main.async {
                                guard !disposable.isDisposed else { return }

                                let mainQueueObjects = objectIDs.map { self.dataController.viewContext.object(with: $0) as! Status }
                                self.statuses = mainQueueObjects
                                observer.send(value: mainQueueObjects)
                                observer.sendCompleted()
                            }
                        }


                    case .failure:
                        observer.send(error: .networkingError)
                    }
                }
        }
    }
}
