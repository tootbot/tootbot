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
import ReactiveSwift
import Result
import TootModel
import TootNetworking

public class APIClient {
    let networkService: NetworkService

    public init(networkService: NetworkService) {
        self.networkService = networkService
    }

    public func perform(_ urlRequest: URLRequest) -> SignalProducer<(Data, URLResponse), NetworkingError> {
        return networkService.perform(urlRequest)
    }

    public func perform<R>(_ request: R) -> SignalProducer<R.ResponseObject, NetworkingError> where R: Request, R.ResponseDeserializer.Output == JSON {
        return perform(request.build()).flatMap(.merge) { data, response -> SignalProducer<R.ResponseObject, NetworkingError> in
            let result = Result(value: data)
                .flatMap(R.ResponseDeserializer.deserialize)
                .flatMap { json in
                    request.parse(json).mapError { error in
                        if case .decoding = error, let serverError = try? ServerError(json: json) {
                            return .server(serverError.message)
                        } else {
                            return error
                        }
                    }
                }

            return SignalProducer(result: result)
        }
    }

    public func perform<R>(_ request: R) -> SignalProducer<R.ResponseObject, NetworkingError> where R: Request {
        return perform(request.build()).flatMap(.merge) { data, response -> SignalProducer<R.ResponseObject, NetworkingError> in
            let result = Result(value: data)
                .flatMap(R.ResponseDeserializer.deserialize)
                .flatMap(request.parse)
            return SignalProducer(result: result)
        }
    }
}
