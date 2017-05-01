//
//  XKPhotoScrollViewAnimatedTransitioning.h
//  XKPhotoScrollView
//
//  Created by Karl von Randow on 17/07/15.
//  Copyright (c) 2015 Karl von Randow. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef void (^XKPhotoScrollViewVoidBlock)();

@interface XKPhotoScrollViewAnimatedTransitioning : NSObject <UIViewControllerAnimatedTransitioning>

/** These animation hooks can be overridden to create extra animations on your view controllers.
 The completionBlock must be called otherwise the animation cannot complete.
 */
- (void)animationDidEnd:(nonnull id<UIViewControllerContextTransitioning>)transitionContext completionBlock:(nonnull XKPhotoScrollViewVoidBlock)completionBlock;
- (void)animationWillStart:(nonnull id<UIViewControllerContextTransitioning>)transitionContext completionBlock:(nonnull XKPhotoScrollViewVoidBlock)completionBlock;

/** Returns the view to use as the target view of the transition for the given
 view controller. This view should either be an XKPhotoScrollView or a UIImageView.
 */
- (nullable UIView *)targetViewForViewController:(nonnull UIViewController *)viewController;

@end

