#ifdef __OBJC__
#import <UIKit/UIKit.h>
#else
#ifndef FOUNDATION_EXPORT
#if defined(__cplusplus)
#define FOUNDATION_EXPORT extern "C"
#else
#define FOUNDATION_EXPORT extern
#endif
#endif
#endif

#import "XKPhotoScrollView.h"
#import "XKPhotoScrollViewAnimatedTransitioning.h"
#import "XKPhotoScrollViewDataSource.h"
#import "XKPhotoScrollViewDelegate.h"
#import "XKPhotoScrollViewViewState.h"

FOUNDATION_EXPORT double XKPhotoScrollViewVersionNumber;
FOUNDATION_EXPORT const unsigned char XKPhotoScrollViewVersionString[];

