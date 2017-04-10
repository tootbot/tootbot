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

public struct PostStatusRequest: Request {
    public typealias ResponseObject = Status

    public var userAccount: UserAccount
    public var status: String
    public var inReplyToID: Int?
    public var mediaIDs: [Int]?
    public var isSensitive: Bool?
    public var spoilerText: String?
    public var visibility: StatusVisibility?

    public init(userAccount: UserAccount, status: String, inReplyToID: Int?, mediaIDs: [Int]?, isSensitive: Bool?, spoilerText: String?, visibility: StatusVisibility?) {
        self.userAccount = userAccount
        self.status = status
        self.inReplyToID = inReplyToID
        self.mediaIDs = mediaIDs
        self.isSensitive = isSensitive
        self.spoilerText = spoilerText
        self.visibility = visibility
    }

    func payload() -> Data? {
        var data = [String: JSON]()
        data["status"] = status.toJSON()
        data["in_reply_to_id"] = inReplyToID?.toJSON()
        data["media_ids"] = mediaIDs?.toJSON()
        data["sensitive"] = isSensitive?.toJSON()
        data["spoiler_text"] = spoilerText?.toJSON()
        data["visibility"] = visibility?.rawValue.toJSON()

        return try? JSON.dictionary(data).serialize()
    }

    public func build() -> URLRequest {
        var request = URLRequest(url: userAccount.instanceURL.appendingPathComponent("api/v1/statuses"))
        request.httpBody = payload()
        request.httpMethod = Method.post.rawValue
        request.setValue("Bearer \(userAccount.token)", forHTTPHeaderField: "Authorization")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        return request
    }
}
