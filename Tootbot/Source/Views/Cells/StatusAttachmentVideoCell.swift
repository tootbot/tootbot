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
import ReactiveCocoa
import ReactiveSwift
import UIKit

class PlayerView: UIView {
    override class var layerClass: AnyClass {
        return AVPlayerLayer.self
    }

    var loops: Bool {
        return looper != nil
    }

    var playerLayer: AVPlayerLayer {
        return layer as! AVPlayerLayer
    }

    private let disposable = SerialDisposable()

    var looper: AVPlayerLooper?

    var player: AVPlayer? {
        get {
            return playerLayer.player
        }
        set {
            playerLayer.player = newValue
        }
    }

    func play() {
        player?.play()
    }

    func pause() {
        player?.pause()
    }
}

class StatusAttachmentVideoCell: UICollectionViewCell {
    @IBOutlet var playerView: PlayerView!
    @IBOutlet var sensitiveOverlayView: UIVisualEffectView!

    // MARK: - Collection View Cell

    override func awakeFromNib() {
        super.awakeFromNib()

        playerView.playerLayer.videoGravity = AVLayerVideoGravityResizeAspectFill
    }

    override func prepareForReuse() {
        super.prepareForReuse()
    }
}
