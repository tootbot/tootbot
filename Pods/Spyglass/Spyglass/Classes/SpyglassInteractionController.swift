//
//  SpyglassInteractionController.swift
//  Spyglass
//
//  Created by Alexsander Akers on 9/8/2016.
//  Copyright © 2016 Pandamonia LLC. All rights reserved.
//

import UIKit

public class SpyglassInteractionController: NSObject, UIViewControllerInteractiveTransitioning {
    public var animationController: SpyglassAnimationController!
    
    public private(set) var percentComplete = CGFloat(0)
    var shouldFreezeHandler: ((UIView) -> Bool)?
    var isActive = false
    var transitionDuration: TimeInterval = -1
    var transitionContext: UIViewControllerContextTransitioning?
    var _minimumSnapshotViewScale = CGFloat(0.5)
    var _minimumRequiredProgressForDismissal = CGFloat(0.4)
    var hasSnapshotViewAnchorPoint = false
    var isAnimatingSnapshotView = false

    public var maximumDragDistance: CGFloat?
    public var minimumSnapshotViewScale: CGFloat {
        get {
            return _minimumSnapshotViewScale
        }
        set {
            _minimumSnapshotViewScale = min(max(newValue, 0), 1)
        }
    }
    public var minimumRequiredProgressForDismissal: CGFloat {
        get {
            return _minimumRequiredProgressForDismissal
        }
        set {
            _minimumRequiredProgressForDismissal = min(max(newValue, 0), 1)
        }
    }

    public func didPan(with panGestureRecognizer: UIPanGestureRecognizer) {
        guard !(isAnimatingSnapshotView || panGestureRecognizer.state == .cancelled || panGestureRecognizer.state == .failed),
            let animationController = animationController,
            let context = animationController.context,
            let snapshotViewSuperview = context.snapshotView.superview
        else {
            return
        }

        let snapshotView = context.snapshotView
        if !hasSnapshotViewAnchorPoint {
            let anchorPoint = panGestureRecognizer.location(in: snapshotView)
            let bounds = snapshotView.bounds

            let frame = snapshotView.layer.frame
            snapshotView.layer.anchorPoint = CGPoint(x: anchorPoint.x / bounds.size.width, y: anchorPoint.y / bounds.size.height)
            snapshotView.layer.frame = frame

            hasSnapshotViewAnchorPoint = true
        }

        let location = panGestureRecognizer.location(in: snapshotViewSuperview)
        snapshotView.layer.position = location

        let maximumDragDistance = self.maximumDragDistance ?? snapshotViewSuperview.bounds.size.height / 2
        let translation = panGestureRecognizer.translation(in: snapshotViewSuperview)
        let progress = min(abs(translation.y) / maximumDragDistance, 1)
        updateInteractiveTransition(progress)

        let scale = 1 - (1 - minimumSnapshotViewScale) * progress
        snapshotView.transform = CGAffineTransform(scaleX: scale, y: scale)

        if panGestureRecognizer.state == .ended {
            isAnimatingSnapshotView = true

            let frame = snapshotView.layer.frame
            snapshotView.layer.anchorPoint = CGPoint(x: 0.5, y: 0.5)
            snapshotView.layer.frame = frame

            let completion: (Bool) -> Void = { completed in
                let fromVC = self.transitionContext!.viewController(forKey: .from)!
                context.source.sourceTransitionDidEnd(for: animationController.transitionType, viewController: fromVC, userInfo: context.userInfo, completed: completed)

                let toVC = self.transitionContext!.viewController(forKey: .to)!
                context.destination.destinationTransitionDidEnd(for: animationController.transitionType, viewController: toVC, userInfo: context.userInfo, completed: completed)

                self.isAnimatingSnapshotView = false
                snapshotView.removeFromSuperview()
            }

            if progress > minimumRequiredProgressForDismissal {
                animationController.animator.perform(animations: {
                    snapshotView.transform = .identity
                    snapshotView.frame = context.snapshotDestinationRect.frame(relativeTo: snapshotViewSuperview)
                }, completion: { _ in
                    completion(true)
                })

                finishInteractiveTransition()
            } else {
                animationController.animator.perform(animations: {
                    snapshotView.transform = .identity
                    snapshotView.frame = context.snapshotSourceRect.frame(relativeTo: snapshotViewSuperview)
                }, completion: { _ in
                    completion(false)
                })

                cancelInteractiveTransition()
            }
        }
    }

    // MARK: - Interactive Transitioning

    func removeAnimationsRecursively(from layer: CALayer) {
        guard let sublayers = layer.sublayers else {
            return
        }

        for sublayer in sublayers {
            sublayer.removeAllAnimations()
            removeAnimationsRecursively(from: sublayer)
        }
    }

    func updateInteractiveTransition(_ percentComplete: CGFloat) {
        guard isActive else {
            return
        }

        let boundedPercentage = min(max(percentComplete, 0), 1)
        transitionContext?.updateInteractiveTransition(boundedPercentage)
        self.percentComplete = boundedPercentage

        if let transitionContext = transitionContext {
            let pausedTime = transitionDuration * Double(self.percentComplete)
            for subview in transitionContext.containerView.subviews where shouldFreeze(subview) {
                let layer = subview.layer
                layer.speed = 0
                layer.timeOffset = pausedTime
            }
        }
    }

    func shouldFreeze(_ view: UIView) -> Bool {
        if let shouldFreezeHandler = shouldFreezeHandler {
            return shouldFreezeHandler(view)
        } else {
            return true
        }
    }

    @objc func reversePausedAnimation(_ displayLink: CADisplayLink) {
        let percentInterval = displayLink.duration / transitionDuration
        percentComplete -= CGFloat(percentInterval)

        if percentComplete <= 0 {
            percentComplete = 0
            displayLink.invalidate()
        }

        updateInteractiveTransition(percentComplete)

        if percentComplete == 0 {
            isActive = false

            if let transitionContext = transitionContext {
                for subview in transitionContext.containerView.subviews where shouldFreeze(subview) {
                    let layer = subview.layer
                    let animationKeys = layer.animationKeys() ?? []
                    let values = layer.presentation()?.dictionaryWithValues(forKeys: animationKeys)
                    layer.removeAllAnimations()

                    if let values = values, !values.isEmpty {
                        layer.setValuesForKeys(values)
                    }

                    layer.speed = 1
                }
            }
        }
    }

    func cancelInteractiveTransition() {
        guard isActive else {
            return
        }

        transitionContext?.cancelInteractiveTransition()

        let displayLink = CADisplayLink(target: self, selector: #selector(reversePausedAnimation))
        displayLink.add(to: .main, forMode: .defaultRunLoopMode)
    }

    func finishInteractiveTransition() {
        guard isActive else {
            return
        }

        isActive = false

        transitionContext?.finishInteractiveTransition()

        if let transitionContext = transitionContext {
            for subview in transitionContext.containerView.subviews where shouldFreeze(subview) {
                let layer = subview.layer
                let pausedTime = layer.timeOffset
                layer.speed = 1
                layer.timeOffset = 0
                layer.beginTime = 0
                let timeSincePause = layer.convertTime(CACurrentMediaTime(), from: nil) - pausedTime
                layer.beginTime = timeSincePause
            }
        }
    }

    public func startInteractiveTransition(_ transitionContext: UIViewControllerContextTransitioning) {
        isActive = true
        self.transitionContext = transitionContext

        let containerLayer = transitionContext.containerView.layer
        removeAnimationsRecursively(from: containerLayer)
        transitionDuration = animationController.transitionDuration(using: transitionContext)
        animationController.animateTransition(using: transitionContext)
        updateInteractiveTransition(0)
    }
}
