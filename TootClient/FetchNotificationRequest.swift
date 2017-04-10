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

import TootModel
import TootNetworking

public struct FetchNotificationRequest: Request {
    public typealias ResponseObject = TootModel.Notification

    public var instanceURI: String
    public var notificationID: Int

    public init(instanceURI: String, notificationID: Int) {
        self.instanceURI = instanceURI
        self.notificationID = notificationID
    }

    public func build() -> URLRequest {
        return URLRequest(url: URL(string: "\(instanceURI)/api/v1/notifications/\(notificationID)")!)
    }
}
