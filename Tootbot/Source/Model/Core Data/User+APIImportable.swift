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

import CoreData
import Foundation

extension User: APIImportable {
    typealias JSONModel = API.Account

    static func predicate(matching model: API.Account) -> NSPredicate {
        return NSPredicate(format: "%K == %@", #keyPath(userID), model.id as NSNumber)
    }

    func update(with model: API.Account) {
        userID = Int64(model.id)
        username = model.username
        accountName = model.accountName
        displayName = model.displayName
        note = model.note
        websiteURL = model.websiteURL
        avatarURL = model.avatarURL
        headerURL = model.headerURL
        isLocked = model.isLocked
        createdAt = model.createdAt as NSDate
        followersCount = Int64(model.followersCount)
        followingCount = Int64(model.followersCount)
        statusesCount = Int64(model.statusesCount)

        updatedAt = NSDate()
    }
}
