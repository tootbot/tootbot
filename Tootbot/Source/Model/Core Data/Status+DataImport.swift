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

import CoreData
import Foundation

extension Status: APIImportable {
    typealias JSONModel = API.Status

    static var primaryKeyPath: String {
        return #keyPath(statusID)
    }

    func update(with model: API.Status) {
        statusID = Int64(model.id)
        applicationName = model.application?.name
        applicationURL = model.application?.websiteURL
        content = model.content
        createdAt = model.createdAt as NSDate
        isFavorited = model.isFavorited
        isReblogged = model.isReblogged
        isSensitive = model.isSensitive
        spoilerText = model.spoilerText
        updatedAt = NSDate()

        guard let context = managedObjectContext else {
            return
        }

        rebloggedStatus = (model.rebloggedStatus?.value).map { status in Status.upsert(model: status, in: context) }
        user = User.upsert(model: model.account, in: context)

        if let mentions = mentions {
            removeFromMentions(mentions)
        }

        for mentionModel in model.mentions {
            let mention = Mention.upsert(model: mentionModel, in: context)
            addToMentions(mention)
        }
    }
}
