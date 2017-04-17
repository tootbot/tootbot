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

public class NetworkingController {
    let disposable: ScopedDisposable<CompositeDisposable>
    var providers: [Authentication: MastodonProvider]
    var keychain: KeychainProtocol

    typealias LoginResult = (instanceURI: String, result: Result<API.Account, MoyaError>)
    let loginResultSignal: Signal<LoginResult, NoError>
    let loginResultObserver: Observer<LoginResult, NoError>

    public init(keychain: KeychainProtocol = Keychain()) {
        let disposable = ScopedDisposable(CompositeDisposable())
        self.disposable = disposable
        self.keychain = keychain
        self.providers = [:]
        (self.loginResultSignal, self.loginResultObserver) = Signal.pipe(disposable: disposable)
    }

    func plugins(for authentication: Authentication) -> [PluginType] {
        if case .authenticated(let account) = authentication, let token = token(for: account) {
            return [AccessTokenPlugin(token: token)]
        } else {
            return []
        }
    }

    func provider(with authentication: Authentication) -> MastodonProvider {
        if let provider = providers[authentication] {
            return provider
        }

        let baseURL = self.baseURL(for: authentication.instanceURI)!
        let provider = MastodonProvider(baseURL: baseURL, plugins: plugins(for: authentication))
        providers[authentication] = provider
        return provider
    }

    public func request(_ endpoint: MastodonService, authentication: Authentication) -> SignalProducer<Response, MoyaError> {
        return SignalProducer { observer, disposable in
            let provider = self.provider(with: authentication)
            disposable += provider.request(endpoint).start(observer)
        }
    }

    func baseURL(for instanceURI: String) -> URL? {
        var components = URLComponents()
        components.scheme = "https"
        components.host = instanceURI
        return components.url
    }

    public func loginURL(applicationProperties: ApplicationProperties, applicationCredentials: ApplicationCredentials) -> URL? {
        guard let baseURL = baseURL(for: applicationCredentials.instanceURI) else {
            return nil
        }

        let endpoint = MastodonService.oauthAuthorize(clientID: applicationCredentials.oauthCredentials.clientID, redirectURI: applicationProperties.redirectURI, scopes: applicationProperties.scopes, state: applicationCredentials.instanceURI)
        let target = DynamicTarget(baseURL: baseURL, subTarget: endpoint)
        return MoyaProvider<DynamicTarget<MastodonService>>.defaultEndpointMapping(for: target).urlRequest?.url
    }

    public func applicationCredentials(for application: ApplicationProperties, on instanceURI: String) -> SignalProducer<ApplicationCredentials, MoyaError> {
        return SignalProducer.deferred {
            if let credentials = self.applicationCredentials(for: instanceURI) {
                return SignalProducer(value: credentials)
            } else {
                return self.register(application: application, on: instanceURI)
            }
        }
    }

    public func register(application: ApplicationProperties, on instanceURI: String) -> SignalProducer<ApplicationCredentials, MoyaError> {
        let endpoint = MastodonService.registerApp(
            clientName: application.clientName,
            redirectURI: application.redirectURI,
            scopes: application.scopes,
            websiteURL: application.websiteURL
        )

        return request(endpoint, authentication: .unauthenticated(instanceURI: instanceURI))
            .mapFreddyJSONDecoded(OAuthCredentials.self)
            .map { ApplicationCredentials(instanceURI: instanceURI, oauthCredentials: $0) }
            .on(value: { credentials in self.setApplicationCredentials(credentials, for: instanceURI) })
    }

    public func handleLoginCallback(instanceURI: String, authorizationCode: String, redirectURI: String) {
        guard let credentials = applicationCredentials(for: instanceURI) else {
            return
        }

        let noAuthProvider = self.provider(with: .unauthenticated(instanceURI: instanceURI))
        let endpoint = MastodonService.oauthToken(clientID: credentials.oauthCredentials.clientID, clientSecret: credentials.oauthCredentials.clientSecret, authorizationCode: authorizationCode, redirectURI: redirectURI)
        disposable += noAuthProvider.request(endpoint)
            .mapFreddyJSON()
            .flatMap(.latest) { json -> SignalProducer<String, MoyaError> in
                do {
                    let accessToken = try json.getString(at: "access_token")
                    return SignalProducer(value: accessToken)
                } catch {
                    return SignalProducer(error: .underlying(error))
                }
            }
            .flatMap(.latest) { accessToken -> SignalProducer<API.Account, MoyaError> in
                let provider = MastodonProvider(baseURL: noAuthProvider.baseURL, plugins: [AccessTokenPlugin(token: accessToken)])
                return provider.request(.currentUser)
                    .mapFreddyJSONDecoded(API.Account.self)
                    .on(value: { account in
                        let userAccount = UserAccount(instanceURI: instanceURI, username: account.username)
                        self.providers[.authenticated(account: userAccount)] = provider
                        self.setToken(accessToken, for: userAccount)
                    })
            }
            .map(Result.success)
            .flatMapError { error in SignalProducer(value: .failure(error)) }
            .map { result in (instanceURI, result) }
            .start(loginResultObserver)
    }

    func loginResult(for instanceURI: String) -> Signal<API.Account, MoyaError> {
        return loginResultSignal
            .filter { resultInstanceURI, _ in instanceURI == resultInstanceURI }
            .flatMap(.latest) { _, result in SignalProducer(result: result) }
    }
}
