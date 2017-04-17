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
import Moya
import ReactiveSwift
import Result

extension Response {
    public func mapFreddyJSON() throws -> JSON {
        do {
            return try JSON(data: data)
        } catch {
            throw MoyaError.underlying(error)
        }
    }

    public func mapFreddyJSONDecoded<Decoded>(_: Decoded.Type = Decoded.self) throws -> Decoded where Decoded: JSONDecodable {
        return try Decoded(json: mapFreddyJSON())
    }

    public func mapFreddyJSONDecodedArray<Decoded>(_: Decoded.Type = Decoded.self) throws -> [Decoded] where Decoded: JSONDecodable {
        let json = try mapFreddyJSON()
        guard case .array(let elements) = json else {
            throw JSON.Error.valueNotConvertible(value: json, to: [Decoded].self)
        }

        return try elements.map { try Decoded(json: $0) }
    }
}

extension SignalProducerProtocol where Value == Response, Error == MoyaError {
    private func wrapMoyaOperation<T, U>(_ operation: @escaping (T) throws -> U) -> (T) -> Result<U, MoyaError> {
        return { value in
            do {
                return .success(try operation(value))
            } catch let error as MoyaError {
                return .failure(error)
            } catch {
                return .failure(.underlying(error))
            }
        }
    }

    public func mapFreddyJSON() -> SignalProducer<JSON, MoyaError> {
        return attemptMap(wrapMoyaOperation({ try $0.mapFreddyJSON() }))
    }

    public func mapFreddyJSONDecoded<Decoded>(_: Decoded.Type = Decoded.self) -> SignalProducer<Decoded, MoyaError> where Decoded: JSONDecodable {
        return attemptMap(wrapMoyaOperation({ try $0.mapFreddyJSONDecoded() }))
    }

    public func mapFreddyJSONDecodedArray<Decoded>(_: Decoded.Type = Decoded.self) -> SignalProducer<[Decoded], MoyaError> where Decoded: JSONDecodable {
        return attemptMap(wrapMoyaOperation({ try $0.mapFreddyJSONDecodedArray() }))
    }
}
