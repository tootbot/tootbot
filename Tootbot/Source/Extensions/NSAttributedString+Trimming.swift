//
//  NSAttributedString+Trimming.swift
//  Tootbot
//
//  Created by Michał Kałużny on 18/04/2017.
//
//

import Foundation

extension NSAttributedString {
    public func attributedStringByTrimmingCharacterSet(_ characterSet: CharacterSet) -> NSAttributedString {
        let modifiedString = NSMutableAttributedString(attributedString: self)
        modifiedString.trimCharactersInSet(characterSet)
        return NSAttributedString(attributedString: modifiedString)
    }
}

extension NSMutableAttributedString {
    public func trimCharactersInSet(_ characterSet: CharacterSet) {
        var range = (string as NSString).rangeOfCharacter(from: characterSet)

        // Trim leading characters from character set.
        while range.length != 0 && range.location == 0 {
            replaceCharacters(in: range, with: "")
            range = (string as NSString).rangeOfCharacter(from: characterSet)
        }

        // Trim trailing characters from character set.
        range = (string as NSString).rangeOfCharacter(from: characterSet, options: .backwards)
        while range.length != 0 && NSMaxRange(range) == length {
            replaceCharacters(in: range, with: "")
            range = (string as NSString).rangeOfCharacter(from: characterSet, options: .backwards)
        }
    }
}
