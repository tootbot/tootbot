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

import Foundation
import Freddy

enum MentionKey: String, JSONPathType {
    case profileURL = "url"
    case username
    case accountName = "acct"
    case accountID = "id"

    func value(in dictionary: [String : JSON]) throws -> JSON {
        return try rawValue.value(in: dictionary)
    }
}

public struct Mention: JSONDecodable, JSONEncodable {
    public var accountID: Int
    public var profileURL: URL
    public var accountName: String
    public var username: String

    public init(json: JSON) throws {
        self.accountID = try json.getInt(at: MentionKey.accountID)
        self.profileURL = URL(string: try json.getString(at: MentionKey.profileURL))!
        self.accountName = try json.getString(at: MentionKey.accountName)
        self.username = try json.getString(at: MentionKey.username)
    }

    public func toJSON() -> JSON {
        return [
            MentionKey.accountID.rawValue: accountID.toJSON(),
            MentionKey.profileURL.rawValue: profileURL.absoluteString.toJSON(),
            MentionKey.accountName.rawValue: accountName.toJSON(),
            MentionKey.username.rawValue: username.toJSON()
        ]
    }
}
