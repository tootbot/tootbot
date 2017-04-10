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

import ReactiveSwift
import TootClient
import TootNetworking
import UIKit

enum Constants {
    static let clientName = "Tootbot"
    static let redirectURI = "tootbot://auth"
    static let scopes: Set<ApplicationScope> = [.read, .write, .follow]
    static let homepageURL = URL(string: "https://github.com/tootbot/tootbot")!
}

class ViewController: UIViewController {
    let api = APIClient(networkService: URLSessionNetworkService())

    override func viewDidLoad() {
        super.viewDidLoad()

        let credentials = OAuthCredentials(id: <#T##String#>, clientID: <#T##String#>, clientSecret: <#T##String#>)
        let account = UserAccount(instanceURL: <#T##URL#>, username: <#T##String#>, token: <#T##String#>)
        let request = TimelineRequest(userAccount: account, timelineType: .home)
        api.perform(request).startWithResult { result in
            print(result)
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}
