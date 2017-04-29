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

private class StatusCellAttachmentsDataSource: NSObject, UICollectionViewDataSource {
    let attachments: [(preview: URL, fullSize: URL, type: Attachment.MediaType)]
    let isSensitive: Bool

    init(attachments: [(preview: URL, fullSize: URL, type: Attachment.MediaType)], isSensitive: Bool) {
        self.attachments = attachments
        self.isSensitive = isSensitive
    }

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return attachments.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let attachment = attachments[indexPath.item]
        switch attachment.type {
        case .image:
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ImageCell", for: indexPath) as! StatusAttachmentImageCell
            cell.imageView.pin_setImage(from: attachment.preview)
            cell.sensitiveOverlayView.isHidden = !isSensitive
            return cell

        case .gifv, .video:
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "VideoCell", for: indexPath) as! StatusAttachmentVideoCell
            cell.sensitiveOverlayView.isHidden = !isSensitive

            let player = AVQueuePlayer()
            cell.playerView.player = player
            cell.playerView.looper = AVPlayerLooper(player: player, templateItem: AVPlayerItem(url: attachment.fullSize))

            return cell
        }
    }
}

private class StatusCellAttachmentsDelegate: NSObject, UICollectionViewDelegate {
    let itemTappedSignal: Signal<IndexPath, NoError>
    private let itemTappedObserver: Observer<IndexPath, NoError>

    override init() {
        (self.itemTappedSignal, self.itemTappedObserver) = Signal.pipe()
    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        itemTappedObserver.send(value: indexPath)
    }

    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        if let cell = cell as? StatusAttachmentVideoCell, cell.sensitiveOverlayView.isHidden {
            cell.playerView.play()
        }
    }
}

class StatusCellAttachmentsViewModel {
    let attachments: [(preview: URL, fullSize: URL, type: Attachment.MediaType)]
    let isSensitive: Bool
    private var prefetchingUUIDs = [IndexPath: UUID]()

    init(attachments: [(preview: URL, fullSize: URL, type: Attachment.MediaType)], isSensitive: Bool) {
        self.attachments = attachments
        self.isSensitive = isSensitive
    }

    private(set) lazy var dataSource: UICollectionViewDataSource = {
        return StatusCellAttachmentsDataSource(attachments: self.attachments, isSensitive: self.isSensitive)
    }()

    private lazy var _delegate: StatusCellAttachmentsDelegate = {
        return StatusCellAttachmentsDelegate()
    }()

    var delegate: UICollectionViewDelegate {
        return _delegate
    }

    var itemTapped: Signal<IndexPath, NoError> {
        return _delegate.itemTappedSignal
    }
}
