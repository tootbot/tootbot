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

public enum Authentication: CustomStringConvertible, Equatable, Hashable {
    case authenticated(account: UserAccount)
    case unauthenticated(instanceURI: String)

    public static func ==(lhs: Authentication, rhs: Authentication) -> Bool {
        switch (lhs, rhs) {
        case (.authenticated(let leftAccount), .authenticated(let rightAccount)):
            return leftAccount == rightAccount
        case (.unauthenticated(let leftInstanceURI), .unauthenticated(let rightInstanceURI)):
            return leftInstanceURI == rightInstanceURI
        default:
            return false
        }
    }

    public var description: String {
        switch self {
        case .authenticated(let account):
            return String(describing: account)
        case .unauthenticated(let instanceURI):
            return instanceURI
        }
    }

    public var hashValue: Int {
        switch self {
        case .authenticated(let account):
            return account.hashValue
        case .unauthenticated(let instanceURI):
            return instanceURI.hashValue
        }
    }

    var instanceURI: String {
        switch self {
        case .authenticated(let account):
            return account.instanceURI
        case .unauthenticated(let instanceURI):
            return instanceURI
        }
    }
}
