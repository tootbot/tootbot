//
//  SpyglassAnimationContext.swift
//  Spyglass
//
//  Created by Alexsander Akers on 9/11/2016.
//  Copyright © 2016 Pandamonia LLC. All rights reserved.
//

import UIKit

public struct SpyglassAnimationContext {
    public var source: SpyglassTransitionSource
    public var destination: SpyglassTransitionDestination
    public var userInfo: SpyglassUserInfo?
    public var snapshotView: UIView
    public var snapshotSourceView: UIView
    public var snapshotSourceRect: SpyglassRelativeRect
    public var snapshotDestinationView: UIView
    public var snapshotDestinationRect: SpyglassRelativeRect

    public init(source: SpyglassTransitionSource, destination: SpyglassTransitionDestination, userInfo: SpyglassUserInfo?, snapshotView: UIView, snapshotSourceView: UIView, snapshotSourceRect: SpyglassRelativeRect, snapshotDestinationView: UIView, snapshotDestinationRect: SpyglassRelativeRect) {
        self.source = source
        self.destination = destination
        self.userInfo = userInfo
        self.snapshotView = snapshotView
        self.snapshotSourceView = snapshotSourceView
        self.snapshotSourceRect = snapshotSourceRect
        self.snapshotDestinationView = snapshotDestinationView
        self.snapshotDestinationRect = snapshotDestinationRect
    }
}
