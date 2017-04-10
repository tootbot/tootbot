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
import ReactiveSwift
import Result

public class URLSessionNetworkService: NetworkService {
    let session: URLSession

    public init(sessionConfiguration: URLSessionConfiguration = .default) {
        self.session = URLSession(configuration: sessionConfiguration, delegate: nil, delegateQueue: nil)
    }

    public func perform(_ request: URLRequest) -> SignalProducer<(Data, URLResponse), NetworkingError> {
        return SignalProducer<(Data, URLResponse), NetworkingError> { observer, disposable in
            let task = self.session.dataTask(with: request) { data, response, error in
                if let data = data, let response = response {
                    observer.send(value: (data, response))
                    observer.sendCompleted()
                } else {
                    observer.send(error: NetworkingError(error))
                }
            }

            task.resume()

            disposable += {
                task.cancel()
            }
        }
    }
}
