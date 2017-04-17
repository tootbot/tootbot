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

import SAMKeychain

protocol KeychainProtocol {
    func allAccounts() -> [(serviceName: String, account: String)]?
    func allServiceNames() -> Set<String>?
    func accounts(forService serviceName: String) -> [String]?

    func passwordData(forService serviceName: String, account: String) -> Data?

    @discardableResult
    func deletePassword(forService serviceName: String, account: String) -> Bool

    @discardableResult
    func setPasswordData(_ passwordData: Data, forService serviceName: String, account: String) -> Bool
}

extension KeychainProtocol {
    func password(forService serviceName: String, account: String) -> String? {
        return passwordData(forService: serviceName, account: account)
            .flatMap { passwordData in String(data: passwordData, encoding: .utf8) }
    }

    @discardableResult
    func setPassword(_ password: String, forService serviceName: String, account: String) -> Bool {
        guard let passwordData = password.data(using: .utf8) else { return false }
        return setPasswordData(passwordData, forService: serviceName, account: account)
    }
}

struct Keychain: KeychainProtocol {
    init() {
    }

    func allAccounts() -> [(serviceName: String, account: String)]? {
        guard let accounts = SAMKeychain.allAccounts() else {
            return nil
        }

        return accounts.flatMap { properties in
            if let serviceName = properties[kSecAttrService as String] as? String, let account = properties[kSecAttrAccount as String] as? String {
                return (serviceName, account)
            } else {
                return nil
            }
        }
    }

    func allServiceNames() -> Set<String>? {
        guard let accounts = allAccounts() else {
            return nil
        }

        return Set(accounts.map({ $0.serviceName }))
    }

    func accounts(forService serviceName: String) -> [String]? {
        guard let accounts = SAMKeychain.accounts(forService: serviceName) else {
            return nil
        }

        return accounts.flatMap { account in account[kSecAttrAccount as String] as? String }
    }

    func passwordData(forService serviceName: String, account: String) -> Data? {
        return SAMKeychain.passwordData(forService: serviceName, account: account)
    }

    @discardableResult
    func deletePassword(forService serviceName: String, account: String) -> Bool {
        return SAMKeychain.deletePassword(forService: serviceName, account: account)
    }

    @discardableResult
    func setPasswordData(_ passwordData: Data, forService serviceName: String, account: String) -> Bool {
        return SAMKeychain.setPasswordData(passwordData, forService: serviceName, account: account)
    }
}
