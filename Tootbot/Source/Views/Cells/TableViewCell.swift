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
import Result
import UIKit

class TableViewCell: UITableViewCell {
    let prepareForReuseSignal: Signal<Void, NoError>
    let prepareForReuseObserver: Observer<Void, NoError>

    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        (self.prepareForReuseSignal, self.prepareForReuseObserver) = Signal.pipe()
        super.init(style: style, reuseIdentifier: reuseIdentifier)
    }

    required init?(coder aDecoder: NSCoder) {
        (self.prepareForReuseSignal, self.prepareForReuseObserver) = Signal.pipe()
        super.init(coder: aDecoder)
    }

    deinit {
        prepareForReuseObserver.sendCompleted()
    }

    override func prepareForReuse() {
        super.prepareForReuse()

        prepareForReuseObserver.send(value: ())
    }
}
