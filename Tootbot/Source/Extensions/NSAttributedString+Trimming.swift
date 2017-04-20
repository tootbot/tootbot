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

import Foundation

extension NSAttributedString {
    public func trimmingCharacters(in set: CharacterSet) -> NSAttributedString {
        let modifiedString = NSMutableAttributedString(attributedString: self)
        modifiedString.trimCharacters(in: set)
        return NSAttributedString(attributedString: modifiedString)
    }
}

extension NSMutableAttributedString {
    public func trimCharacters(in set: CharacterSet) {
        var range = (string as NSString).rangeOfCharacter(from: set, options: .anchored)

        // Trim leading characters from character set.
        while range.location != NSNotFound {
            replaceCharacters(in: range, with: "")
            range = (string as NSString).rangeOfCharacter(from: set, options: .anchored)
        }

        // Trim trailing characters from character set.
        range = (string as NSString).rangeOfCharacter(from: set, options: [.anchored, .backwards])
        while range.location != NSNotFound {
            replaceCharacters(in: range, with: "")
            range = (string as NSString).rangeOfCharacter(from: set, options: [.anchored, .backwards])
        }
    }
}
