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

import AVFoundation
import Foundation
import ReactiveSwift
import Result
import UIKit

class AttachmentsViewModel {
    class CollectionDataSource: NSObject, UICollectionViewDataSource {
        let attachments: [AttachmentViewModel]
        let isSensitive: Bool

        init(attachments: [AttachmentViewModel], isSensitive: Bool) {
            self.attachments = attachments
            self.isSensitive = isSensitive
        }

        func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
            return attachments.count
        }

        func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
            let attachment = attachments[indexPath.item]
            if attachment.isImage {
                let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ImageCell", for: indexPath) as! StatusAttachmentImageCell
                cell.imageView.pin_setImage(from: attachment.previewURL)
                cell.sensitiveOverlayView.isHidden = !isSensitive
                return cell
            } else {
                let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "VideoCell", for: indexPath) as! StatusAttachmentVideoCell
                cell.sensitiveOverlayView.isHidden = !isSensitive
                cell.playerView.configure(with: attachment.fullSizeURL)
                return cell
            }
        }
    }

    class CollectionDelegate: NSObject, UICollectionViewDelegate {
        let itemTapped: Signal<IndexPath, NoError>

        override init() {
            let (signal, observer) = Signal<IndexPath, NoError>.pipe()
            self.itemTapped = signal

            super.init()
            
            self.reactive.signal(for: #selector(collectionView(_:didSelectItemAt:)))
                .map { $0[1] as! IndexPath }
                .observeValues(observer.send(value:))
        }

        func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
            // No-op, required for `reactive.signal(for:)`
        }

        func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
            if let cell = cell as? StatusAttachmentVideoCell, cell.sensitiveOverlayView.isHidden {
                cell.playerView.play()
            }
        }
    }

    let attachments: [AttachmentViewModel]
    let isSensitive: Bool

    init(attachments: [AttachmentViewModel], isSensitive: Bool) {
        self.attachments = attachments
        self.isSensitive = isSensitive
    }

    private(set) lazy var collectionDataSource: CollectionDataSource = {
        return CollectionDataSource(attachments: self.attachments, isSensitive: self.isSensitive)
    }()

    private(set) lazy var collectionDelegate = CollectionDelegate()
}

