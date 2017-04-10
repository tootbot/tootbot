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

public struct AuthorizeFollowRequestRequest: Request {
    public typealias ResponseObject = Void

    public var instanceURI: String
    public var accountID: Int

    public init(instanceURI: String, accountID: Int) {
        self.instanceURI = instanceURI
        self.accountID = accountID
    }

    func payload() -> Data? {
        return try? JSON.dictionary(["id": accountID.toJSON()]).serialize()
    }

    public func build() -> URLRequest {
        var request = URLRequest(url: URL(string: "\(instanceURI)/api/v1/follow_requests/authorize")!)
        request.httpBody = payload()
        request.httpMethod = Method.post.rawValue
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        return request
    }
}
