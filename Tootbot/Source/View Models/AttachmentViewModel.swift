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

import Foundation

struct AttachmentViewModel {
    let type: Attachment.MediaType
    let previewURL: URL
    let fullSizeURL: URL
    let textURL: URL?

    init?(attachment: Attachment) {
        guard let previewURL = attachment.previewURL,
            let fullSizeURL = attachment.remoteURL ?? attachment.url,
            let type = attachment.mediaTypeValue
        else {
            return nil
        }

        self.previewURL = previewURL
        self.type = type
        self.fullSizeURL = fullSizeURL
        self.textURL = attachment.textURL
    }

    func matches(link: URL) -> Bool {
        return link == textURL || link == fullSizeURL
    }

    var isImage: Bool {
        switch type {
        case .image:
            return true
        case .gifv, .video:
            return false
        }
    }

    var isVideo: Bool {
        switch type {
        case .image:
            return false
        case .gifv, .video:
            return true
        }
    }
}
