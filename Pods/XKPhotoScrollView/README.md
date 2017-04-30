# XKPhotoScrollView

[![CI Status](http://img.shields.io/travis/Karl von Randow/XKPhotoScrollView.svg?style=flat)](https://travis-ci.org/Karl von Randow/XKPhotoScrollView)
[![Version](https://img.shields.io/cocoapods/v/XKPhotoScrollView.svg?style=flat)](http://cocoapods.org/pods/XKPhotoScrollView)
[![License](https://img.shields.io/cocoapods/l/XKPhotoScrollView.svg?style=flat)](http://cocoapods.org/pods/XKPhotoScrollView)
[![Platform](https://img.shields.io/cocoapods/p/XKPhotoScrollView.svg?style=flat)](http://cocoapods.org/pods/XKPhotoScrollView)

## Usage

The `XKPhotoScrollView` is a `UIView` subclass which provides a swipeable and zoomable photo viewer, modelled on the iOS
Photos app. It uses a delegate and dataSource approach to notifying your code about events, and for obtaining views containing
photos (or whatever you want to present).

The examples project contains a number of examples, showing how you can use the `XKPhotoScrollView` with Interface Builder, or
in code, with or without Auto Layout. The examples also show how it can rotate with your view controller, if you view controller
supports auto rotation. Or you can monitor `UIDevice` for orientation events and tell `XKPhotoScrollView` to change its orientation
internally, so your view controller isn't required to rotate.

To run the example project, clone the repo, and run `pod install` from the Example directory first.

Here is a short example of integrating `XKPhotoScrollView` based on the Manual example:

```objc
- (void)loadView
{
    XKPhotoScrollView *photoScrollView = [XKPhotoScrollView new];
    photoScrollView.dataSource = self;
    photoScrollView.delegate = self;

    self.view = photoScrollView;
}

#pragma mark - XKPhotoScrollView

#pragma mark XKPhotoScrollViewDataSource

- (void)photoScrollView:(XKPhotoScrollView *)photoScrollView requestViewAtIndexPath:(NSIndexPath *)indexPath
{
    UIImage *image = _images[indexPath.col];
    UIImageView *view = [[UIImageView alloc] initWithImage:image];

    [photoScrollView setView:view atIndexPath:indexPath placeholder:NO];
}

- (NSUInteger)photoScrollViewCols:(XKPhotoScrollView *)photoScrollView
{
    return _images.count;
}

#pragma mark XKPhotoScrollViewDelegate

- (void)photoScrollView:(XKPhotoScrollView *)photoScrollView didTapView:(UIView *)view atPoint:(CGPoint)pt atIndexPath:(NSIndexPath *)indexPath
{
    NSInteger col = indexPath.col;
}
```

## Features

* Supports asynchronous delivery of views, including placeholder vs final views
* Minimum and maximum zoom scales and zoom bounce options
* Rich delegate events

## Requirements

## Installation

XKPhotoScrollView is available through [CocoaPods](http://cocoapods.org). To install
it, simply add the following line to your Podfile:

```ruby
pod "XKPhotoScrollView"
```

## Author

Karl von Randow, karl@xk72.com

## License

XKPhotoScrollView is available under the MIT license. See the LICENSE file for more info.
