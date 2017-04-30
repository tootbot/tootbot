//
//  XKPhotoScrollViewDataSource.h
//  Pods
//
//  Created by Karl von Randow on 17/07/15.
//
//

@class XKPhotoScrollView;

@protocol XKPhotoScrollViewDataSource <NSObject>

/** Called when the photo scroll view wants the data source to provide a view for the given index path. */
- (void)photoScrollView:(XKPhotoScrollView *)photoScrollView requestViewAtIndexPath:(NSIndexPath *)indexPath;
- (NSUInteger)photoScrollViewCols:(XKPhotoScrollView *)photoScrollView;

@optional

- (void)photoScrollView:(XKPhotoScrollView *)photoScrollView cancelRequestAtIndexPath:(NSIndexPath *)indexPath;
- (NSUInteger)photoScrollViewRows:(XKPhotoScrollView *)photoScrollView;

@end
