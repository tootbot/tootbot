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
    @IBOutlet var contentContainerStackView: UIStackView!
    @IBOutlet var dateLabel: UILabel!
    @IBOutlet var displayNameLabel: UILabel!
    @IBOutlet var placeholderContentView: UIView!
    var contentTextView: StatusTextView!

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

        contentTextView = StatusTextView(frame: .zero)
        contentTextView.backgroundColor = .clear
        contentTextView.isEditable = false
        contentTextView.isSelectable = false
        contentTextView.isScrollEnabled = false
        contentTextView.tintColor = .white

        let color = #colorLiteral(red: 0.8791071773, green: 0.9057380557, blue: 0.9279155135, alpha: 1)
        let attributes: [String: Any] = [
            NSBackgroundColorAttributeName: color.withAlphaComponent(0.15),
            NSUnderlineColorAttributeName: color.withAlphaComponent(0.35),
            NSUnderlineStyleAttributeName: NSUnderlineStyle.styleSingle.rawValue,
        ]

        contentTextView.statusTextStorage.overlaidAttributes = [
            HashtagMentionAttributeName: attributes,
            UserMentionAttributeName: attributes,
            NSLinkAttributeName: attributes,
        ]

        contentContainerStackView.addArrangedSubview(contentTextView)
        placeholderContentView.removeFromSuperview()
    }

    override func prepareForReuse() {
        avatarImageView.image = nil
        
        super.prepareForReuse()
    }
}
