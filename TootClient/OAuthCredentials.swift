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
import Freddy

enum OAuthCredentialsKey: String, JSONPathType {
    case id
    case clientID = "client_id"
    case clientSecret = "client_secret"

    func value(in dictionary: [String : JSON]) throws -> JSON {
        return try rawValue.value(in: dictionary)
    }
}

public struct OAuthCredentials: JSONDecodable {
    public var id: String
    public var clientID: String
    public var clientSecret: String

    public init(id: String, clientID: String, clientSecret: String) {
        self.id = id
        self.clientID = clientID
        self.clientSecret = clientSecret
    }
    
    public init(json: JSON) throws {
        self.id = try json.getString(at: OAuthCredentialsKey.id)
        self.clientID = try json.getString(at: OAuthCredentialsKey.clientID)
        self.clientSecret = try json.getString(at: OAuthCredentialsKey.clientSecret)
    }
}
