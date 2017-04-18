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
import Alamofire
import ReactiveSwift
import ReactiveCocoa
import Result

class StatusCellViewModel {
    let displayName = MutableProperty<String?>(nil)
    let userName = MutableProperty<String?>(nil)
    let attachments = MutableProperty<[UIImage?]>([])
    let boosted = MutableProperty<Bool>(false)
    let boostedByName = MutableProperty<String?>(nil)
    let createdAtDate = MutableProperty<Date?>(nil)
    let hasAttachments = MutableProperty<Bool>(false)

    let contentSignalProducer: SignalProducer<NSAttributedString, NoError>
    let avatarSignalProducer: SignalProducer<UIImage, ImageCacheController.Error>

    private let status: Status
    private let imageCacheController = ImageCacheController()
    private let managedObjectContext: NSManagedObjectContext

    init(status: Status, managedObjectContext: NSManagedObjectContext) {
        self.status = status
        self.managedObjectContext = managedObjectContext

        boosted.value = status.rebloggedStatus != nil

        let displayedStatus = status.rebloggedStatus ?? status
        userName.value = displayedStatus.user?.username
        displayName.value = displayedStatus.user?.displayName
        boostedByName.value = status.user?.displayName
        createdAtDate.value = status.createdAt as Date?

        avatarSignalProducer = imageCacheController
            .fetch(url: (displayedStatus.user?.avatarURL)!)

        contentSignalProducer = SignalProducer { observer, disposable in
            guard let data = displayedStatus.content?.data(using: .utf16) else {
                observer.sendCompleted()
                return
            }

            if disposable.isDisposed {
                observer.sendInterrupted()
                return
            }

            let options = [NSDocumentTypeDocumentAttribute: NSHTMLTextDocumentType]
            guard let attributedString = try? NSMutableAttributedString(data: data, options: options, documentAttributes: nil) else {
                observer.sendCompleted()
                return
            }

            let range = NSMakeRange(0, attributedString.string.utf16.count)
            attributedString.addAttributes([NSFontAttributeName: UIFont.systemFont(ofSize: 17),
                                            NSForegroundColorAttributeName: UIColor.white],
                                           range: range)

            observer.send(value: attributedString.attributedStringByTrimmingCharacterSet(.whitespacesAndNewlines))
            observer.sendCompleted()
        }
    }
}
