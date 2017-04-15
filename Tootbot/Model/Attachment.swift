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

enum AttachmentKey: String, JSONPathType {
    case id
    case type
    case url
    case remoteURL = "remote_url"
    case previewURL = "preview_url"
    case textURL = "text_url"

    func value(in dictionary: [String : JSON]) throws -> JSON {
        return try rawValue.value(in: dictionary)
    }
}

extension JSONEntity {
    public enum AttachmentType: String, JSONTransformable {
        case image
        case video
        case gifv
    }

    public struct Attachment: JSONDecodable {
        public var id: Int
        public var type: AttachmentType
        public var url: URL
        public var remoteURL: URL?
        public var previewURL: URL
        public var textURL: URL?

        public init(json: JSON) throws {
            self.id = try json.getInt(at: AttachmentKey.id)
            self.type = try json.decode(at: AttachmentKey.type)
            self.url = URL(string: try json.getString(at: AttachmentKey.url))!
            self.remoteURL = (try json.getString(at: AttachmentKey.remoteURL, alongPath: [.missingKeyBecomesNil, .nullBecomesNil])).flatMap { URL(string: $0) }
            self.previewURL = URL(string: try json.getString(at: AttachmentKey.previewURL))!
            self.textURL = (try json.getString(at: AttachmentKey.textURL, alongPath: [.missingKeyBecomesNil, .nullBecomesNil])).flatMap { URL(string: $0) }
        }
    }
}
