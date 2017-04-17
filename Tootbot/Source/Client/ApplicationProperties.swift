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

import Foundation

public struct ApplicationProperties {
    public var clientName: String
    public var redirectURI: String
    public var scopes: Set<ApplicationScope>
    public var websiteURL: URL?

    public init(clientName: String, redirectURI: String, scopes: Set<ApplicationScope>, websiteURL: URL?) {
        self.clientName = clientName
        self.redirectURI = redirectURI
        self.scopes = scopes
        self.websiteURL = websiteURL
    }
}

extension Bundle {
    var applicationProperties: ApplicationProperties? {
        return applicationProperties(forKey: "ClientProperties")
    }

    func applicationProperties(forKey key: String) -> ApplicationProperties? {
        guard let info = infoDictionary,
            let properties = info[key] as? [String: Any],
            let clientName = properties["ClientName"] as? String,
            let redirectURI = properties["RedirectURI"] as? String,
            let scopeString = properties["Scopes"] as? String
        else {
            return nil
        }

        let websiteURL: URL?
        if let website = info["Website"] as? String {
            websiteURL = URL(string: website)
        } else {
            websiteURL = nil
        }

        let scopeStrings = scopeString.characters.split(separator: " ").map(String.init)
        let scopes = Set(scopeStrings.flatMap({ ApplicationScope(rawValue: $0) }))
        return ApplicationProperties(clientName: clientName, redirectURI: redirectURI, scopes: scopes, websiteURL: websiteURL)
    }
}
