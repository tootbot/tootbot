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

public struct FetchAccountStatusesRequest: Request {
    public typealias ResponseObject = [Status]

    public var instanceURI: String
    public var accountID: Int

    public var onlyMedia: Bool?
    public var excludeReplies: Bool?

    public init(instanceURI: String, accountID: Int, onlyMedia: Bool?, excludeReplies: Bool?) {
        self.instanceURI = instanceURI
        self.accountID = accountID
        self.onlyMedia = onlyMedia
        self.excludeReplies = excludeReplies
    }

    public func build() -> URLRequest {
        var components = URLComponents(string: "\(instanceURI)/api/v1/accounts/\(accountID)/statuses")!
        components.queryItems = {
            var items = [URLQueryItem]()

            if let onlyMedia = onlyMedia {
                items.append(URLQueryItem(name: "only_media", value: onlyMedia ? "true" : "false"))
            }

            if let excludeReplies = excludeReplies {
                items.append(URLQueryItem(name: "exclude_replies", value: excludeReplies ? "true" : "false"))
            }

            return items.isEmpty ? nil : items
        }()

        return URLRequest(url: components.url!)
    }
}
