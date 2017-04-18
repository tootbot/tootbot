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
import UIKit

class HomeTimelineViewController: UITableViewController {
    let disposable = ScopedDisposable(CompositeDisposable())
    var viewModel: HomeTimelineViewModel!

    // MARK: - View Life Cycle

    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.estimatedRowHeight = 82
        tableView.rowHeight = UITableViewAutomaticDimension
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        disposable += viewModel.fetchNewestToots().startWithCompleted {
            self.tableView.reloadData()
        }
    }
    
    // MARK: - Table View

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.statuses.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let statusViewModel = viewModel.viewModel(at: indexPath)

        let cell = tableView.dequeueReusableCell(withIdentifier: "StatusCell", for: indexPath) as! StatusCell
        cell.contentLabel.text = statusViewModel.content
        cell.displayNameLabel.text = statusViewModel.displayName
        cell.usernameLabel.text = statusViewModel.username
        return cell
    }
}
