//
//  XKPhotoScrollViewViewState.h
//  Pods
//
//  Created by Karl von Randow on 17/07/15.
//
//

#import <Foundation/Foundation.h>

@interface XKPhotoScrollViewViewState : NSObject <NSCopying>

@property (nonatomic, strong) UIView *view;

/** The current scale of the view, relative to the baseScale. This applies when the view is zoomed by the user. */
@property (nonatomic, assign) CGFloat scale;

/** The baseScale of the view is the scale applied to the view in order to fit it to the photo scroll view. It is governed by the photo scroll view's maximumBaseScale. */
@property (nonatomic, assign) CGFloat baseScale;

/** The indexPath that this view state represents */
@property (nonatomic, strong) NSIndexPath *indexPath;

/** Whether this view is a placeholder, that is expected to be replaced by the real view later. */
@property (nonatomic, assign) BOOL placeholder;

@end
