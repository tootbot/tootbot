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

import PINRemoteImage
import ReactiveCocoa
import ReactiveSwift
import Result
import UIKit

enum LinkType {
    case hashtagMention
    case userMention
    case hyperlink
}

class StatusCell: UITableViewCell {
    @IBOutlet var avatarImageView: UIImageView!
    @IBOutlet var boosterNameLabel: UILabel!
    @IBOutlet var contentContainerStackView: UIStackView!
    @IBOutlet var dateLabel: UILabel!
    @IBOutlet var displayNameLabel: UILabel!
    @IBOutlet var placeholderContentView: UIView!
    @IBOutlet var attachmentsCollectionView: UICollectionView!
    var contentTextView: StatusTextView!

    typealias LinkTappedValue = (linkType: LinkType, link: String, boundingRect: CGRect)
    let linkTappedSignal: Signal<LinkTappedValue, NoError>
    private let linkTappedObserver: Observer<LinkTappedValue, NoError>

    private static let dateFormatter: DateFormatter = {
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .short
        dateFormatter.doesRelativeDateFormatting = true
        dateFormatter.timeStyle = .short
        return dateFormatter
    }()

    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        (self.linkTappedSignal, self.linkTappedObserver) = Signal.pipe()
        super.init(style: style, reuseIdentifier: reuseIdentifier)
    }

    required init?(coder aDecoder: NSCoder) {
        (self.linkTappedSignal, self.linkTappedObserver) = Signal.pipe()
        super.init(coder: aDecoder)
    }

    var viewModel: StatusCellViewModel? {
        didSet {
            guard let viewModel = viewModel else { return }

            if viewModel.hasAttachments {
                attachmentsCollectionView.isHidden = false
                attachmentsCollectionView.dataSource = viewModel.attachmentsViewModel.dataSource
                attachmentsCollectionView.delegate = viewModel.attachmentsViewModel.delegate

            } else {
                attachmentsCollectionView.isHidden = true
                attachmentsCollectionView.dataSource = nil
                attachmentsCollectionView.delegate = nil
            }

            avatarImageView.pin_setImage(from: viewModel.avatarImageURL)

            boosterNameLabel.isHidden = !viewModel.isBoosted
            boosterNameLabel.text = viewModel.boostedByName
                .map { name in String(format: NSLocalizedString("%@ boosted", comment: ""), name) }

            contentTextView.attributedText = viewModel.attributedContent

            dateLabel.text = StatusCell.dateFormatter.string(from: viewModel.createdAtDate)

            displayNameLabel.text = viewModel.displayName
        }
    }

    private func configureContentTextView() {
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

        let index = contentContainerStackView.arrangedSubviews.index(of: placeholderContentView)!
        contentContainerStackView.insertArrangedSubview(contentTextView, at: index)
        placeholderContentView.removeFromSuperview()
    }

    private func configureLinkTappedHandler() {
        let tap = UITapGestureRecognizer()
        contentContainerStackView.addGestureRecognizer(tap)

        tap.reactive.stateChanged
            .filter { gesture in gesture.state == .recognized }
            .map { [unowned self] gesture in gesture.location(in: self.contentTextView) }
            .map { [unowned self] location -> ([String: Any], CGRect)? in
                var boundingRect = CGRect()
                if let attributes = self.contentTextView.attributes(at: location, boundingRect: &boundingRect) {
                    return (attributes, boundingRect)
                } else {
                    return nil
                }
            }
            .skipNil()
            .map { (attributes, boundingRect) -> LinkTappedValue? in
                if let hashtag = attributes[HashtagMentionAttributeName] as? String {
                    return (.hashtagMention, hashtag, boundingRect)
                } else if let user = attributes[UserMentionAttributeName] as? String {
                    return (.userMention, user, boundingRect)
                } else if let link = attributes[NSLinkAttributeName] as? String {
                    return (.hyperlink, link, boundingRect)
                } else {
                    return nil
                }
            }
            .skipNil()
            .observe(linkTappedObserver)
    }

    // MARK: - Table View Cell

    override func awakeFromNib() {
        super.awakeFromNib()

        configureContentTextView()
        configureLinkTappedHandler()
    }

    override func prepareForReuse() {
        avatarImageView.pin_cancelImageDownload()
        avatarImageView.image = nil

        super.prepareForReuse()
    }
}
