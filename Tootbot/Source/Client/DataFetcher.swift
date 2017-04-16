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
import Result
import Moya
import Freddy

enum NetworkRequestError: Swift.Error {
    case unimplementedParseMethod
    case json(JSON.Error)
    case underlying(Swift.Error)
}

protocol NetworkRequestProtocol {
    associatedtype Output

    func request() -> SignalProducer<Response, MoyaError>
    func parse(response: Response) -> Result<Output, NetworkRequestError>
}

class NetworkRequest<Output>: NetworkRequestProtocol {
    let networkingController: NetworkingController
    let userAccount: UserAccount
    let endpoint: MastodonService

    init(userAccount: UserAccount, networkingController: NetworkingController, endpoint: MastodonService) {
        self.endpoint = endpoint
        self.networkingController = networkingController
        self.userAccount = userAccount
    }

    func request() -> SignalProducer<Response, MoyaError> {
        return networkingController.request(endpoint, authentication: .authenticated(account: userAccount))
    }

    func parse(response: Response) -> Result<Output, NetworkRequestError> {
        return .failure(.unimplementedParseMethod)
    }
}

extension NetworkRequestProtocol where Output: JSONDecodable {
    func parse(response: Response) -> Result<Output, NetworkRequestError> {
        do {
            let json = try JSON(data: response.data)
            let value = try Output(json: json)
            return .success(value)
        } catch {
            return .failure(.underlying(error))
        }
    }
}

extension NetworkRequestProtocol where Output: RangeReplaceableCollection, Output.Iterator.Element: JSONDecodable {
    func parse(response: Response) -> Result<Output, NetworkRequestError> {
        do {
            let json = try JSON(data: response.data)
            guard case .array(let jsonFragments) = json else {
                throw JSON.Error.valueNotConvertible(value: json, to: Output.self)
            }

            var collection = Output()
            collection.reserveCapacity(numericCast(jsonFragments.count))

            for jsonFragment in jsonFragments {
                let value = try Output.Iterator.Element(json: jsonFragment)
                collection.append(value)
            }

            return .success(collection)
        } catch {
            return .failure(.underlying(error))
        }
    }
}

enum CachePolicy {
    case localOnly
    case remoteOnly
    case localThenRemote

    static var `default`: CachePolicy {
        return .localThenRemote
    }
}

struct ManagedObjectRequest<ManagedObject>: NetworkRequestProtocol where ManagedObject: APIImportable, ManagedObject.T == ManagedObject {
    typealias Output = [ManagedObject.JSONModel]

    let requestFunction: () -> SignalProducer<Response, MoyaError>
    let parseFunction: (Response) -> Result<Output, NetworkRequestError>

    init<R>(_ request: R) where R: NetworkRequestProtocol, R.Output == Output {
        self.requestFunction = request.request
        self.parseFunction = request.parse
    }

    func request() -> SignalProducer<Response, MoyaError> {
        return requestFunction()
    }

    func parse(response: Response) -> Result<Output, NetworkRequestError> {
        return parseFunction(response)
    }
}

struct DataFetcher<ManagedObject> where ManagedObject: APIImportable, ManagedObject.T == ManagedObject {
    enum Error: Swift.Error {
        case moya(MoyaError)
        case networkRequest(NetworkRequestError)
        case coreData(NSError)
    }
    
    let request: ManagedObjectRequest<ManagedObject>
    let cacheRequest: CacheRequest<ManagedObject>

    init<Request>(request: Request, cacheRequest: CacheRequest<ManagedObject>) where Request: NetworkRequestProtocol, Request.Output == [ManagedObject.JSONModel] {
        self.request = ManagedObjectRequest(request)
        self.cacheRequest = cacheRequest
    }

    func fetch(cachePolicy: CachePolicy = .default) -> SignalProducer<[ManagedObject], Error> {
        switch cachePolicy {
        case .localOnly:
            return cacheRequest.fetch().mapError(Error.coreData)
        case .remoteOnly:
            return request.request()
                .mapError(Error.moya)
                .attemptMap { response in
                    self.request.parse(response: response)
                        .mapError(Error.networkRequest)
                }
                .observe(on: QueueScheduler.main)
                .map { models -> [ManagedObject] in
                    let context = self.cacheRequest.dataController.viewContext
                    return models.map { model in ManagedObject.upsert(model: model, in: context) }
                }
                .then(fetch(cachePolicy: .localOnly))
        case .localThenRemote:
            let local = fetch(cachePolicy: .localOnly)
            let remote = fetch(cachePolicy: .remoteOnly)
            return SignalProducer { observer, disposable in
                let localDisposable = local.start(observer)
                disposable += localDisposable

                let remoteDisposable = remote.on(completed: localDisposable.dispose).start(observer)
                disposable += remoteDisposable
            }
        }
    }
}

struct CacheRequest<ManagedObject> where ManagedObject: APIImportable, ManagedObject.T == ManagedObject {
    let dataController: DataController
    let fetchRequest: NSFetchRequest<ManagedObject>

    init(dataController: DataController, fetchRequest: NSFetchRequest<ManagedObject>) {
        self.dataController = dataController
        self.fetchRequest = fetchRequest
    }

    func fetch() -> SignalProducer<[ManagedObject], NSError> {
        return SignalProducer { observer, disposable in
            do {
                let results = try self.dataController.viewContext.fetch(self.fetchRequest)
                observer.send(value: results)
            } catch {
                observer.send(error: error as NSError)
            }

        }
    }
}