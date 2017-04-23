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

import UIKit

class StatusTextStorage: NSTextStorage {
    private let backingStore: NSMutableAttributedString

    var overlaidAttributes = [String: [String: Any]]() {
        willSet {
            beginEditing()
        }
        didSet {
            let fullRange = NSRange(0 ..< length)
            edited(.editedAttributes, range: fullRange, changeInLength: 0)
            endEditing()
        }
    }

    override init() {
        self.backingStore = NSMutableAttributedString(string: "")
        super.init()
    }

    required init?(coder aDecoder: NSCoder) {
        self.backingStore = NSMutableAttributedString(string: "")
        super.init(coder: aDecoder)
    }

    override var string: String {
        return backingStore.string
    }

    override func attributes(at location: Int, effectiveRange range: NSRangePointer?) -> [String: Any] {
        var attributes = backingStore.attributes(at: location, effectiveRange: range)

        let frozenKeys = Array(attributes.keys)
        for attribute in frozenKeys {
            if let overlaid = overlaidAttributes[attribute] {
                for (key, value) in overlaid {
                    attributes[key] = value
                }
            }
        }

        return attributes
    }

    override func replaceCharacters(in range: NSRange, with str: String) {
        beginEditing()
        backingStore.replaceCharacters(in: range, with: str)
        edited(.editedCharacters, range: range, changeInLength: (str as NSString).length - range.length)
        endEditing()
    }

    override func setAttributes(_ attrs: [String: Any]?, range: NSRange) {
        beginEditing()
        backingStore.setAttributes(attrs, range: range)
        edited(.editedAttributes, range: range, changeInLength: 0)
        endEditing()
    }

    func attribute(_ attributeName: String, onAttribute rootAttribute: String) -> Any? {
        return overlaidAttributes[rootAttribute]?[attributeName]
    }

    func setAttribute(_ attributeName: String, value: Any?, onAttribute rootAttribute: String) {
        if overlaidAttributes[rootAttribute] == nil {
            overlaidAttributes[rootAttribute] = [:]
        }

        overlaidAttributes[rootAttribute]![attributeName] = value
    }
}

class StatusLayoutManager: NSLayoutManager {
    private var lastBackgroundDrawOrigin: CGPoint?

    override func drawBackground(forGlyphRange glyphsToShow: NSRange, at origin: CGPoint) {
        lastBackgroundDrawOrigin = origin
        super.drawBackground(forGlyphRange: glyphsToShow, at: origin)
        lastBackgroundDrawOrigin = nil
    }

    override func fillBackgroundRectArray(_ rectArray: UnsafePointer<CGRect>, count rectCount: Int, forCharacterRange charRange: NSRange, color: UIColor) {
        guard let ctx = UIGraphicsGetCurrentContext() else {
            super.fillBackgroundRectArray(rectArray, count: rectCount, forCharacterRange: charRange, color: color)
            return
        }

        let rects = UnsafeBufferPointer(start: rectArray, count: rectCount)
        var clippedRects = [CGRect]()

        let glyphRange = self.glyphRange(forCharacterRange: charRange, actualCharacterRange: nil)
        let textOffset = lastBackgroundDrawOrigin!
        var lineRange = NSRange(location: glyphRange.location, length: 1)
        while NSMaxRange(lineRange) <= NSMaxRange(glyphRange) {
            var lineBounds = lineFragmentUsedRect(forGlyphAt: lineRange.location, effectiveRange: &lineRange)
            lineBounds.origin.x += textOffset.x
            lineBounds.origin.y += textOffset.y

            for rect in rects {
                let intersection = lineBounds.intersection(rect)
                if !intersection.isEmpty {
                    clippedRects.append(intersection)
                }
            }

            lineRange = NSRange(location: NSMaxRange(lineRange), length: 1)
        }

        ctx.saveGState()

        ctx.setAllowsAntialiasing(true)
        ctx.setShouldAntialias(true)
        ctx.fill(clippedRects)

        ctx.restoreGState()
    }
}

class StatusTextView: UITextView {
    init(frame: CGRect) {
        let textContainer = NSTextContainer(size: .zero)
        textContainer.heightTracksTextView = true
        textContainer.lineFragmentPadding = 0
        textContainer.widthTracksTextView = true

        let layoutManager = StatusLayoutManager()
        layoutManager.addTextContainer(textContainer)

        let textStorage = StatusTextStorage()
        textStorage.addLayoutManager(layoutManager)

        super.init(frame: frame, textContainer: textContainer)

        self.textContainerInset = UIEdgeInsets()
    }
    
    required init?(coder aDecoder: NSCoder) {
        // Cannot use init(frame:textContainer:) from a XIB or Storyboard
        fatalError("init(coder:) has not been implemented")
    }

    var statusLayoutManger: StatusLayoutManager {
        return layoutManager as! StatusLayoutManager
    }

    var statusTextStorage: StatusTextStorage {
        return textStorage as! StatusTextStorage
    }

    func attributes(at point: CGPoint, boundingRect: UnsafeMutablePointer<CGRect>? = nil) -> [String: Any]? {
        let relativePoint = CGPoint(x: point.x - contentInset.left, y: point.y - contentInset.top)

        var fraction: CGFloat = -1
        let characterIndex = layoutManager.characterIndex(for: relativePoint, in: textContainer, fractionOfDistanceBetweenInsertionPoints: &fraction)

        if textStorage.length > 0 && (fraction > 0 || characterIndex > 0) && (fraction < 1 || characterIndex < textStorage.length - 1) {
            var effectiveCharacterRange = NSRange(location: NSNotFound, length: 0)
            let attributes = textStorage.attributes(at: characterIndex, effectiveRange: &effectiveCharacterRange)

            if let boundingRect = boundingRect {
                let effectiveGlyphRange = layoutManager.glyphRange(forCharacterRange: effectiveCharacterRange, actualCharacterRange: nil)
                boundingRect.pointee = layoutManager.boundingRect(forGlyphRange: effectiveGlyphRange, in: textContainer)
            }

            return attributes
        }

        return nil
    }
}
