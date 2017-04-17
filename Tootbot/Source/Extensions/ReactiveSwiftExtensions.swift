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

import ReactiveSwift

extension SignalProtocol {
    func ignoreValues() -> Signal<Void, Error> {
        return signal
            .filter { _ in false }
            .map { _ in () }
    }
}

extension SignalProducerProtocol {
    static func deferred(_ function: @escaping () -> SignalProducer<Value, Error>) -> Self {
        return Self { observer, disposable in disposable += function().start(observer) }
    }

    init(attempt: @escaping () throws -> Value, transformError: @escaping (Swift.Error) -> Error = { $0 as! Error }) {
        self.init { observer, disposable in
            do {
                let value = try attempt()
                observer.send(value: value)
                observer.sendCompleted()
            } catch let error as Error {
                observer.send(error: error)
            } catch {
                observer.send(error: transformError(error))
            }
        }
    }

    func ignoreValues() -> SignalProducer<Void, Error> {
        return lift { signal in signal.ignoreValues() }
    }
}
