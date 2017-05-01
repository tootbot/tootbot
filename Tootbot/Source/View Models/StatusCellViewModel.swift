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
    let boostedByName: String?
    let createdAtDate: Date
    let attributedContent: NSAttributedString
    let avatarImageURL: URL
    let isSensitive: Bool
    let attachmentsViewModel: AttachmentsViewModel?

    var hasAttachments: Bool {
        return attachmentsViewModel != nil
    }

    var isBoosted: Bool {
        return boostedByName != nil
    }

    private let status: Status
    private let managedObjectContext: NSManagedObjectContext

    init(status: Status, managedObjectContext: NSManagedObjectContext) {
        self.status = status
        self.managedObjectContext = managedObjectContext

        let displayedStatus = status.rebloggedStatus ?? status
        username = displayedStatus.user!.username!
        displayName = displayedStatus.user!.displayName!
        boostedByName = status.rebloggedStatus != nil ? status.user!.displayName! : nil
        createdAtDate = status.createdAt! as Date
        avatarImageURL = displayedStatus.user!.avatarURL!
        isSensitive = status.isSensitive

        let sortDescriptors = [NSSortDescriptor(key: #keyPath(Attachment.attachmentID), ascending: true)]
        if let attachmentObjects = displayedStatus.attachments?.sortedArray(using: sortDescriptors) as! [Attachment]? {
            let attachments = attachmentObjects.flatMap(AttachmentViewModel.init)
            if !attachments.isEmpty {
                attachmentsViewModel = AttachmentsViewModel(attachments: attachments, isSensitive: self.isSensitive)
            } else {
                attachmentsViewModel = nil
            }
        } else {
            attachmentsViewModel = nil
        }

        if let content = displayedStatus.content, let attributedString = NSMutableAttributedString(htmlString: content, handlers: MastodonHTMLElementHandler.common) {
            attributedString.trimCharacters(in: .whitespacesAndNewlines)

            let fontSize: CGFloat = 17
            let attributes: [String: Any] = [
                NSFontAttributeName: UIFont.systemFont(ofSize: fontSize),
                NSForegroundColorAttributeName: UIColor.white,
            ]
            attributedString.addAttributes(attributes, range: NSRange(0 ..< attributedString.length))

            if let attachmentsViewModel = attachmentsViewModel {
                attributedString.enumerateAttributes(in: NSRange(0 ..< attributedString.length)) { attributes, range, stop in
                    if let link = attributes[NSLinkAttributeName] as? String, let linkURL = URL(string: link) {
                        let contains = attachmentsViewModel.attachments.contains(where: { $0.matches(link: linkURL) })
                        if contains {
                            let nbsp = "\u{00a0}"
                            let replacement = NSMutableAttributedString(string: nbsp + FontAwesome.pictureO.rawValue + nbsp)
                            let fullRange = NSRange(0 ..< replacement.length)
                            replacement.addAttributes(attributes, range: fullRange)
                            replacement.addAttribute(NSFontAttributeName, value: FontAwesome.ofSize(fontSize)!, range: fullRange)
                            attributedString.replaceCharacters(in: range, with: replacement)
                        }
                    }
                }
            }

            attributedContent = attributedString
        } else {
            attributedContent = NSAttributedString()
        }
    }
}
