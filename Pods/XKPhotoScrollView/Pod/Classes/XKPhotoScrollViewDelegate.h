//
//  XKPhotoScrollViewDelegate.h
//  Pods
//
//  Created by Karl von Randow on 17/07/15.
//
//

@class XKPhotoScrollView;

@protocol XKPhotoScrollViewDelegate <NSObject>

@optional

- (void)photoScrollView:(XKPhotoScrollView *)photoScrollView didTapView:(UIView *)view atPoint:(CGPoint)pt atIndexPath:(NSIndexPath *)indexPath;
- (void)photoScrollView:(XKPhotoScrollView *)photoScrollView didLongPressView:(UIView *)view atPoint:(CGPoint)pt atIndexPath:(NSIndexPath *)indexPath;
- (void)photoScrollView:(XKPhotoScrollView *)photoScrollView didTouchView:(UIView *)view withTouches:(NSSet *)touches atIndexPath:(NSIndexPath *)indexPath;
- (void)photoScrollView:(XKPhotoScrollView *)photoScrollView didDragView:(UIView *)view atIndexPath:(NSIndexPath *)indexPath;
- (void)photoScrollView:(XKPhotoScrollView *)photoScrollView didUpdateTransformationForView:(UIView *)view withState:(XKPhotoScrollViewViewState *)state;
- (void)photoScrollView:(XKPhotoScrollView *)photoScrollView didZoomView:(UIView *)view atIndexPath:(NSIndexPath *)indexPath;
- (void)photoScrollView:(XKPhotoScrollView *)photoScrollView didPinchDismissView:(UIView *)view atIndexPath:(NSIndexPath *)indexPath;
#if TARGET_OS_IOS
- (void)photoScrollView:(XKPhotoScrollView *)photoScrollView orientationDidChangeTo:(UIDeviceOrientation)orientation;
#endif
- (void)photoScrollView:(XKPhotoScrollView *)photoScrollView didChangeToIndexPath:(NSIndexPath *)indexPath;
- (void)photoScrollView:(XKPhotoScrollView *)photoScrollView didSetCurrentView:(UIView *)view withState:(XKPhotoScrollViewViewState *)state;
- (void)photoScrollView:(XKPhotoScrollView *)photoScrollView isStabilizing:(UIView *)view;
- (void)photoScrollView:(XKPhotoScrollView *)photoScrollView didStabilizeView:(UIView *)view;

@end
