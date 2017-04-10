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

public struct SearchRequest: Request {
    public typealias ResponseObject = Results

    public var instanceURI: String
    public var query: String
    public var shouldResolveRemoteAccounts: Bool

    public init(instanceURI: String, query: String, shouldResolveRemoteAccounts: Bool) {
        self.instanceURI = instanceURI
        self.query = query
        self.shouldResolveRemoteAccounts = shouldResolveRemoteAccounts
    }

    public func build() -> URLRequest {
        var components = URLComponents(string: "\(instanceURI)/api/v1/search")!
        components.queryItems = [
            URLQueryItem(name: "q", value: query),
            URLQueryItem(name: "resolve", value: shouldResolveRemoteAccounts ? "true" : "false"),
        ]
        return URLRequest(url: components.url!)
    }
}
