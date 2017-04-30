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
import UIKit

class VideoPlayerView: UIView {
    override class var layerClass: AnyClass {
        return AVPlayerLayer.self
    }

    var loops: Bool {
        return looper != nil
    }

    var playerLayer: AVPlayerLayer {
        return layer as! AVPlayerLayer
    }

    var looper: AVPlayerLooper?

    var player: AVPlayer? {
        get {
            return playerLayer.player
        }
        set {
            playerLayer.player = newValue
        }
    }

    var isPlaying: Bool {
        guard let player = player else { return false }
        return player.rate > 0.0
    }

    func play() {
        player?.play()
    }

    func pause() {
        player?.pause()
    }

    func configure(with url: URL, loops: Bool = true) {
        let playerItem = AVPlayerItem(url: url)
        if loops {
            let queuePlayer = AVQueuePlayer()
            looper = AVPlayerLooper(player: queuePlayer, templateItem: playerItem)
            player = queuePlayer
        } else {
            looper = nil
            player = AVPlayer(playerItem: playerItem)
        }
    }
}
