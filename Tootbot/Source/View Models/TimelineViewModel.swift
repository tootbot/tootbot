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
import Moya
import ReactiveSwift
import Result

class TimelineViewModel {
    let dataController: DataController
    let dataFetcher: DataFetcher<Status>
    let fetchNewestTootsAction: Action<(), [Status], DataFetcherError>
    let networkingController: NetworkingController
    let timeline: Timeline

    private let statuses = MutableProperty<[Status]>([])
    private var viewModelCache = [NSManagedObjectID: StatusCellViewModel]()
    let statusesUpdated: Signal<(), NoError>

    init?(timeline: Timeline, dataController: DataController, networkingController: NetworkingController) {
        guard let account = timeline.account, let userAccount = UserAccount(account: account) else {
            return nil
        }

        self.dataController = dataController
        self.networkingController = networkingController
        self.timeline = timeline

        let fetchRequest: NSFetchRequest<Status> = Status.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "%@ IN %K", timeline, #keyPath(Status.timelines))
        fetchRequest.relationshipKeyPathsForPrefetching = [#keyPath(Status.attachments)]
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: #keyPath(Status.createdAt), ascending: false)]

        let endpoint = (timeline.timelineTypeValue ?? .home).endpoint
        let networkRequest = NetworkRequest<JSONCollection<API.Status>>(userAccount: userAccount, networkingController: self.networkingController, endpoint: endpoint)
        let cacheRequest = CacheRequest(managedObjectContext: self.dataController.viewContext, fetchRequest: fetchRequest)
        let dataImporter = DataImporter<Status>(dataController: self.dataController) { managedObjects in
            managedObjects.forEach { $0.addToTimelines(timeline) }
        }
        let dataFetcher = DataFetcher(networkRequest: networkRequest, cacheRequest: cacheRequest, dataImporter: dataImporter)
        self.dataFetcher = dataFetcher

        self.fetchNewestTootsAction = Action { _ in dataFetcher.fetch() }
        self.statuses <~ self.fetchNewestTootsAction.values
        self.statusesUpdated = self.statuses.signal.map { _ in () }
    }

    var numberOfStatuses: Int {
        return statuses.value.count
    }

    func viewModel(at indexPath: IndexPath) -> StatusCellViewModel {
        let status = statuses.value[indexPath.row]
        let objectID = status.objectID

        if let viewModel = viewModelCache[objectID] {
            return viewModel
        } else {
            let viewModel = StatusCellViewModel(status: status, managedObjectContext: dataController.viewContext)
            viewModelCache[objectID] = viewModel
            return viewModel
        }
    }
}
