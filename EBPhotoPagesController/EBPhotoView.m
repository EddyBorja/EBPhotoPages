//
//  Created by Eddy Borja.
//  Copyright (c) 2014 Eddy Borja. All rights reserved.
/*
 Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:
 
 The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.
 
 THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
 */



#import <QuartzCore/QuartzCore.h>
#import <AVFoundation/AVFoundation.h>

#import "EBPhotoView.h"
#import "EBTagPopover.h"
#import "EBPhotoTagProtocol.h"
#import "EBShadedView.h"
#import "EBPhotoPagesNotifications.h"


static NSString *PhotoFrameKeyPath = @"frame";
static NSString *ImageKeyPath = @"image";

@interface EBPhotoView ()
@property (strong, readwrite) UIImageView *imageView;
@end


#pragma mark -
#pragma mark - EBPhotoScrollView

@implementation EBPhotoView

- (id)init
{
    self = [super init];
    if (self) {
        [self initialize];
    }
    return self;
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self initialize];
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self) {
        [self initialize];
    }
    return self;
}

- (void)initialize
{
    [self setDelegate:self];
    [self setShowsVerticalScrollIndicator:NO];
    [self setShowsHorizontalScrollIndicator:NO];
    [self setBouncesZoom:YES];
    [self setDecelerationRate:UIScrollViewDecelerationRateFast];
    
    [self setAlpha:0];
    [self setImageView:[[UIImageView alloc] initWithFrame:self.bounds]];
    [self addSubview:self.imageView];
    [self.imageView setContentMode:UIViewContentModeScaleAspectFit];
    [self setClipsToBounds:NO];
    [self.imageView setClipsToBounds:NO];
    [self setMaximumZoomScale:5.0];
    [self setShowsHorizontalScrollIndicator:NO];
    [self setShowsVerticalScrollIndicator:NO];

    [self setBackgroundColor:[UIColor clearColor]];
    
    [self setAutoresizingMask:UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight];
    
    [self setAdjustsContentModeForImageSize:YES];
    
    [self loadTouchGestureRecognizers];
    
    [self beginObservations];
}

- (void)dealloc
{
    [self stopObservations];
}

#pragma mark - Key Value Observing

- (void)beginObservations
{
    NSAssert(self.imageView, @"Must have an imageview to observe.");
    [self.imageView addObserver:self forKeyPath:PhotoFrameKeyPath options:NSKeyValueObservingOptionNew context:nil];
    
    [self.imageView addObserver:self forKeyPath:ImageKeyPath options:NSKeyValueObservingOptionNew context:nil];
}

- (void)stopObservations
{
    [self.imageView removeObserver:self forKeyPath:PhotoFrameKeyPath];
    [self.imageView removeObserver:self forKeyPath:ImageKeyPath];
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    if(object == self.imageView && [keyPath isEqualToString:PhotoFrameKeyPath]){
        [self repositionTags];
    } else if (object == self.imageView && [keyPath isEqualToString:ImageKeyPath]){
        [self repositionTags];
        if(self.imageView.image){
            [self setAlpha:1];
        } else {
            [self setAlpha:0];
        }
    }
}

#pragma mark - Views Management

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    //This will immediately stop any animations the image view is doing.
    [UIView animateWithDuration:0
                          delay:0
                        options:UIViewAnimationOptionBeginFromCurrentState
                     animations:^{
                         [self.layer setAffineTransform:CGAffineTransformMakeScale(1, 1)];
                     }completion:nil];
    
    if (![self isZoomed] && !CGRectEqualToRect(self.bounds, [self.imageView frame])) {
        [self.imageView setFrame:self.bounds];
        return;
    }
    
    // center the zoom view as it becomes smaller than the size of the screen
    CGSize boundsSize = self.bounds.size;
    CGRect frameToCenter = self.imageView.frame;
    
    
    // center horizontally
    if (frameToCenter.size.width < boundsSize.width)
        frameToCenter.origin.x = (boundsSize.width - frameToCenter.size.width) / 2;
    else
        frameToCenter.origin.x = 0;
    
    // center vertically
    if (frameToCenter.size.height < boundsSize.height)
        frameToCenter.origin.y = (boundsSize.height - frameToCenter.size.height) / 2;
    else
        frameToCenter.origin.y = 0;
    
    self.imageView.frame = frameToCenter;
    
    [self setContentModeForImageSize:self.imageView.image.size];
}

#pragma mark - Loading

- (void)loadTouchGestureRecognizers
{    
    UITapGestureRecognizer *singleTapRecognizer = [[UITapGestureRecognizer alloc]
                                                   initWithTarget:self action:@selector(didRecognizeSingleTap:)];
    [singleTapRecognizer setNumberOfTapsRequired:1];
    [self addGestureRecognizer:singleTapRecognizer];
    
    
    UITapGestureRecognizer *doubleTapGesture = [[UITapGestureRecognizer alloc]
                                                initWithTarget:self
                                                action:@selector(didRecognizeDoubleTap:)];
    [doubleTapGesture setNumberOfTapsRequired:2];
    [self addGestureRecognizer:doubleTapGesture];
    
    UILongPressGestureRecognizer *longPressGesture = [[UILongPressGestureRecognizer alloc]
                                              initWithTarget:self
                                              action:@selector(didRecognizeLongPress:)];
    [self addGestureRecognizer:longPressGesture];
    
    [singleTapRecognizer requireGestureRecognizerToFail:doubleTapGesture];
}

#pragma mark - Event Hooks

- (void)didRecognizeSingleTap:(id)sender
{
    NSAssert([sender isKindOfClass:[UITapGestureRecognizer class]], @"Expected notification from a single tap gesture");
    
    UITapGestureRecognizer *tapGesture = sender;
    
    CGPoint touchPoint = [tapGesture locationInView:self];
    CGPoint normalizedTapLocation = [self normalizedPositionForPoint:touchPoint
                                                             inFrame:[self frameForPhoto]];
    
    NSDictionary *tapInfo = @{@"touchGesture" : sender,
                              @"normalizedTapLocation" : [NSValue valueWithCGPoint:normalizedTapLocation]};
    
    [[NSNotificationCenter defaultCenter] postNotificationName:EBPhotoViewSingleTapNotification
                                                        object:self
                                                      userInfo:tapInfo];
}

- (void)didRecognizeDoubleTap:(id)sender
{
    NSAssert([sender isKindOfClass:[UITapGestureRecognizer class]], @"Expected notification from a double tap gesture");
    
    UITapGestureRecognizer *tap = sender;
    
    CGPoint touchPoint = [tap locationInView:self];
    CGPoint normalizedTapLocation = [self normalizedPositionForPoint:touchPoint
                                                             inFrame:[self frameForPhoto]];
    
    NSDictionary *tapInfo = @{@"touchGesture" : sender,
                              @"normalizedTapLocation" : [NSValue valueWithCGPoint:normalizedTapLocation]};
    [[NSNotificationCenter defaultCenter] postNotificationName:EBPhotoViewDoubleTapNotification
                                                        object:self
                                                      userInfo:tapInfo];
}

- (void)didRecognizeLongPress:(id)sender
{
    NSAssert([sender isKindOfClass:[UILongPressGestureRecognizer class]], @"Expected notification from a long press gesture");
    
    UILongPressGestureRecognizer *longPressGesture = sender;
    if (longPressGesture.state == UIGestureRecognizerStateBegan){
        CGPoint touchPoint = [longPressGesture locationInView:self];
        CGPoint normalizedTapLocation = [self normalizedPositionForPoint:touchPoint
                                                                 inFrame:[self frameForPhoto]];
        
        NSDictionary *tapInfo = @{@"touchGesture" : longPressGesture,
                                  @"normalizedTapLocation" : [NSValue valueWithCGPoint:normalizedTapLocation]};
        
        [[NSNotificationCenter defaultCenter] postNotificationName:EBPhotoViewLongPressNotification
                                                            object:self
                                                          userInfo:tapInfo];
    }
    
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    [super touchesEnded:touches withEvent:event];
    
    if(self.imageView.image == nil){
        return;
    }
    
    for(UITouch *touch in touches){
        if([touch tapCount] == 1){
            CGPoint screenTouchPoint = [touch locationInView:self];
            CGPoint normalizedPoint = [self normalizedPositionForPoint:screenTouchPoint
                                                               inFrame:[self frameForPhoto]];
            NSDictionary *touchInfo =
                @{@"screenTouchPoint": [NSValue valueWithCGPoint:screenTouchPoint],
                  @"normalizedPointInPhoto" : [NSValue valueWithCGPoint:normalizedPoint]};
            
            [[NSNotificationCenter defaultCenter] postNotificationName:EBPhotoViewTouchDidEndNotification
                                                                object:self
                                                              userInfo:touchInfo];
        }
    }
}

#pragma mark - Setters

- (void)setImage:(UIImage *)image
{
    NSAssert(image, @"Image cannot be nil");
    [self.imageView setAlpha:0];
    [UIView animateWithDuration:0.1
                          delay:0
                        options:UIViewAnimationOptionCurveEaseIn
                     animations:^{
                         [self.imageView setAlpha:1];
                     }completion:nil];
    
    [self setContentModeForImageSize:image.size];
    [self.imageView setImage:image];
}

- (void)setContentModeForImageSize:(CGSize)size
{
    if(self.adjustsContentModeForImageSize == NO){
        [self.imageView setContentMode:UIViewContentModeScaleAspectFit];
        return;
    }
    
    UIViewContentMode newContentMode;
    if((size.height < self.imageView.bounds.size.height) &&
       (size.width  < self.imageView.bounds.size.width ) ){
        newContentMode = UIViewContentModeCenter;
    } else {
        newContentMode = UIViewContentModeScaleAspectFit;
    }
    
    if(self.imageView.contentMode != newContentMode){
        [self.imageView setContentMode:newContentMode];
    }
}

#pragma mark - Actions

- (void)startNewTagPopover:(EBTagPopover *)popover atNormalizedPoint:(CGPoint)normalizedPoint
{
    NSAssert(((normalizedPoint.x >= 0.0 && normalizedPoint.x <= 1.0) &&
              (normalizedPoint.y >= 0.0 && normalizedPoint.y <= 1.0)),
             @"Point is outside of photo.");
    
    CGRect photoFrame = [self frameForPhoto];
    
    CGPoint tagLocation =
    CGPointMake(photoFrame.origin.x + (photoFrame.size.width * normalizedPoint.x),
                photoFrame.origin.y + (photoFrame.size.height * normalizedPoint.y));
    
    [popover presentPopoverFromPoint:tagLocation inView:self animated:YES];
    [popover setNormalizedArrowPoint:normalizedPoint];
    [popover becomeFirstResponder];
}


- (void)showSpotlightAtPoint:(CGPoint)spotlightLocation
{
    EBSpotlightShadeView *spotlight = [EBSpotlightShadeView spotlightWithFrame:self.bounds atPoint:spotlightLocation];
    [self addSubview:spotlight];
    [spotlight setNeedsDisplay];
}

- (void)bouncePhoto
{
    [self bouncePhotoWithDuration:0.38 scaleAmount:0.03];
}

- (void)bouncePhotoWithDuration:(NSTimeInterval)duration scaleAmount:(CGFloat)scale
{
    [UIView animateWithDuration:(duration*0.5)
                          delay:0
                        options:UIViewAnimationOptionCurveEaseIn|
     UIViewAnimationOptionAllowUserInteraction|
     UIViewAnimationOptionBeginFromCurrentState
                     animations:^{
                         CGFloat scaleAmount = self.isZoomed ? scale : -scale;
                         [self.layer setAffineTransform:CGAffineTransformMakeScale(1+scaleAmount,
                                                                                   1+scaleAmount)];
                     } completion:^(BOOL finished){
                         [UIView animateWithDuration:(duration*0.5)
                                               delay:0
                                             options:UIViewAnimationOptionCurveEaseOut|
                          UIViewAnimationOptionAllowUserInteraction|
                          UIViewAnimationOptionBeginFromCurrentState
                                          animations:^{
                                              [self.layer setAffineTransform:CGAffineTransformMakeScale(1.0, 1.0)];
                                          }completion:nil];
                     }];
    
}

- (void)zoomToPoint:(CGPoint)point
{
    if(self.imageView.image == nil){
        return;
    }
    
    CGRect zoomRect = self.isZoomed ? [self bounds] : [self zoomRectForScale:self.maximumZoomScale
                                                                  withCenter:point];
    [self zoomToRect:zoomRect animated:YES];
}

- (CGRect)zoomRectForScale:(float)scale withCenter:(CGPoint)center
{
    CGRect zoomRect = self.frame;
    
    zoomRect.size.height /= scale;
    zoomRect.size.width /= scale;
    
    //the origin of a rect is it's top left corner,
    //so subtract half the width and height of the rect from it's center point to get to that x,y
    zoomRect.origin.x = center.x - (zoomRect.size.width  / 2.0);
    zoomRect.origin.y = center.y - (zoomRect.size.height / 2.0);
    
    return zoomRect;
}

- (void)repositionTags
{
    CGRect newPhotoFrame = [self frameForPhoto];
    
    for(EBTagPopover *popover in self.subviews){
        if([popover isKindOfClass:[EBTagPopover class]]){
            [popover repositionInRect:newPhotoFrame];
        }
    }
}

#pragma mark - Getters

- (CGRect)frameForPhoto
{
    if(self.imageView.image == nil){
        return CGRectZero;
    }
    
    CGRect photoDisplayedFrame;
    if(self.imageView.contentMode == UIViewContentModeScaleAspectFit){
        photoDisplayedFrame = AVMakeRectWithAspectRatioInsideRect(self.imageView.image.size, self.imageView.frame);
    } else if(self.imageView.contentMode == UIViewContentModeCenter) {
        CGPoint photoOrigin = CGPointZero;
        photoOrigin.x = (self.imageView.frame.size.width - (self.imageView.image.size.width * self.zoomScale)) * 0.5;
        photoOrigin.y = (self.imageView.frame.size.height - (self.imageView.image.size.height * self.zoomScale)) * 0.5;
        photoDisplayedFrame = CGRectMake(photoOrigin.x,
                                         photoOrigin.y,
                                         self.imageView.image.size.width*self.zoomScale,
                                         self.imageView.image.size.height*self.zoomScale);
    } else {
        NSAssert(0, @"Don't know how to generate frame for photo with current content mode.");
    }

    return photoDisplayedFrame;
}

- (EBTagPopover *)activeTagPopover
{
    for(EBTagPopover *popover in self.subviews){
        if([popover isFirstResponder]){
            return popover;
        }
    }
    
    return nil;
}


- (BOOL)canTagPhotoAtNormalizedPoint:(CGPoint)normalizedPoint
{
    if((normalizedPoint.x >= 0.0 && normalizedPoint.x <= 1.0) &&
       (normalizedPoint.y >= 0.0 && normalizedPoint.y <= 1.0)){
        return YES;
    }
    return NO;
}

- (CGPoint)normalizedPositionForPoint:(CGPoint)point inFrame:(CGRect)frame
{
    point.x -= (frame.origin.x - self.frame.origin.x);
    point.y -= (frame.origin.y - self.frame.origin.y);
    
    CGPoint normalizedPoint = CGPointMake(point.x / frame.size.width,
                                          point.y / frame.size.height);
    
    return normalizedPoint;
}

- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView
{
    return (self.image ? self.imageView : nil);
}

- (UIImage *)image
{
    return self.imageView.image;
}

- (BOOL)isZoomed
{
    return ((self.zoomScale == self.minimumZoomScale) ? NO : YES);
}

#pragma mark - 

//Leave this blank to prevent UITextFields in the EBPhotoView from scrolling the view.
- (void)scrollRectToVisible:(CGRect)rect animated:(BOOL)animated
{}



@end
