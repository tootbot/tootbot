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

import ReactiveCocoa
import ReactiveSwift
import SafariServices
import UIKit

class TimelineViewController: UITableViewController, UIViewControllerPreviewingDelegate {
    let disposable = ScopedDisposable(CompositeDisposable())
    var viewModel: TimelineViewModel!

    func configureTableView() {
        tableView.estimatedRowHeight = 82
        tableView.rowHeight = UITableViewAutomaticDimension

        viewModel.statusesUpdated.observeValues { [unowned self] in
            self.tableView.reloadData()
        }
    }

    func configureRefreshControl() {
        refreshControl!.beginRefreshing()
        refreshControl!.reactive.refresh = CocoaAction(viewModel.fetchNewestTootsAction, { _ in () })
    }

    func reloadData() {
        disposable += viewModel.fetchNewestTootsAction.apply().start()
    }

    func safariViewController(url: URL) -> SFSafariViewController {
        let safariViewController = SFSafariViewController(url: url)
        safariViewController.preferredBarTintColor = #colorLiteral(red: 0.1921568627, green: 0.2078431373, blue: 0.262745098, alpha: 1)
        safariViewController.preferredControlTintColor = .white
        return safariViewController
    }

    func handleLinkTapped(type: LinkType, link: String, sourceRect: CGRect, sourceView: UIView) {
        let viewController: UIViewController

        switch type {
        case .hashtagMention:
            // TODO: Hashtag mention timeline
            // https://github.com/tootbot/tootbot/issues/41
            return
        case .userMention:
            // TODO: User profile screen
            // https://github.com/tootbot/tootbot/issues/40
            return
        case .hyperlink:
            guard let url = URL(string: link) else { return }
            viewController = safariViewController(url: url)
        }

        show(viewController, sender: sourceView)
    }

    // MARK: - View Life Cycle

    override func show(_ vc: UIViewController, sender: Any?) {
        if vc is SFSafariViewController {
            present(vc, animated: true)
        } else {
            navigationController!.pushViewController(vc, animated: true)
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        configureTableView()
        configureRefreshControl()

        registerForPreviewing(with: self, sourceView: tableView)
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        reloadData()
    }
    
    // MARK: - Table View

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.numberOfStatuses
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "StatusCell", for: indexPath) as! StatusCell
        cell.viewModel = viewModel.viewModel(at: indexPath)

        _ = cell.linkTappedSignal
            .map { type, link, boundingRect in (type, link, boundingRect, cell.contentTextView) }
            .take(until: cell.reactive.prepareForReuse)
            .observeValues(handleLinkTapped)

        return cell
    }

    // MARK: - Status Bar

    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }

    // MARK: - 3D Touch

    func previewingContext(_ previewingContext: UIViewControllerPreviewing, viewControllerForLocation location: CGPoint) -> UIViewController? {
        guard previewingContext.sourceView == tableView,
            let indexPath = tableView.indexPathForRow(at: location),
            let cell = tableView.cellForRow(at: indexPath) as? StatusCell
        else {
            return nil
        }

        let relativePoint = tableView.convert(location, to: cell.contentTextView)
        var boundingRect = CGRect()
        guard let attributes = cell.contentTextView.attributes(at: relativePoint, boundingRect: &boundingRect) else {
            return nil
        }

        previewingContext.sourceRect = cell.contentTextView.convert(boundingRect, to: tableView)

        if let string = attributes[NSLinkAttributeName] as? String, let linkURL = URL(string: string) {
            return safariViewController(url: linkURL)
        } else {
            return nil
        }
    }

    func previewingContext(_ previewingContext: UIViewControllerPreviewing, commit viewControllerToCommit: UIViewController) {
        show(viewControllerToCommit, sender: nil)
    }
}
