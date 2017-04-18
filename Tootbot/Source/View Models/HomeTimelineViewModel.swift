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

class HomeTimelineViewModel {
    let dataController: DataController
    let dataFetcher: DataFetcher<Status>
    let networkingController: NetworkingController
    let timeline: Timeline

    public var statuses = [Status]()
    private var viewModels = [Int: StatusViewModel]()

  init?(timeline: Timeline, dataController: DataController, networkingController: NetworkingController) {
        guard let account = timeline.account, let userAccount = UserAccount(account: account) else {
            return nil
        }

        self.dataController = dataController
        self.networkingController = networkingController
        self.timeline = timeline

        let fetchRequest: NSFetchRequest<Status> = Status.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "%@ IN %K", timeline, #keyPath(Status.timelines))
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: #keyPath(Status.createdAt), ascending: false)]

        let networkRequest = NetworkRequest<JSONCollection<API.Status>>(userAccount: userAccount, networkingController: self.networkingController, endpoint: .homeTimeline)
        let cacheRequest = CacheRequest(managedObjectContext: self.dataController.viewContext, fetchRequest: fetchRequest)
        let dataImporter = DataImporter<Status>(dataController: self.dataController) { managedObjects in
            managedObjects.forEach { $0.addToTimelines(timeline) }
        }
        self.dataFetcher = DataFetcher(networkRequest: networkRequest, cacheRequest: cacheRequest, dataImporter: dataImporter)
    }

    func fetchNewestToots() -> SignalProducer<[Status], DataFetcherError> {
        return dataFetcher.fetch()
            .on(value: { self.statuses = $0 })
    }

    func viewModel(at index: IndexPath) -> StatusViewModel {
        if let viewModel = viewModels[index.row] {
            return viewModel
        } else {
            let status = statuses[index.row]
            let viewModel = StatusViewModel(status: status,
                                                managedObjectContext: dataController.viewContext)
            viewModels[index.row] = viewModel
            return self.viewModel(at: index)
        }
    }
}
