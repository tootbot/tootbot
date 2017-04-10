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

import Freddy
import TootModel
import TootNetworking

public enum ApplicationScope: String {
    case read
    case write
    case follow
}

public struct RegisterApplicationRequest: Request {
    public typealias ResponseObject = OAuthCredentials

    public var instanceURI: String
    public var clientName: String
    public var redirectURI: String
    public var scopes: Set<ApplicationScope>
    public var homepageURL: URL?

    public init(instanceURI: String, clientName: String, redirectURI: String, scopes: Set<ApplicationScope>, homepageURL: URL?) {
        self.instanceURI = instanceURI
        self.clientName = clientName
        self.redirectURI = redirectURI
        self.scopes = scopes
        self.homepageURL = homepageURL
    }

    func payload() -> Data? {
        var data = [String: JSON]()
        data["client_name"] = clientName.toJSON()
        data["redirect_uris"] = redirectURI.toJSON()
        data["scopes"] = scopes.map({ $0.rawValue }).joined(separator: " ").toJSON()
        data["website"] = homepageURL?.absoluteString.toJSON()

        return try? JSON.dictionary(data).serialize()
    }

    public func build() -> URLRequest {
        var request = URLRequest(url: URL(string: "\(instanceURI)/api/v1/apps")!)
        request.httpMethod = Method.post.rawValue
        request.httpBody = payload()
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        return request
    }
}
