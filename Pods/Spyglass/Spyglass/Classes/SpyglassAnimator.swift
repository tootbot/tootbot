//
//  SpyglassAnimator.swift
//  Spyglass
//
//  Created by Alexsander Akers on 9/6/2016.
//  Copyright © 2016 Pandamonia LLC. All rights reserved.
//

import UIKit

public protocol SpyglassAnimator {
    var totalDuration: TimeInterval { get }

    func perform(animations: @escaping () -> Void, completion: ((Bool) -> Void)?)
}

public struct SpyglassDefaultAnimator: SpyglassAnimator {
    public var duration: TimeInterval
    public var delay: TimeInterval
    public var options: UIViewAnimationOptions

    public init(duration: TimeInterval, delay: TimeInterval = 0, options: UIViewAnimationOptions = []) {
        self.duration = duration
        self.delay = delay
        self.options = options
    }

    public var totalDuration: TimeInterval {
        return delay + duration
    }

    public func perform(animations: @escaping () -> Void, completion: ((Bool) -> Void)?) {
        UIView.animate(withDuration: duration, delay: delay, options: options, animations: animations, completion: completion)
    }
}

public struct SpyglassSpringAnimator: SpyglassAnimator {
    public var duration: TimeInterval
    public var delay: TimeInterval
    public var springDamping: CGFloat
    public var initialSpringVelocity: CGFloat
    public var options: UIViewAnimationOptions

    public init(duration: TimeInterval, delay: TimeInterval = 0, springDamping: CGFloat, initialSpringVelocity: CGFloat, options: UIViewAnimationOptions = []) {
        self.duration = duration
        self.delay = delay
        self.springDamping = springDamping
        self.initialSpringVelocity = initialSpringVelocity
        self.options = options
    }

    public var totalDuration: TimeInterval {
        return delay + duration
    }

    public func perform(animations: @escaping () -> Void, completion: ((Bool) -> Void)?) {
        UIView.animate(withDuration: duration, delay: delay, usingSpringWithDamping: springDamping, initialSpringVelocity: initialSpringVelocity, options: options, animations: animations, completion: completion)
    }
}
