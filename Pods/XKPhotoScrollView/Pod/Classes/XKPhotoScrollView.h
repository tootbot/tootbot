//
//  XKPhotoScrollView.h
//  XKPhotoScrollView
//
//  Created by Karl von Randow on 2/08/08.
//  Copyright 2008 XK72 Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "XKPhotoScrollViewViewState.h"
#import "XKPhotoScrollViewDataSource.h"
#import "XKPhotoScrollViewDelegate.h"

typedef NS_ENUM(NSInteger, XKPhotoScrollViewAnimationType) {
	XKPhotoScrollViewAnimationTypeFade,
	XKPhotoScrollViewAnimationTypeSlide
};

typedef NS_ENUM(NSInteger, XKPhotoScrollViewFillMode) {
    XKPhotoScrollViewFillModeAspectFit,
    XKPhotoScrollViewFillModeAspectFill
};

@interface XKPhotoScrollView : UIView

- (void)reloadData;
- (void)setView:(UIView *)view atIndexPath:(NSIndexPath *)indexPath placeholder:(BOOL)placeholder;
- (BOOL)wantsViewAtIndexPath:(NSIndexPath *)indexPath;
- (void)setViewScale:(CGFloat)scale;

@property (weak, nonatomic) IBOutlet id<XKPhotoScrollViewDataSource> dataSource;
@property (weak, nonatomic) IBOutlet id<XKPhotoScrollViewDelegate> delegate;
@property (assign, nonatomic) BOOL bouncesZoom;
@property (assign, nonatomic) BOOL alwaysBounceScroll;

/** The maximum scale factor to apply when zooming, relative to the base scale of the view. Default 3.0, meaning the user can zoom the view up to 3x of the base scale */
@property (assign, nonatomic) CGFloat maximumZoomScale;

/** The minimum scale factor to apply when zooming, relative to the base scale of the view. Default 1.0, meaning the user cannot shrink the view. */
@property (assign, nonatomic) CGFloat minimumZoomScale;

/** The maximum scale factor to apply to views in order to make them fit the available bounds. Default 1.0, meaning don't enlarge a view to make it fit. */
@property (assign, nonatomic) CGFloat maximumBaseScale;

@property (assign, nonatomic) XKPhotoScrollViewFillMode fillMode;

@property (assign, nonatomic) CGFloat minimumDrag;

@property (strong, nonatomic) NSIndexPath *currentIndexPath;
- (void)setCurrentIndexPath:(NSIndexPath *)currentIndexPath animated:(BOOL)animated;

#if TARGET_OS_IOS
@property (nonatomic) UIDeviceOrientation orientation;
- (void)setOrientation:(UIDeviceOrientation)orientation animated:(BOOL)animated;
#endif

@property (readonly, nonatomic) BOOL touching;
@property (assign, nonatomic) CGFloat viewScale;
@property (readonly, nonatomic) CGFloat baseScale;
@property (assign, nonatomic) UIEdgeInsets insets;
@property (assign, nonatomic) UIEdgeInsets baseInsets;
@property (assign, nonatomic) CGPoint viewOffset;
@property (readonly, nonatomic) CGRect viewFrame;
@property (weak, readonly, nonatomic) UIView *currentView;
@property (assign, nonatomic) XKPhotoScrollViewAnimationType animationType;
@property (readonly, copy, nonatomic) XKPhotoScrollViewViewState *currentViewState;
@property (assign, nonatomic) NSTimeInterval minimumLongPressDuration;

@property (readonly, strong, nonatomic) UIView *contentView;
@property (readonly, nonatomic) CGAffineTransform contentViewTransform;

@end

@interface XKPhotoScrollView (ExtraForExperts)

- (void)configureView:(XKPhotoScrollViewViewState *)viewState andInitialise:(BOOL)andInitialise;

@end

@interface NSIndexPath (XKPhotoScrollView)

+ (NSIndexPath *)indexPathForRow:(NSInteger)row inColumn:(NSInteger)column;

- (NSInteger)col;

@end
