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

    public var instanceURI: String
    public var accountIDs: [Int]

    public init(instanceURI: String, accountIDs: [Int]) {
        self.instanceURI = instanceURI
        self.accountIDs = accountIDs
    }

    public func build() -> URLRequest {
        var components = URLComponents(string: "\(instanceURI)/api/v1/accounts/relationships")!
        components.queryItems = accountIDs.map { accountID in
            URLQueryItem(name: "id", value: String(describing: accountID))
        }

        return URLRequest(url: components.url!)
    }
}
