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
    @IBOutlet var contentLabel: UITextView!
    @IBOutlet var avatarImageView: UIImageView!
    @IBOutlet var displayNameLabel: UILabel!
    @IBOutlet var usernameLabel: UILabel!
    @IBOutlet var boostedByStackView: UIStackView!
    @IBOutlet var boosterNameLabel: UILabel!

    private var disposable = ScopedDisposable(CompositeDisposable())

    static let dateFormatter: DateFormatter = {
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .short
        dateFormatter.doesRelativeDateFormatting = true
        dateFormatter.timeStyle = .short
        return dateFormatter
    }()

    override func prepareForReuse() {
        avatarImageView.image = nil
        
        super.prepareForReuse()
    }

    var viewModel: StatusCellViewModel? {
        didSet {
            guard let viewModel = viewModel else { return }

            avatarImageView.reactive.image <~ SignalProducer<UIImage?, NoError>(value: nil)
                .concat(viewModel.avatarImage
                    .map(Optional.some)
                    .flatMapError({ _ in SignalProducer(value: nil) })
                )
                .take(until: reactive.prepareForReuse)

            boostedByStackView.isHidden = !viewModel.isBoosted

            boosterNameLabel.text = viewModel.boostedByName
                .map { name in String(format: NSLocalizedString("%@ boosted", comment: ""), name) }

            contentLabel.reactive.attributedText <~ viewModel.attributedContent
                .take(until: reactive.prepareForReuse)

            displayNameLabel.text = viewModel.displayName

            usernameLabel.text = StatusCell.dateFormatter.string(from: viewModel.createdAtDate)
        }
    }
}
