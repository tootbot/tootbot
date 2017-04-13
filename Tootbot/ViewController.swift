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
import Result
import SafariServices
import UIKit

let UserDefaultsAccountsKey = "Accounts"

class ViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    var accounts = [UserAccount]()
    var applicationProperties: ApplicationProperties!
    let disposable = ScopedDisposable(CompositeDisposable())
    var networking: Networking!

    @IBOutlet var tableView: UITableView!

    func loadAccounts() {
        let accountStrings = UserDefaults.standard.stringArray(forKey: UserDefaultsAccountsKey) ?? []
        accounts = accountStrings.flatMap { string in UserAccount(string) }
    }

    func saveAccounts() {
        let accountStrings = accounts.map { String(describing: $0) }
        UserDefaults.standard.set(accountStrings, forKey: UserDefaultsAccountsKey)
    }

    func presentLogIn(for instanceURI: String) {
        let properties = applicationProperties!
        disposable += networking.applicationCredentials(for: properties, on: instanceURI)
            .flatMap(.latest) { credentials -> SignalProducer<URL, MoyaError> in
                if let loginURL = self.networking.loginURL(applicationProperties: properties, applicationCredentials: credentials) {
                    return SignalProducer(value: loginURL)
                } else {
                    return SignalProducer(error: .underlying(SimpleError(message: "Could not generate login URL")))
                }
            }
            .on(value: { authURL in
                let safari = SFSafariViewController(url: authURL)
                self.present(safari, animated: true)
            })
            .flatMap(.latest) { _ -> Signal<UserAccount, MoyaError> in
                return self.networking.loginResultSignal
                    .filter { resultInstanceURI, _ in instanceURI == resultInstanceURI }
                    .flatMap(.latest) { _, result in SignalProducer(result: result) }
            }
            .take(first: 1)
            .on(failed: { error in
                print(error)
            }, terminated: {
                self.dismiss(animated: true)
            }, value: { account in
                self.tableView.beginUpdates()
                self.tableView.insertRows(at: [[0, self.accounts.count]], with: .automatic)
                self.accounts.append(account)
                self.tableView.endUpdates()

                self.saveAccounts()
            })
            .start()
    }

    // MARK: - Configuration

    func configureNavigationItem() {
        navigationItem.leftBarButtonItem = editButtonItem
    }

    // MARK: - View Life Cycle

    override func viewDidLoad() {
        super.viewDidLoad()

        loadAccounts()
        configureNavigationItem()
    }

    // MARK: - Actions

    @IBAction func addAccount(_ sender: AnyObject?) {
        let defaultInstance = "mastodon.social"

        let alert = UIAlertController(title: "Which instance?", message: "Enter the URL of the instance.", preferredStyle: .alert)
        alert.addTextField { textField in textField.placeholder = defaultInstance }

        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        alert.addAction(UIAlertAction(title: "Log In", style: .default, handler: { _ in
            let instanceURI: String
            if let textField = alert.textFields?.first, let text = textField.text?.trimmingCharacters(in: .whitespaces), !text.isEmpty {
                instanceURI = text
            } else {
                instanceURI = defaultInstance
            }

            self.presentLogIn(for: instanceURI)
        }))

        present(alert, animated: true)
    }
    
    // MARK: - Table View

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return accounts.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "AccountCell", for: indexPath)

        let account = accounts[indexPath.row]
        cell.textLabel!.text = "@" + account.username
        cell.detailTextLabel!.text = account.instanceURI

        return cell
    }
}
