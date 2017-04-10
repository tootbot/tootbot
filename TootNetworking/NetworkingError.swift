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

import Foundation
import Freddy

public enum NetworkingError: Error {
    case unknown
    case generic(Error)
    case decoding(JSON.Error)
    case request(URLError)

    public init(_ error: Error) {
        if let error = error as? JSON.Error {
            self = .decoding(error)
        } else if let error = error as? URLError {
            self = .request(error)
        } else {
            self = .generic(error)
        }
    }

    public init(_ error: Error?) {
        if let error = error {
            self = NetworkingError(error)
        } else {
            self = .unknown
        }
    }
}
