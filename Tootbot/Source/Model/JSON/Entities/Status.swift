//
// Copyright (C) 2017 Tootbot Contributors
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
    public struct Status: JSONDecodable, CoreDataExportable {
        enum Key: String, CoreDataKey {
            case id
            case fediverseURI = "uri"
            case statusURL = "url"
            case account
            case inReplyToID = "in_reply_to_id"
            case inReplyToAccountID = "in_reply_to_account_id"
            case rebloggedStatus = "reblog"
            case content
            case createdAt = "created_at"
            case reblogsCount = "reblogs_count"
            case favoritesCount = "favourites_count"
            case isReblogged = "reblogged"
            case isFavorited = "favourited"
            case isSensitive = "sensitive"
            case spoilerText = "spoiler_text"
            case visibility
            case mediaAttachments = "media_attachments"
            case mentions
            case tags
            case application

            static var primaryKey: Key {
                return .id
            }
        }

        public enum Visibility: String, JSONTransformable {
            case `public`
            case unlisted
            case `private`
            case direct
        }

        public var id: Int
        public var fediverseURI: String
        public var statusURL: URL
        public var account: Account
        public var inReplyToID: Int?
        public var inReplyToAccountID: Int?
        public var rebloggedStatus: Box<Status>?
        public var content: String
        public var createdAt: Date
        public var reblogsCount: Int
        public var favoritesCount: Int
        public var isReblogged: Bool
        public var isFavorited: Bool
        public var isSensitive: Bool
        public var spoilerText: String
        public var visibility: Visibility
        public var mediaAttachments: [Attachment]
        public var mentions: [Mention]
        public var tags: [Tag]
        public var application: Application?

        var primaryKeyValue: Any {
            return id
        }

        public init(json: JSON) throws {
            self.id = try json.getInt(at: Key.id)
            self.fediverseURI = try json.getString(at: Key.fediverseURI)
            self.statusURL = URL(string: try json.getString(at: Key.statusURL))!
            self.account = try json.decode(at: Key.account)
            self.inReplyToID = try json.getInt(at: Key.inReplyToID, alongPath: [.missingKeyBecomesNil, .nullBecomesNil])
            self.inReplyToAccountID = try json.getInt(at: Key.inReplyToAccountID, alongPath: [.missingKeyBecomesNil, .nullBecomesNil])
            self.rebloggedStatus = (try json.decode(at: Key.rebloggedStatus, alongPath: [.missingKeyBecomesNil, .nullBecomesNil])).map(Box.init)
            self.content = try json.getString(at: Key.content)
            self.createdAt = SharedDateFormatter.date(from: try json.getString(at: Key.createdAt))!
            self.reblogsCount = try json.getInt(at: Key.reblogsCount)
            self.favoritesCount = try json.getInt(at: Key.favoritesCount)
            self.isReblogged = try json.getBool(at: Key.isReblogged, alongPath: [.missingKeyBecomesNil, .nullBecomesNil]) ?? false
            self.isFavorited = try json.getBool(at: Key.isFavorited, alongPath: [.missingKeyBecomesNil, .nullBecomesNil]) ?? false
            self.isSensitive = try json.getBool(at: Key.isSensitive, alongPath: [.missingKeyBecomesNil, .nullBecomesNil]) ?? false
            self.spoilerText = try json.getString(at: Key.spoilerText)
            self.visibility = try json.decode(at: Key.visibility)
            self.mediaAttachments = try json.decodedArray(at: Key.mediaAttachments)
            self.mentions = try json.decodedArray(at: Key.mentions)
            self.tags = try json.decodedArray(at: Key.tags)
            self.application = try json.decode(at: Key.application, alongPath: [.missingKeyBecomesNil, .nullBecomesNil])
        }
    }
}
