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

import UIKit
import ReactiveSwift
import ReactiveCocoa
import Result

class StatusCell: UITableViewCell {
    @IBOutlet var avatarImageView: UIImageView!
    @IBOutlet var boosterNameLabel: UILabel!
    @IBOutlet var contentTextView: UITextView!
    @IBOutlet var dateLabel: UILabel!
    @IBOutlet var displayNameLabel: UILabel!

    private var disposable = ScopedDisposable(CompositeDisposable())

    private static let dateFormatter: DateFormatter = {
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .short
        dateFormatter.doesRelativeDateFormatting = true
        dateFormatter.timeStyle = .short
        return dateFormatter
    }()

    var viewModel: StatusCellViewModel? {
        didSet {
            guard let viewModel = viewModel else { return }

            avatarImageView.reactive.image <~ SignalProducer<UIImage?, NoError>(value: nil)
                .concat(viewModel.avatarImage
                    .map(Optional.some)
                    .flatMapError({ _ in SignalProducer(value: nil) })
                )
                .take(until: reactive.prepareForReuse)

            boosterNameLabel.isHidden = !viewModel.isBoosted
            boosterNameLabel.text = viewModel.boostedByName
                .map { name in String(format: NSLocalizedString("%@ boosted", comment: ""), name) }

            contentTextView.attributedText = viewModel.attributedContent

            dateLabel.text = StatusCell.dateFormatter.string(from: viewModel.createdAtDate)

            displayNameLabel.text = viewModel.displayName
        }
    }

    // MARK: - Table View Cell

    override func awakeFromNib() {
        super.awakeFromNib()

        contentTextView.textContainerInset = UIEdgeInsets(top: -4, left: -4, bottom: -4, right: -4)
    }

    override func prepareForReuse() {
        avatarImageView.image = nil
        
        super.prepareForReuse()
    }
}
