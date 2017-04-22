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
import UIKit

let HashtagMentionAttributeName = "Tootbot.Mention.Hashtag"
let UserMentionAttributeName = "Tootbot.Mention.User"

enum MastodonHTMLElementHandler {
    static func ellipsis(_ tag: HTMLTag, _ contents: NSAttributedString) -> NSAttributedString? {
        if let className = tag.className, className.contains("ellipsis") {
            let mutableContents = NSMutableAttributedString(attributedString: contents)

            let attributes: [String: Any]
            if mutableContents.length > 0 {
                attributes = mutableContents.attributes(at: mutableContents.length - 1, effectiveRange: nil)
            } else {
                attributes = [:]
            }

            let ellipsis = NSAttributedString(string: "…", attributes: attributes)
            mutableContents.append(ellipsis)

            return mutableContents
        }

        return nil
    }

    static func invisible(_ tag: HTMLTag, _ contents: NSAttributedString) -> NSAttributedString? {
        if let className = tag.className, className.contains("invisible") {
            return NSAttributedString(string: "")
        }
        
        return nil
    }

    static func hashtagMention(_ tag: HTMLTag, _ contents: NSAttributedString) -> NSAttributedString? {
        if tag.name == "a", let className = tag.className, className.contains("mention") && className.contains("hashtag"), let href = tag.attributes["href"], let hrefURL = URL(string: href) {
            let hashtag = hrefURL.lastPathComponent
            let mutableContents = NSMutableAttributedString(attributedString: contents)
            mutableContents.addAttribute(HashtagMentionAttributeName, value: hashtag, range: NSRange(0 ..< mutableContents.length))
            return mutableContents
        }
        
        return nil
    }

    static func userMention(_ tag: HTMLTag, _ contents: NSAttributedString) -> NSAttributedString? {
        if let className = tag.className, className.contains("mention"), let href = tag.attributes["href"], let hrefComponents = URLComponents(string: href) {
            let host = hrefComponents.host ?? ""
            let user: String = {
                let atIndex = hrefComponents.path.characters.index(of: "@")!
                let characters = hrefComponents.path.characters[atIndex ..< hrefComponents.path.characters.endIndex]
                return String(characters)
            }()
            let value = user + "@" + host

            let mutableContents = NSMutableAttributedString(attributedString: contents)
            mutableContents.addAttribute(HashtagMentionAttributeName, value: value, range: NSRange(0 ..< mutableContents.length))
            return mutableContents
        }
        
        return nil
    }

    static func hyperlink(_ tag: HTMLTag, _ contents: NSAttributedString) -> NSAttributedString? {
        if let className = tag.className, className.contains("mention"), let href = tag.attributes["href"], let hrefComponents = URLComponents(string: href) {
            let host = hrefComponents.host ?? ""
            let user: String = {
                let atIndex = hrefComponents.path.characters.index(of: "@")!
                let characters = hrefComponents.path.characters[atIndex ..< hrefComponents.path.characters.endIndex]
                return String(characters)
            }()
            let value = user + "@" + host

            let mutableContents = NSMutableAttributedString(attributedString: contents)
            mutableContents.addAttribute(HashtagMentionAttributeName, value: value, range: NSRange(0 ..< mutableContents.length))
            return mutableContents
        }
        
        return nil
    }

    static func newline(_ tag: HTMLTag, _ contents: NSAttributedString) -> NSAttributedString? {
        if tag.name == "p" || tag.name == "br" {
            let mutableContents = NSMutableAttributedString(attributedString: contents)

            let attributes: [String: Any]
            if mutableContents.length > 0 {
                attributes = mutableContents.attributes(at: mutableContents.length - 1, effectiveRange: nil)
            } else {
                attributes = [:]
            }

            let newline = NSAttributedString(string: "\n", attributes: attributes)
            mutableContents.append(newline)
            
            return mutableContents
        }
        
        return nil
    }

    static var common: [NSAttributedStringHTMLTagHandler] {
        return [ellipsis, invisible, hashtagMention, userMention, hyperlink, newline]
    }
}
