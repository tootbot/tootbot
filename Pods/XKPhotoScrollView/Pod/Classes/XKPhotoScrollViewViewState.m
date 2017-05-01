//
//  XKPhotoScrollViewViewState.m
//  Pods
//
//  Created by Karl von Randow on 17/07/15.
//
//

#import "XKPhotoScrollViewViewState.h"

@implementation XKPhotoScrollViewViewState

- (id)copyWithZone:(NSZone *)zone {
    XKPhotoScrollViewViewState *copy = [[XKPhotoScrollViewViewState allocWithZone:zone] init];
    copy.view = self.view;
    copy.scale = self.scale;
    copy.baseScale = self.baseScale;
    copy.indexPath = self.indexPath;
    copy.placeholder = self.placeholder;
    return copy;
}

@end
