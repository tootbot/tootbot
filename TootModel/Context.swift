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

enum ContextKey: String, JSONPathType {
    case ancestors
    case descendants

    func value(in dictionary: [String : JSON]) throws -> JSON {
        return try rawValue.value(in: dictionary)
    }
}

public struct Context: JSONDecodable, JSONEncodable {
    public var ancestors: [Status]
    public var descendants: [Status]

    public init(json: JSON) throws {
        self.ancestors = try json.decodedArray(at: ContextKey.ancestors)
        self.descendants = try json.decodedArray(at: ContextKey.descendants)
    }

    public func toJSON() -> JSON {
        return [
            ContextKey.ancestors.rawValue: ancestors.toJSON(),
            ContextKey.descendants.rawValue: descendants.toJSON(),
        ]
    }
}
