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
    public struct Attachment: JSONDecodable, CoreDataExportable {
        public enum MediaType: String, JSONTransformable {
            case image
            case video
            case gifv
        }

        enum Key: String, CoreDataKey {
            case id
            case type
            case url
            case remoteURL = "remote_url"
            case previewURL = "preview_url"
            case textURL = "text_url"

            static var primaryKey: Key {
                return .id
            }
        }

        public var id: Int
        public var type: MediaType
        public var url: URL
        public var remoteURL: URL?
        public var previewURL: URL
        public var textURL: URL?

        var primaryKeyValue: Any {
            return id
        }
        
        public init(json: JSON) throws {
            self.id = try json.getInt(at: Key.id)
            self.type = try json.decode(at: Key.type)
            self.url = URL(string: try json.getString(at: Key.url))!
            self.remoteURL = (try json.getString(at: Key.remoteURL, alongPath: [.missingKeyBecomesNil, .nullBecomesNil])).flatMap { URL(string: $0) }
            self.previewURL = URL(string: try json.getString(at: Key.previewURL))!
            self.textURL = (try json.getString(at: Key.textURL, alongPath: [.missingKeyBecomesNil, .nullBecomesNil])).flatMap { URL(string: $0) }
        }
    }
}
