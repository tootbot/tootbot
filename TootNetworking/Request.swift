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
import Result

public protocol Request {
    associatedtype ResponseDeserializer: Deserializer = JSONDeserializer
    associatedtype ResponseObject

    func build() -> URLRequest
    func parse(_ response: ResponseDeserializer.Output) -> Result<ResponseObject, NetworkingError>
}

public extension Request where ResponseDeserializer.Output == JSON, ResponseObject: JSONDecodable {
    func parse(_ response: JSON) -> Result<ResponseObject, NetworkingError> {
        do {
            return try .success(ResponseObject(json: response))
        } catch {
            return .failure(NetworkingError(error))
        }
    }
}

public extension Request where ResponseDeserializer.Output == JSON, ResponseObject: RangeReplaceableCollection, ResponseObject.Iterator.Element: JSONDecodable {
    func parse(_ response: JSON) -> Result<ResponseObject, NetworkingError> {
        do {
            guard case .array(let elements) = response else {
                throw JSON.Error.valueNotConvertible(value: response, to: ResponseObject.self)
            }

            var collection = ResponseObject()
            collection.reserveCapacity(numericCast(elements.count))

            for jsonFragment in elements {
                let parsedElement = try ResponseObject.Iterator.Element(json: jsonFragment)
                collection.append(parsedElement)
            }

            return .success(collection)
        } catch {
            return .failure(NetworkingError(error))
        }
    }
}

public extension Request where ResponseObject == Void {
    func parse(_: ResponseDeserializer.Output) -> Result<ResponseObject, NetworkingError> {
        return .success()
    }
}
