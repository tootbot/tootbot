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

public struct UserAccount: CustomStringConvertible, Equatable, Hashable {
    public var instanceURI: String
    public var username: String

    public init(instanceURI: String, username: String) {
        self.instanceURI = instanceURI
        self.username = username
    }

    public static func ==(lhs: UserAccount, rhs: UserAccount) -> Bool {
        return lhs.instanceURI == rhs.instanceURI && lhs.username == rhs.username
    }

    public var hashValue: Int {
        return 31 &* instanceURI.hashValue &+ username.hashValue
    }

    public var description: String {
        return username + "@" + instanceURI
    }
}
