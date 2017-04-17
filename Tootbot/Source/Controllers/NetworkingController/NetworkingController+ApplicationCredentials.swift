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

private let CredentialsService = "._credentials"

extension NetworkingController {
    func applicationCredentials(for instanceURI: String) -> ApplicationCredentials? {
        return keychain.passwordData(forService: CredentialsService, account: instanceURI)
            .flatMap { passwordData -> JSON? in try? JSON(data: passwordData) }
            .flatMap { json in try? ApplicationCredentials(json: json) }
    }

    @discardableResult
    func setApplicationCredentials(_ credentials: ApplicationCredentials, for instanceURI: String) -> Bool {
        guard let passwordData = try? credentials.toJSON().serialize() else {
            return false
        }

        return keychain.setPasswordData(passwordData, forService: CredentialsService, account: instanceURI)
    }

    @discardableResult
    func deleteApplicationCredentials(for instanceURI: String) -> Bool {
        return keychain.deletePassword(forService: CredentialsService, account: instanceURI)
    }
}
