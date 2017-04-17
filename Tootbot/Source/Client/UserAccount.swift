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

public struct UserAccount: Hashable, LosslessStringConvertible {
    public var instanceURI: String
    public var username: String

    public init(instanceURI: String, username: String) {
        self.instanceURI = instanceURI
        self.username = username
    }

    public init?(account: Account) {
        guard let instanceURI = account.instanceURI, let username = account.username else {
            return nil
        }

        self.init(instanceURI: instanceURI, username: username)
    }

    public init?(_ description: String) {
        let split = description.characters.split(separator: "@")
        guard split.count == 2 else {
            return nil
        }

        self.username = String(split[0])
        self.instanceURI = String(split[1])
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
