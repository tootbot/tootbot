//
//  XKPhotoScrollViewAnimatedTransitioning.m
//  XKPhotoScrollView
//
//  Created by Karl von Randow on 17/07/15.
//  Copyright (c) 2015 Karl von Randow. All rights reserved.
//

#import "XKPhotoScrollViewAnimatedTransitioning.h"

#import "XKPhotoScrollView.h"

@interface UIViewController (WithPhotoScrollView)

- (XKPhotoScrollView *)photoScrollView;

@end

@implementation XKPhotoScrollViewAnimatedTransitioning

- (void)animationDidEnd:(id<UIViewControllerContextTransitioning>)transitionContext completionBlock:(XKPhotoScrollViewVoidBlock)completionBlock {
    completionBlock();
}

- (void)animationWillStart:(id<UIViewControllerContextTransitioning>)transitionContext completionBlock:(XKPhotoScrollViewVoidBlock)completionBlock {
    completionBlock();
}

- (void)animateTransition:(id<UIViewControllerContextTransitioning>)transitionContext
{
    [self animationWillStart:transitionContext completionBlock: ^() {
        UIViewController * const to = [transitionContext viewControllerForKey:UITransitionContextToViewControllerKey];
        UIViewController * const from = [transitionContext viewControllerForKey:UITransitionContextFromViewControllerKey];
        
        UIView * const toView = [transitionContext viewForKey:UITransitionContextToViewKey];
        toView.alpha = 0.0;
        toView.frame = [transitionContext finalFrameForViewController:to];
        [transitionContext.containerView addSubview:toView];
        [toView layoutIfNeeded]; /* Force layout so views are positioned correctly for animation calculations below */
        
        UIView * const toTargetView = [self targetViewForViewController:to];
        UIView * const fromTargetView = [self targetViewForViewController:from];
        
        XKPhotoScrollView * const toPhotoScrollView = ([toTargetView isKindOfClass:[XKPhotoScrollView class]] ? (XKPhotoScrollView *)toTargetView : nil);
        XKPhotoScrollView * const fromPhotoScrollView = ([fromTargetView isKindOfClass:[XKPhotoScrollView class]] ? (XKPhotoScrollView *)fromTargetView : nil);
        
        if (fromPhotoScrollView) {
            toPhotoScrollView.currentIndexPath = fromPhotoScrollView.currentIndexPath;
        }
        
        UIImageView * const fromImageView = (UIImageView *)(fromPhotoScrollView ? fromPhotoScrollView.currentView : fromTargetView);
        UIView * const toImageView = toPhotoScrollView ? toPhotoScrollView.currentView : toTargetView;
        
        UIImageView * animatingImageView;
        
        const CGRect fromImageViewFrameInContainerView = [transitionContext.containerView convertRect:fromImageView.frame fromView:fromImageView.superview];
        const CGRect toImageViewFrameInContainerView = [transitionContext.containerView convertRect:toImageView.frame fromView:toImageView.superview];
        if (CGRectIntersectsRect(fromImageViewFrameInContainerView, transitionContext.containerView.bounds) && CGRectIntersectsRect(toImageViewFrameInContainerView, transitionContext.containerView.bounds)) {
            fromImageView.alpha = 0.0;
            
            animatingImageView = [[UIImageView alloc] initWithImage:fromImageView.image];
            animatingImageView.contentMode = fromImageView.contentMode;
            animatingImageView.bounds = fromImageView.bounds;
            animatingImageView.center = [transitionContext.containerView convertPoint:fromImageView.center fromView:fromImageView.superview];
            
            /* Calculate initial transform (rotation) on the animating image view */
            CGAffineTransform containerViewTransform = transitionContext.containerView.transform;
            CGAffineTransform result = from.view.transform; /* We access the view directly as we won't manipulate it at all, we just want to get its transform - the viewForKey returns nil if you're not removing the fromView */
            if (fromPhotoScrollView) {
                result = CGAffineTransformConcat(result, fromPhotoScrollView.contentViewTransform);
            }
            result = CGAffineTransformConcat(result, CGAffineTransformInvert(containerViewTransform));
            result = CGAffineTransformConcat(result, fromImageView.transform);
            animatingImageView.transform = result;
            
            [transitionContext.containerView addSubview:animatingImageView];
            
            toImageView.alpha = 0.0;
        } else {
            animatingImageView = nil;
        }
        
        [UIView animateWithDuration:[self transitionDuration:transitionContext] animations:^{
            CGPoint animationDestination = [transitionContext.containerView convertPoint:toImageView.center fromView:toImageView.superview];
            animatingImageView.center = animationDestination;
            
            /* Transform scaling calculation: compare the bounds, then transform to match the bounds, then apply to toImageView's transform. */
            CGFloat scale = MIN(toImageView.bounds.size.width / animatingImageView.bounds.size.width, toImageView.bounds.size.height / animatingImageView.bounds.size.height);
            
            CGAffineTransform transform = toView.transform;
            transform = CGAffineTransformConcat(transform, toImageView.transform);
            if (toPhotoScrollView) {
                transform = CGAffineTransformConcat(transform, toPhotoScrollView.contentViewTransform);
            }
            transform = CGAffineTransformConcat(transform, CGAffineTransformMakeScale(scale, scale));
            animatingImageView.transform = transform;
            
            toView.alpha = 1.0;
        } completion:^(BOOL finished) {
            fromImageView.alpha = 1.0;
            toImageView.alpha = 1.0;
            [animatingImageView removeFromSuperview];
            
            [self animationDidEnd:transitionContext completionBlock: ^() {
                [transitionContext completeTransition:finished];
            }];
        }];
    }];
}

- (void)animationEnded:(BOOL)transitionCompleted
{
    
}

- (NSTimeInterval)transitionDuration:(id<UIViewControllerContextTransitioning>)transitionContext
{
    return 0.5;
}

- (UIView *)targetViewForViewController:(UIViewController *)viewController
{
    if ([viewController respondsToSelector:@selector(photoScrollView)]) {
        return (XKPhotoScrollView *) [viewController performSelector:@selector(photoScrollView)];
    } else if ([viewController isKindOfClass:[UINavigationController class]]) {
        return [self targetViewForViewController:((UINavigationController *)viewController).topViewController];
    } else {
        return viewController.view;
    }
}

@end
