//
//  Spyglass.swift
//  Spyglass
//
//  Created by Alexsander Akers on 9/2/2016.
//  Copyright © 2016 Pandamonia LLC. All rights reserved.
//

import UIKit

public class Spyglass: NSObject, UINavigationControllerDelegate, UIViewControllerTransitioningDelegate {
    // only necessary for modal presentation
    let gestureRecognizersByAnimationController = NSMapTable<NSObject, UIPanGestureRecognizer>.weakToStrongObjects()
    let gestureRecognizers = NSMapTable<UIViewController, UIPanGestureRecognizer>.weakToStrongObjects()
    let interactionControllers = NSMapTable<UIPanGestureRecognizer, SpyglassInteractionController>.weakToStrongObjects()
    let isNavigationTransition = NSMapTable<UIPanGestureRecognizer, NSNumber>.weakToStrongObjects()

    func recognizedPanGesture(_ panGesture: UIPanGestureRecognizer) {
        if panGesture.state == .began {
            let interactionController = SpyglassInteractionController()
            interactionControllers.setObject(interactionController, forKey: panGesture)

            if let isNavigation = isNavigationTransition.object(forKey: panGesture), isNavigation.boolValue {
                let navigationController: UINavigationController = {
                    for key in gestureRecognizers.keyEnumerator() {
                        let viewController = key as! UIViewController
                        if gestureRecognizers.object(forKey: viewController) === panGesture {
                            return viewController as! UINavigationController
                        }
                    }

                    fatalError()
                }()

                navigationController.popViewController(animated: true)
            } else {
                let viewController: UIViewController = {
                    for key in gestureRecognizers.keyEnumerator() {
                        let viewController = key as! UIViewController
                        if gestureRecognizers.object(forKey: viewController) === panGesture {
                            return viewController
                        }
                    }

                    fatalError()
                }()

                viewController.dismiss(animated: true)
            }
        } else {
            if let interactionController = interactionControllers.object(forKey: panGesture) {
                interactionController.didPan(with: panGesture)
            }

            if panGesture.state == .cancelled || panGesture.state == .ended {
                interactionControllers.removeObject(forKey: panGesture)
            }
        }
    }

    func ensurePanGesture(on viewController: UIViewController, isNavigation: Bool) {
        guard gestureRecognizers.object(forKey: viewController) == nil else {
            return
        }

        let gestureRecognizer = UIPanGestureRecognizer(target: self, action: #selector(recognizedPanGesture))
        viewController.view.addGestureRecognizer(gestureRecognizer)
        gestureRecognizers.setObject(gestureRecognizer, forKey: viewController)
        isNavigationTransition.setObject(NSNumber(value: isNavigation), forKey: gestureRecognizer)
    }

    // MARK: - Navigation Controller

    public func navigationController(_ navigationController: UINavigationController, animationControllerFor operation: UINavigationControllerOperation, from fromVC: UIViewController, to toVC: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        switch operation {
        case .push:
            ensurePanGesture(on: navigationController, isNavigation: true)

            let animationController = SpyglassPresentationAnimationController()
            animationController.transitionStyle = .navigation
            return animationController

        case .pop:
            let animationController = SpyglassDismissalAnimationController()
            animationController.transitionStyle = .navigation
            return animationController

        default:
            return nil
        }
    }

    public func navigationController(_ navigationController: UINavigationController, interactionControllerFor animationController: UIViewControllerAnimatedTransitioning) -> UIViewControllerInteractiveTransitioning? {
        if let panGesture = gestureRecognizers.object(forKey: navigationController), let interactionController = interactionControllers.object(forKey: panGesture), let animationController = animationController as? SpyglassAnimationController, animationController.transitionType == SpyglassTransitionType.dismissal {
            interactionController.animationController = animationController
            interactionController.shouldFreezeHandler = { view in view != animationController.context?.snapshotView }
            return interactionController
        } else {
            return nil
        }
    }

    // MARK: - View Controller

    public func animationController(forPresented presented: UIViewController, presenting: UIViewController, source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        ensurePanGesture(on: presented, isNavigation: false)

        let animationController = SpyglassPresentationAnimationController()
        animationController.transitionStyle = .modalPresentation
        return animationController
    }

    public func animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        let animationController = SpyglassDismissalAnimationController()
        animationController.transitionStyle = .modalPresentation

        if let gestureRecognizer = gestureRecognizers.object(forKey: dismissed) {
            gestureRecognizersByAnimationController.setObject(gestureRecognizer, forKey: animationController)
        }

        return animationController
    }

    public func interactionControllerForPresentation(using animator: UIViewControllerAnimatedTransitioning) -> UIViewControllerInteractiveTransitioning? {
        return nil
    }

    public func interactionControllerForDismissal(using animator: UIViewControllerAnimatedTransitioning) -> UIViewControllerInteractiveTransitioning? {
        let animatorObject = animator as! NSObject
        if let panGesture = gestureRecognizersByAnimationController.object(forKey: animatorObject), let interactionController = interactionControllers.object(forKey: panGesture), let animationController = animator as? SpyglassAnimationController, animationController.transitionType == SpyglassTransitionType.dismissal {
            interactionController.animationController = animationController
            interactionController.shouldFreezeHandler = { view in view != animationController.context?.snapshotView }
            return interactionController
        } else {
            return nil
        }
    }
}
