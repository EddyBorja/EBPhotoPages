//
//  Created by Eddy Borja.
//  Copyright (c) 2014 Eddy Borja. All rights reserved.
/*
 Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:
 
 The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.
 
 THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
 */



#import <UIKit/UIKit.h>


/*EBPhotoView is a UIScrollView subclass that hold's a photo in an imageview that can be interacted with through various gesture recognizers.*/

@class EBTagPopover;
@interface EBPhotoView : UIScrollView <UIScrollViewDelegate>


@property (strong, readonly) UIImageView *imageView;

//If set to YES, the UIImageView for a photo will use content mode UIViewContentModeCenter if the image is
//smaller than the UIImageView's frame, to prevent the image from scaling up to a pixelated size.
//If set to NO, the content mode will always remain at UIViewContentModeScaleAspectFit
//This property is set to YES by default
@property (assign) BOOL adjustsContentModeForImageSize;

- (UIImage *)image;
- (void)setImage:(UIImage *)image;

- (EBTagPopover *)activeTagPopover;

- (void)bouncePhoto;
- (void)bouncePhotoWithDuration:(NSTimeInterval)duration scaleAmount:(CGFloat)scale;

- (BOOL)canTagPhotoAtNormalizedPoint:(CGPoint)normalizedPoint;

- (void)startNewTagPopover:(EBTagPopover *)popover
        atNormalizedPoint:(CGPoint)normalizedPoint;


- (void)zoomToPoint:(CGPoint)point;

@end
