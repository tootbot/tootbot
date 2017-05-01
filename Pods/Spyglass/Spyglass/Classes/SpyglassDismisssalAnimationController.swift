//
//  SpyglassDismissalAnimationController.swift
//  Spyglass
//
//  Created by Alexsander Akers on 9/2/2016.
//  Copyright © 2016 Pandamonia LLC. All rights reserved.
//

import UIKit

public class SpyglassDismissalAnimationController: NSObject, SpyglassAnimationController {
    public var animator: SpyglassAnimator = SpyglassDefaultAnimator(duration: 0.3)
    public var transitionStyle = SpyglassTransitionStyle.navigation
    public let transitionType = SpyglassTransitionType.dismissal

    public private(set) var context: SpyglassAnimationContext?

    // MARK: - Animated Transitioning

    public func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return animator.totalDuration
    }

    public func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        // Extract values from `transitionContext`
        let containerView = transitionContext.containerView

        let fromVC = transitionContext.viewController(forKey: .from)!
        let toVC = transitionContext.viewController(forKey: .to)!

        let initialFromFrame = transitionContext.initialFrame(for: fromVC)
        let finalFromFrame = transitionContext.finalFrame(for: fromVC)

        let initialToFrame = transitionContext.initialFrame(for: toVC)
        let finalToFrame = transitionContext.finalFrame(for: toVC)

        let fromView = transitionContext.view(forKey: .from)
        let toView = transitionContext.view(forKey: .to)

        if let toView = toView {
            switch transitionStyle {
            case .navigation:
                if finalToFrame != .zero {
                    toView.frame = finalToFrame
                }

            case .modalPresentation:
                if initialToFrame != .zero {
                    toView.frame = initialToFrame
                }
            }

            containerView.addSubview(toView)
        }

        if let fromView = fromView {
            switch transitionStyle {
            case .navigation:
                if finalFromFrame != .zero {
                    fromView.frame = finalFromFrame
                }

            case .modalPresentation:
                if initialFromFrame != .zero {
                    fromView.frame = initialFromFrame
                }
            }

            containerView.addSubview(fromView)
        }

        containerView.layoutIfNeeded()
        
        // Extract transition source / destination
        let transitionSource = findTransitionSource(for: fromVC)
        let transitionDestination = findTransitionDestination(for: toVC)

        // Get snapshotView
        let userInfo: SpyglassUserInfo??
        let snapshotView = UIView()
        let snapshotSourceView: UIView?
        let snapshotSourceRect: SpyglassRelativeRect?
        let snapshotDestinationView: UIView?
        let snapshotDestinationRect: SpyglassRelativeRect?

        if let source = transitionSource, transitionDestination != nil {
            let _userInfo = source.userInfo(for: transitionType, from: fromVC, to: toVC)
            snapshotSourceView = source.sourceSnapshotView(for: transitionType, userInfo: _userInfo)
            snapshotSourceRect = source.sourceRect(for: transitionType, userInfo: _userInfo)
            userInfo = .some(_userInfo)
        } else {
            snapshotSourceView = nil
            snapshotSourceRect = nil
            userInfo = nil
        }

        if let destination = transitionDestination, let userInfo = userInfo {
            snapshotDestinationView = destination.destinationSnapshotView(for: transitionType, userInfo: userInfo)
            snapshotDestinationRect = destination.destinationRect(for: transitionType, userInfo: userInfo)
        } else {
            snapshotDestinationView = nil
            snapshotDestinationRect = nil
        }

        if let sourceRect = snapshotSourceRect, snapshotDestinationRect != nil {
            if let sourceView = snapshotSourceView {
                sourceView.alpha = 1
                sourceView.autoresizingMask = [.flexibleHeight, .flexibleWidth]
                sourceView.frame = snapshotView.bounds
                sourceView.translatesAutoresizingMaskIntoConstraints = true
                snapshotView.addSubview(sourceView)
            }

            if let destinationView = snapshotDestinationView {
                destinationView.alpha = 0
                destinationView.autoresizingMask = [.flexibleHeight, .flexibleWidth]
                destinationView.frame = snapshotView.bounds
                destinationView.translatesAutoresizingMaskIntoConstraints = true
                snapshotView.addSubview(destinationView)
            }

            snapshotView.frame = sourceRect.frame(relativeTo: containerView)
            containerView.addSubview(snapshotView)
        }

        if let source = transitionSource, let destination = transitionDestination, let sourceView = snapshotSourceView, let sourceRect = snapshotSourceRect, let destinationView = snapshotDestinationView, let destinationRect = snapshotDestinationRect, let userInfo = userInfo {
            context = SpyglassAnimationContext(source: source, destination: destination, userInfo: userInfo, snapshotView: snapshotView, snapshotSourceView: sourceView, snapshotSourceRect: sourceRect, snapshotDestinationView: destinationView, snapshotDestinationRect: destinationRect)
        } else {
            context = nil
        }

        // Notify source / destination about transition start
        let flatUserInfo: SpyglassUserInfo?
        if let userInfo = userInfo {
            flatUserInfo = userInfo
        } else {
            flatUserInfo = nil
        }

        transitionSource?.sourceTransitionWillBegin(for: transitionType, viewController: fromVC, userInfo: flatUserInfo)
        transitionDestination?.destinationTransitionWillBegin(for: transitionType, viewController: toVC, userInfo: flatUserInfo)

        // Start animation
        let wasInteractive = transitionContext.isInteractive
        let savedTransitionStyle = self.transitionStyle
        animator.perform(animations: {
            if let fromView = fromView {
                fromView.alpha = 0

                if savedTransitionStyle == .modalPresentation && finalFromFrame != .zero {
                    fromView.frame = finalFromFrame
                }
            }

            if savedTransitionStyle == .modalPresentation, let toView = toView, finalToFrame != .zero {
                toView.frame = finalToFrame
            }

            if let sourceView = snapshotSourceView {
                sourceView.alpha = 0
            }

            if let destinationView = snapshotDestinationView {
                destinationView.alpha = 1
            }

            if !wasInteractive, let destinationRect = snapshotDestinationRect {
                snapshotView.frame = destinationRect.frame(relativeTo: containerView)
            }
        }, completion: { _ in
            if !wasInteractive {
                snapshotView.removeFromSuperview()
            }

            let completed = !transitionContext.transitionWasCancelled
            if !wasInteractive {
                transitionSource?.sourceTransitionDidEnd(for: self.transitionType, viewController: fromVC, userInfo: flatUserInfo, completed: completed)
                transitionDestination?.destinationTransitionDidEnd(for: self.transitionType, viewController: toVC, userInfo: flatUserInfo, completed: completed)
            }

            transitionContext.completeTransition(completed)

            self.context = nil
        })
    }
}
