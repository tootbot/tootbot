//
//  SpyglassTransitionDestination.swift
//  Spyglass
//
//  Created by Alexsander Akers on 9/3/2016.
//  Copyright © 2016 Pandamonia LLC. All rights reserved.
//

import UIKit

public protocol SpyglassTransitionDestinationProvider {
    var transitionDestination: SpyglassTransitionDestination? { get }
}

public extension SpyglassTransitionDestinationProvider where Self: SpyglassTransitionDestination {
    var transitionDestination: SpyglassTransitionDestination? {
        return self
    }
}

public protocol SpyglassTransitionDestination {
    func destinationRect(for transitionType: SpyglassTransitionType, userInfo: SpyglassUserInfo?) -> SpyglassRelativeRect
    func destinationSnapshotView(for transitionType: SpyglassTransitionType, userInfo: SpyglassUserInfo?) -> UIView

    /* optional */ func destinationTransitionWillBegin(for transitionType: SpyglassTransitionType, viewController: UIViewController, userInfo: SpyglassUserInfo?)
    /* optional */ func destinationTransitionDidEnd(for transitionType: SpyglassTransitionType, viewController: UIViewController, userInfo: SpyglassUserInfo?, completed: Bool)
}

public extension SpyglassTransitionDestination {
    func destinationTransitionWillBegin(for transitionType: SpyglassTransitionType, viewController: UIViewController, userInfo: SpyglassUserInfo?) {
    }

    func destinationTransitionDidEnd(for transitionType: SpyglassTransitionType, viewController: UIViewController, userInfo: SpyglassUserInfo?, completed: Bool) {
    }
}
