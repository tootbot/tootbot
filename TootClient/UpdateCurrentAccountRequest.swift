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

import Freddy
import TootModel
import TootNetworking

public struct UpdateCurrentAccountRequest: Request {
    public typealias ResponseObject = Void

    public var userAccount: UserAccount
    public var displayName: String?
    public var note: String?
    public var avatarData: FormData?
    public var headerData: FormData?

    public init(userAccount: UserAccount, displayName: String?, note: String?, avatarData: FormData?, headerData: FormData?) {
        self.userAccount = userAccount
        self.displayName = displayName
        self.note = note
        self.avatarData = avatarData
        self.headerData = headerData
    }

    func payload() -> Data? {
        var data = [String: JSON]()
        data["display_name"] = displayName?.toJSON()
        data["note"] = note?.toJSON()
        data["avatar"] = avatarData?.base64EncodedString.toJSON()
        data["header"] = headerData?.base64EncodedString.toJSON()

        return try? JSON.dictionary(data).serialize()
    }

    public func build() -> URLRequest {
        var request = URLRequest(url: userAccount.instanceURL.appendingPathComponent("api/v1/accounts/verify_credentials"))
        request.httpBody = payload()
        request.httpMethod = Method.patch.rawValue
        request.setValue("Bearer \(userAccount.token)", forHTTPHeaderField: "Authorization")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        return request
    }
}
