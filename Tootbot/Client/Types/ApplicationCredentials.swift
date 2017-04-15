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

enum ApplicationCredentialsKey: String, JSONPathType {
    case instanceURI = "uri"
    case oauthCredentials = "credentials"

    func value(in dictionary: [String : JSON]) throws -> JSON {
        return try rawValue.value(in: dictionary)
    }
}

public struct ApplicationCredentials: JSONDecodable, JSONEncodable {
    public var instanceURI: String
    public var oauthCredentials: OAuthCredentials

    public init(instanceURI: String, oauthCredentials: OAuthCredentials) {
        self.instanceURI = instanceURI
        self.oauthCredentials = oauthCredentials
    }

    public init(json: JSON) throws {
        self.instanceURI = try json.getString(at: ApplicationCredentialsKey.instanceURI)
        self.oauthCredentials = try json.decode(at: ApplicationCredentialsKey.oauthCredentials)
    }

    public func toJSON() -> JSON {
        return [
            ApplicationCredentialsKey.instanceURI.rawValue: instanceURI.toJSON(),
            ApplicationCredentialsKey.oauthCredentials.rawValue: oauthCredentials.toJSON(),
        ]
    }
}
