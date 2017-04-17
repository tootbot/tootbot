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

import Freddy
import Moya
import ReactiveSwift
import Result

enum NetworkRequestError: Swift.Error {
    case json(JSON.Error)
    case underlying(Swift.Error)
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
