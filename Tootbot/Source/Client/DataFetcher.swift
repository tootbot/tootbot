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
import Result
import Moya
import Freddy

enum NetworkRequestError: Swift.Error {
    case unimplementedParseMethod
    case json(JSON.Error)
    case underlying(Swift.Error)
}

struct JSONCollection<T>: JSONDecodable, CustomStringConvertible, CustomDebugStringConvertible where T: JSONDecodable {
    var elements: [T]

    init(_ elements: [T]) {
        self.elements = elements
    }

    init(json: JSON) throws {
        guard case .array(let elements) = json else {
            throw JSON.Error.valueNotConvertible(value: json, to: JSONCollection<T>.self)
        }

        self.elements = try elements.map { json in try T(json: json) }
    }

    var description: String {
        return String(describing: elements)
    }

    var debugDescription: String {
        return String(reflecting: elements)
    }
}

protocol NetworkRequestProtocol {
    associatedtype Output

    func request() -> SignalProducer<Response, MoyaError>
    func parse(response: Response) -> Result<Output, NetworkRequestError>
}

class NetworkRequest<T>: NetworkRequestProtocol where T: JSONDecodable {
    typealias Output = T

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
        do {
            let json = try JSON(data: response.data)
            let value = try Output(json: json)
            return .success(value)
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

struct ManagedObjectRequest<ManagedObject>: NetworkRequestProtocol where ManagedObject: APIImportable, ManagedObject.T == ManagedObject, ManagedObject.JSONModel: JSONDecodable {
    typealias Output = JSONCollection<ManagedObject.JSONModel>

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

    init<Request>(request: Request, cacheRequest: CacheRequest<ManagedObject>) where Request: NetworkRequestProtocol, Request.Output == JSONCollection<ManagedObject.JSONModel> {
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
                    return models.elements.map { model in ManagedObject.upsert(model: model, in: context) }
                }
                .concat(fetch(cachePolicy: .localOnly))
        case .localThenRemote:
            let local = fetch(cachePolicy: .localOnly)
            let remote = fetch(cachePolicy: .remoteOnly)
            return local.take(untilReplacement: remote)
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
        return SignalProducer(attempt: { try self.dataController.viewContext.fetch(self.fetchRequest) })
    }
}
