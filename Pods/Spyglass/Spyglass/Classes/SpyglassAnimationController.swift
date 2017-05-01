//
//  SpyglassAnimationController.swift
//  Spyglass
//
//  Created by Alexsander Akers on 9/8/2016.
//  Copyright © 2016 Pandamonia LLC. All rights reserved.
//

import UIKit

public protocol SpyglassAnimationController: UIViewControllerAnimatedTransitioning {
    var animator: SpyglassAnimator { get }
    var context: SpyglassAnimationContext? { get }
    var transitionStyle: SpyglassTransitionStyle { get }
    var transitionType: SpyglassTransitionType { get }
}
