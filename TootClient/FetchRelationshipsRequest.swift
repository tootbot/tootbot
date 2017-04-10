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

public struct FetchRelationshipsRequest: Request {
    public typealias ResponseObject = [Relationship]

    public var userAccount: UserAccount
    public var accountIDs: [Int]

    public init(userAccount: UserAccount, accountIDs: [Int]) {
        self.userAccount = userAccount
        self.accountIDs = accountIDs
    }

    public func build() -> URLRequest {
        let url = userAccount.instanceURL.appendingPathComponent("api/v1/accounts/relationships")
        var components = URLComponents(url: url, resolvingAgainstBaseURL: true)!
        components.queryItems = accountIDs.map { URLQueryItem(name: "id", value: String(describing: $0)) }

        var request = URLRequest(url: components.url!)
        request.setValue("Bearer \(userAccount.token)", forHTTPHeaderField: "Authorization")
        return request
    }
}
