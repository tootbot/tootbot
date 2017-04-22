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

import Alamofire
import CoreData
import ReactiveCocoa
import ReactiveSwift
import Result

class StatusCellViewModel {
    let displayName: String?
    let username: String?
    let attachments: [UIImage?] = []
    let boostedByName: String?
    let createdAtDate: Date
    let hasAttachments: Bool = false
    let attributedContent: NSAttributedString

    var isBoosted: Bool {
        return boostedByName != nil
    }

    let avatarImage: SignalProducer<UIImage, ImageCacheController.Error>

    private let status: Status
    private let managedObjectContext: NSManagedObjectContext
    private let imageCacheController: ImageCacheController

    init(status: Status, managedObjectContext: NSManagedObjectContext, imageCacheController: ImageCacheController) {
        self.status = status
        self.managedObjectContext = managedObjectContext
        self.imageCacheController = imageCacheController

        let displayedStatus = status.rebloggedStatus ?? status
        username = displayedStatus.user!.username!
        displayName = displayedStatus.user!.displayName!
        boostedByName = status.rebloggedStatus != nil ? status.user!.displayName! : nil
        createdAtDate = status.createdAt! as Date

        avatarImage = imageCacheController
            .fetch(url: displayedStatus.user!.avatarURL!)

        if let content = displayedStatus.content, let attributedString = NSMutableAttributedString(htmlString: content, handlers: MastodonHTMLElementHandler.common) {
            attributedString.trimCharacters(in: .whitespacesAndNewlines)

            let attributes: [String: Any] = [
                NSFontAttributeName: UIFont.systemFont(ofSize: 17),
                NSForegroundColorAttributeName: UIColor.white,
            ]
            attributedString.addAttributes(attributes, range: NSRange(0 ..< (attributedString.string as NSString).length))

            attributedContent = attributedString
        } else {
            attributedContent = NSAttributedString()
        }
    }
}
