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

    var isBoosted: Bool {
        return boostedByName != nil
    }
    
    let attributedContent: SignalProducer<NSAttributedString, NoError>
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

        attributedContent = SignalProducer { observer, disposable in
            guard let data = displayedStatus.content?.data(using: .utf8) else {
                observer.sendCompleted()
                return
            }

            let options: [String : Any] = [
                NSCharacterEncodingDocumentAttribute: String.Encoding.utf8.rawValue as NSNumber,
                NSDocumentTypeDocumentAttribute: NSHTMLTextDocumentType,
            ]

            guard let attributedString = try? NSMutableAttributedString(data: data, options: options, documentAttributes: nil) else {
                observer.sendCompleted()
                return
            }

            let range = NSRange(0 ..< (attributedString.string as NSString).length)
            attributedString.addAttributes([
                NSFontAttributeName: UIFont.systemFont(ofSize: 17),
                NSForegroundColorAttributeName: UIColor.white
            ], range: range)

            attributedString.trimCharacters(in: .whitespacesAndNewlines)

            observer.send(value: attributedString)
            observer.sendCompleted()
        }.replayLazily(upTo: 1)
    }
}
