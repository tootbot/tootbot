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

public enum StatusVisibility: String, JSONTransformable {
    case `public`
    case unlisted
    case `private`
    case direct
}

enum StatusKey: String, JSONPathType {
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

    func value(in dictionary: [String : JSON]) throws -> JSON {
        return try rawValue.value(in: dictionary)
    }
}

public struct Status: JSONDecodable {
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
    public var visibility: StatusVisibility
    public var mediaAttachments: [Attachment]
    public var mentions: [Mention]
    public var tags: [Tag]
    public var application: Application?

    public init(json: JSON) throws {
        self.id = try json.getInt(at: StatusKey.id)
        self.fediverseURI = try json.getString(at: StatusKey.fediverseURI)
        self.statusURL = URL(string: try json.getString(at: StatusKey.statusURL))!
        self.account = try json.decode(at: StatusKey.account)
        self.inReplyToID = try json.getInt(at: StatusKey.inReplyToID, alongPath: [.missingKeyBecomesNil, .nullBecomesNil])
        self.inReplyToAccountID = try json.getInt(at: StatusKey.inReplyToAccountID, alongPath: [.missingKeyBecomesNil, .nullBecomesNil])
        self.rebloggedStatus = (try json.decode(at: StatusKey.rebloggedStatus, alongPath: [.missingKeyBecomesNil, .nullBecomesNil])).map(Box.init)
        self.content = try json.getString(at: StatusKey.content)
        self.createdAt = SharedDateFormatter.date(from: try json.getString(at: StatusKey.createdAt))!
        self.reblogsCount = try json.getInt(at: StatusKey.reblogsCount)
        self.favoritesCount = try json.getInt(at: StatusKey.favoritesCount)
        self.isReblogged = try json.getBool(at: StatusKey.isReblogged, alongPath: [.missingKeyBecomesNil, .nullBecomesNil]) ?? false
        self.isFavorited = try json.getBool(at: StatusKey.isFavorited, alongPath: [.missingKeyBecomesNil, .nullBecomesNil]) ?? false
        self.isSensitive = try json.getBool(at: StatusKey.isSensitive, alongPath: [.missingKeyBecomesNil, .nullBecomesNil]) ?? false
        self.spoilerText = try json.getString(at: StatusKey.spoilerText)
        self.visibility = try json.decode(at: StatusKey.visibility)
        self.mediaAttachments = try json.decodedArray(at: StatusKey.mediaAttachments)
        self.mentions = try json.decodedArray(at: StatusKey.mentions)
        self.tags = try json.decodedArray(at: StatusKey.tags)
        self.application = try json.decode(at: StatusKey.application, alongPath: [.missingKeyBecomesNil, .nullBecomesNil])
    }
}
