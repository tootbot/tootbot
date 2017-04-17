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

import Freddy

public protocol JSONTransformable: JSONDecodable, JSONEncodable {
}

extension JSONTransformable where Self: RawRepresentable, Self.RawValue: JSONDecodable {
    public init(json: JSON) throws {
        let rawValue = try RawValue(json: json)
        if let newValue = Self(rawValue: rawValue) {
            self = newValue
        } else {
            throw JSON.Error.valueNotConvertible(value: json, to: Self.self)
        }
    }
}

extension JSONTransformable where Self: RawRepresentable, Self.RawValue: JSONEncodable {
    public func toJSON() -> JSON {
        return rawValue.toJSON()
    }
}
