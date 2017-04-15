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

import Moya
import ReactiveSwift

public class DynamicMoyaProvider<SubTarget>: MoyaProvider<DynamicTarget<SubTarget>> where SubTarget: SubTargetType {
    public var baseURL: URL

    public init(baseURL: URL, endpointClosure: @escaping EndpointClosure = MoyaProvider.defaultEndpointMapping, requestClosure: @escaping RequestClosure = MoyaProvider.defaultRequestMapping, stubClosure: @escaping StubClosure = MoyaProvider.neverStub, manager: Manager = MoyaProvider<DynamicTarget<SubTarget>>.defaultAlamofireManager(), plugins: [PluginType] = [], trackInflights: Bool = false) {
        self.baseURL = baseURL
        super.init(endpointClosure: endpointClosure, requestClosure: requestClosure, stubClosure: stubClosure, manager: manager, plugins: plugins, trackInflights: trackInflights)
    }

    @discardableResult
    public func request(_ target: SubTarget, completion: @escaping Moya.Completion) -> Cancellable {
        return super.request(DynamicTarget(baseURL: baseURL, subTarget: target), completion: completion)
    }

    @discardableResult
    public func request(_ target: SubTarget, queue: DispatchQueue?, progress: Moya.ProgressBlock? = nil, completion: @escaping Moya.Completion) -> Cancellable {
        return super.request(DynamicTarget(baseURL: baseURL, subTarget: target), queue: queue, progress: progress, completion: completion)
    }
}

public class DynamicReactiveSwiftMoyaProvider<SubTarget>: ReactiveSwiftMoyaProvider<DynamicTarget<SubTarget>> where SubTarget: SubTargetType {
    public var baseURL: URL

    public init(baseURL: URL, endpointClosure: @escaping EndpointClosure = MoyaProvider.defaultEndpointMapping, requestClosure: @escaping RequestClosure = MoyaProvider.defaultRequestMapping, stubClosure: @escaping StubClosure = MoyaProvider.neverStub, manager: Manager = ReactiveSwiftMoyaProvider<DynamicTarget<SubTarget>>.defaultAlamofireManager(), plugins: [PluginType] = [], stubScheduler: DateScheduler? = nil, trackInflights: Bool = false) {
        self.baseURL = baseURL
        super.init(endpointClosure: endpointClosure, requestClosure: requestClosure, stubClosure: stubClosure, manager: manager, plugins: plugins, stubScheduler: stubScheduler, trackInflights: trackInflights)
    }

    public func request(_ target: SubTarget) -> SignalProducer<Response, MoyaError> {
        return super.request(DynamicTarget(baseURL: baseURL, subTarget: target))
    }

    public func stubRequest(_ target: SubTarget, request: URLRequest, completion: @escaping Moya.Completion, endpoint: Endpoint<SubTarget>, stubBehavior: Moya.StubBehavior) -> CancellableToken {
        let newEndpoint = unsafeDowncast(endpoint, to: Endpoint<DynamicTarget<SubTarget>>.self)
        return super.stubRequest(DynamicTarget(baseURL: baseURL, subTarget: target), request: request, completion: completion, endpoint: newEndpoint, stubBehavior: stubBehavior)
    }

    public func requestWithProgress(target: SubTarget) -> SignalProducer<ProgressResponse, MoyaError> {
        return super.requestWithProgress(token: DynamicTarget(baseURL: baseURL, subTarget: target))
    }
}
