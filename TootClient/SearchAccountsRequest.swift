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

import TootModel
import TootNetworking

public struct SearchAccountsRequest: Request {
    public typealias ResponseObject = [Account]

    public var userAccount: UserAccount
    public var query: String
    public var limit: Int?

    public init(userAccount: UserAccount, query: String, limit: Int?) {
        self.userAccount = userAccount
        self.query = query
        self.limit = limit
    }

    public func build() -> URLRequest {
        let url = userAccount.instanceURL.appendingPathComponent("api/v1/accounts/search")
        var components = URLComponents(url: url, resolvingAgainstBaseURL: true)!
        components.queryItems = {
            var items = [URLQueryItem(name: "q", value: query)]
            if let limit = limit {
                items.append(URLQueryItem(name: "limit", value: String(describing: limit)))
            }
            return items
        }()

        var request = URLRequest(url: components.url!)
        request.setValue("Bearer \(userAccount.token)", forHTTPHeaderField: "Authorization")
        request.setValue("Bearer \(userAccount.token)", forHTTPHeaderField: "Authorization")
        return request
    }
}
