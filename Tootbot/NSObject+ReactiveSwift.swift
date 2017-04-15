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

import Foundation
import ReactiveSwift

private var LifetimeToken: UInt8 = 0

extension NSObject {
    fileprivate var lifetimeToken: Lifetime.Token {
        if let token = objc_getAssociatedObject(self, &LifetimeToken) as? Lifetime.Token {
            return token
        }

        let token = Lifetime.Token()
        objc_setAssociatedObject(self, &LifetimeToken, token, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        return token
    }

    var lifetime: Lifetime {
        return Lifetime(lifetimeToken)
    }
}
