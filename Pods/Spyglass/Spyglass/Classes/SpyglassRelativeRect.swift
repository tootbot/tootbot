//
//  SpyglassRelativeRect.swift
//  Spyglass
//
//  Created by Alexsander Akers on 9/3/2016.
//  Copyright © 2016 Pandamonia LLC. All rights reserved.
//

import UIKit

public struct SpyglassRelativeRect {
    // In window coordinates
    fileprivate let rect: CGRect

    public init(rect: CGRect, relativeTo view: UIView) {
        assert(view.window != nil)
        self.rect = view.convert(rect, to: nil)
    }

    public init(view: UIView) {
        assert(view.window != nil)
        self.rect = view.convert(view.bounds, to: nil)
    }

    public func frame(relativeTo view: UIView) -> CGRect {
        assert(view.window != nil)
        return view.convert(rect, from: nil)
    }
}

extension SpyglassRelativeRect: Equatable {
    public static func ==(lhs: SpyglassRelativeRect, rhs: SpyglassRelativeRect) -> Bool {
        return lhs.rect == rhs.rect
    }
}
