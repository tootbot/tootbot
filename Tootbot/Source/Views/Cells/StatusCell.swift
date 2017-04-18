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

class StatusCell: TableViewCell {
    @IBOutlet var contentLabel: UITextView!
    @IBOutlet var avatarImageView: UIImageView!
    @IBOutlet var displayNameLabel: UILabel!
    @IBOutlet var usernameLabel: UILabel!
    @IBOutlet weak var boostedByStackView: UIStackView!
    @IBOutlet weak var boosterNameLabel: UILabel!

    private var disposable = ScopedDisposable(CompositeDisposable())

    let dateFormatter: DateFormatter = {
        let dateFormatter = DateFormatter()
        dateFormatter.timeStyle = .short
        dateFormatter.dateStyle = .short
        dateFormatter.doesRelativeDateFormatting = true
        return dateFormatter
    }()

    override func awakeFromNib() {
        avatarImageView.layer.cornerRadius = 4
        avatarImageView.layer.masksToBounds = true
    }

    override func prepareForReuse() {
        avatarImageView.image = nil
        
        super.prepareForReuse()
    }

    var viewModel: StatusCellViewModel? {
        didSet {
            guard let vm = viewModel else { return }


            boostedByStackView.reactive.isHidden <~ vm.boosted.negate()
            boosterNameLabel.reactive.text <~ vm.boostedByName.map {
                guard let name = $0 else {
                    return ""
                }
                return "\(name) boosted"
            }

            displayNameLabel.reactive.text <~ vm.displayName
            usernameLabel.reactive.text <~ vm.createdAtDate.map {
                guard let date = $0 else {
                    return ""
                }
                return self.dateFormatter.string(from: date)
            }

            contentLabel.reactive.attributedText <~ vm.contentSignalProducer.take(until: reactive.prepareForReuse)

            vm.avatarSignalProducer
                .take(until: reactive.prepareForReuse)
                .on(value: {
                    self.avatarImageView?.image = $0
                })
                .start()
        }
    }
}
