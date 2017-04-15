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

import SAMKeychain

public protocol KeychainProtocol {
    func passwordData(forService serviceName: String, account: String) -> Data?

    @discardableResult
    func deletePassword(forService serviceName: String, account: String) -> Bool

    @discardableResult
    func setPasswordData(_ passwordData: Data, forService serviceName: String, account: String) -> Bool
}

extension KeychainProtocol {
    public func password(forService serviceName: String, account: String) -> String? {
        return passwordData(forService: serviceName, account: account)
            .flatMap { passwordData in String(data: passwordData, encoding: .utf8) }
    }

    @discardableResult
    public func setPassword(_ password: String, forService serviceName: String, account: String) -> Bool {
        guard let passwordData = password.data(using: .utf8) else {
            return false
        }

        return setPasswordData(passwordData, forService: serviceName, account: account)
    }
}

public struct Keychain: KeychainProtocol {
    public init() {
    }

    public func passwordData(forService serviceName: String, account: String) -> Data? {
        return SAMKeychain.passwordData(forService: serviceName, account: account)
    }

    @discardableResult
    public func deletePassword(forService serviceName: String, account: String) -> Bool {
        return SAMKeychain.deletePassword(forService: serviceName, account: account)
    }

    @discardableResult
    public func setPasswordData(_ passwordData: Data, forService serviceName: String, account: String) -> Bool {
        return SAMKeychain.setPasswordData(passwordData, forService: serviceName, account: account)
    }
}
