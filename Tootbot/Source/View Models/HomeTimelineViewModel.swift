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

class HomeTimelineRequest: NetworkRequest<[API.Status]> {
    init(userAccount: UserAccount, networkingController: NetworkingController) {
        super.init(userAccount: userAccount, networkingController: networkingController, endpoint: .homeTimeline)
    }
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
    }

    func fetchNewestToots() -> SignalProducer<[Status], HomeTimelineError> {
        return SignalProducer { observer, disposable in
            guard let account = self.timeline.account.flatMap(UserAccount.init) else {
                observer.send(error: .invalidTimeline)
                return
            }

//            let fetchRequest: NSFetchRequest<Status> = Status.fetchRequest()
//            fetchRequest.predicate = NSPredicate(format: "%@ IN timelines", self.timeline)

            let request = HomeTimelineRequest(userAccount: account, networkingController: self.networkController)
            let cacheRequest = CacheRequest<Status>(dataController: self.dataController, fetchRequest: Status.fetchRequest())
            let dataSource = DataFetcher<Status>(request: request, cacheRequest: cacheRequest)

//            let request = HomeTimelineRequest(userAccount: account, networkingController: self.networkController)
//            let fetcher = DataFetcher<HomeTimelineRequest, Status>(request: request, dataController: self.dataController)

//            _ = fetcher
//            disposable += fetcher.fetch()
//                .mapError { _ in .networkingError }
//                .start(observer)
        }
    }
}
