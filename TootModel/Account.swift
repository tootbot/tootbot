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

enum AccountKey: String, JSONPathType {
    case id
    case username
    case accountName = "acct"
    case displayName = "display_name"
    case note
    case websiteURL = "url"
    case avatarURL = "avatar"
    case headerURL = "header"
    case isLocked = "locked"
    case createdAt = "created_at"
    case followersCount = "followers_count"
    case followingCount = "following_count"
    case statusesCount = "statuses_count"

    func value(in dictionary: [String : JSON]) throws -> JSON {
        return try rawValue.value(in: dictionary)
    }
}

public struct Account: JSONDecodable {
    public var id: Int
    public var username: String
    public var accountName: String
    public var displayName: String
    public var note: String
    public var websiteURL: URL
    public var avatarURL: URL
    public var headerURL: URL
    public var isLocked: Bool
    public var createdAt: Date
    public var followersCount: Int
    public var followingCount: Int
    public var statusesCount: Int

    public init(json: JSON) throws {
        self.id = try json.getInt(at: AccountKey.id)
        self.username = try json.getString(at: AccountKey.username)
        self.accountName = try json.getString(at: AccountKey.accountName)
        self.displayName = try json.getString(at: AccountKey.displayName)
        self.note = try json.getString(at: AccountKey.note)
        self.websiteURL = URL(string: try json.getString(at: AccountKey.websiteURL))!
        self.avatarURL = URL(string: try json.getString(at: AccountKey.avatarURL))!
        self.headerURL = URL(string: try json.getString(at: AccountKey.headerURL))!
        self.isLocked = try json.getBool(at: AccountKey.isLocked)
        self.createdAt = SharedDateFormatter.date(from: try json.getString(at: AccountKey.createdAt))!
        self.followersCount = try json.getInt(at: AccountKey.followersCount)
        self.followingCount = try json.getInt(at: AccountKey.followingCount)
        self.statusesCount = try json.getInt(at: AccountKey.statusesCount)
    }
}
