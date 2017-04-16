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

extension API {
    public struct Account: JSONDecodable, CoreDataExportable {
        enum Key: String, CoreDataKey {
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

            static var primaryKey: Key {
                return .id
            }
        }

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

        public var primaryKeyValue: Any {
            return id
        }

        public init(json: JSON) throws {
            self.id = try json.getInt(at: Key.id)
            self.username = try json.getString(at: Key.username)
            self.accountName = try json.getString(at: Key.accountName)
            self.displayName = try json.getString(at: Key.displayName)
            self.note = try json.getString(at: Key.note)
            self.websiteURL = URL(string: try json.getString(at: Key.websiteURL))!
            self.avatarURL = URL(string: try json.getString(at: Key.avatarURL))!
            self.headerURL = URL(string: try json.getString(at: Key.headerURL))!
            self.isLocked = try json.getBool(at: Key.isLocked)
            self.createdAt = SharedDateFormatter.date(from: try json.getString(at: Key.createdAt))!
            self.followersCount = try json.getInt(at: Key.followersCount)
            self.followingCount = try json.getInt(at: Key.followingCount)
            self.statusesCount = try json.getInt(at: Key.statusesCount)
        }
    }
}
