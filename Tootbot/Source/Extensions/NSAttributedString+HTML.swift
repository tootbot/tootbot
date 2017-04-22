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

import Axt
import Foundation

struct HTMLTag {
    let name: String
    let attributes: [String: String]

    var className: [String]? {
        guard let className = attributes["class"] else {
            return nil
        }

        return className.characters.split(separator: " ").map { String($0) }
    }
}

private class HTMLParserDelegate: NSObject, AXHTMLParserDelegate {
    var attributedString: NSAttributedString?
    let handlers: [NSAttributedStringHTMLTagHandler]

    private var workingAttributedString: NSMutableAttributedString?
    private var workingElements = [(startIndex: Int, tag: HTMLTag)]()

    init(handlers: [NSAttributedStringHTMLTagHandler] = []) {
        self.handlers = handlers
    }

    func parserDidStartDocument(_ parser: AXHTMLParser) {
        workingAttributedString = NSMutableAttributedString()
    }

    func parserDidEndDocument(_ parser: AXHTMLParser) {
        attributedString = workingAttributedString
        workingAttributedString = nil
    }

    func parser(_ parser: AXHTMLParser, didStartElement elementName: String, attributes attributeDict: [AnyHashable: Any]) {
        let attributes = attributeDict as! [String: String]
        let startIndex = workingAttributedString!.length
        workingElements.append((startIndex, HTMLTag(name: elementName, attributes: attributes)))
    }

    func parser(_ parser: AXHTMLParser, didEndElement elementName: String) {
        let (startIndex, tag) = workingElements.removeLast()

        let subrange = NSRange(startIndex ..< workingAttributedString!.length)
        let replacementString: NSAttributedString = {
            let contents = workingAttributedString!.attributedSubstring(from: subrange)
            for handler in handlers {
                if let replacementString = handler(tag, contents) {
                    return replacementString
                }
            }

            return contents
        }()


        workingAttributedString!.replaceCharacters(in: subrange, with: replacementString)
    }

    func parser(_ parser: AXHTMLParser, foundCharacters string: String) {
        workingAttributedString!.append(NSAttributedString(string: string))
    }

    func parser(_ parser: AXHTMLParser, parseErrorOccurred parseError: Error) {
    }
}

typealias NSAttributedStringHTMLTagHandler = (_ tag: HTMLTag, _ contents: NSAttributedString) -> NSAttributedString?

extension NSAttributedString {
    convenience init?(htmlString: String, handlers: [NSAttributedStringHTMLTagHandler] = []) {
        guard let data = htmlString.data(using: .utf8) else {
            return nil
        }

        let stream = InputStream(data: data)
        guard let parser = AXHTMLParser(stream: stream) else {
            return nil
        }

        let delegate = HTMLParserDelegate(handlers: handlers)
        parser.delegate = delegate

        guard parser.parse(), let attributedString = delegate.attributedString else {
            return nil
        }

        self.init(attributedString: attributedString)
    }
}
