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

private enum RelationshipKey: String, JSONPathType {
    case isFollowing = "following"
    case isFollowedBy = "followed_by"
    case isBlocking = "blocking"
    case isMuting = "muting"
    case isRequested = "requested"

    func value(in dictionary: [String : JSON]) throws -> JSON {
        return try rawValue.value(in: dictionary)
    }
}

extension JSONEntity {
    public struct Relationship: JSONDecodable {
        public var isFollowing: Bool
        public var isFollowedBy: Bool
        public var isBlocking: Bool
        public var isMuting: Bool
        public var isRequested: Bool

        public init(json: JSON) throws {
            self.isFollowing = try json.getBool(at: RelationshipKey.isFollowing)
            self.isFollowedBy = try json.getBool(at: RelationshipKey.isFollowedBy)
            self.isBlocking = try json.getBool(at: RelationshipKey.isBlocking)
            self.isMuting = try json.getBool(at: RelationshipKey.isMuting)
            self.isRequested = try json.getBool(at: RelationshipKey.isRequested)
        }
    }
}