//
//  Created by Eddy Borja.
//  Copyright (c) 2014 Eddy Borja. All rights reserved.
/*
 Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:
 
 The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.
 
 THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
 */


#import "EBShadedView.h"

#pragma mark - EBShadowView

static NSString *FrameKeyPath = @"frame";

@implementation EBShadedView
+(instancetype)upperGradientWithFrame:(CGRect)frame
{
    EBGradientView *gradientView = [[EBGradientView alloc] initWithFrame:frame];
    [gradientView setReversed:YES];
    return gradientView;
}

+(instancetype)lowerGradientWithFrame:(CGRect)frame
{
    EBShadedView *gradientView = [[EBGradientView alloc] initWithFrame:frame];
    return gradientView;
}

+(instancetype)screenDimmerWithFrame:(CGRect)frame
{
    EBShadedView *screenDimmerView = [[EBDimmedScreenView alloc] initWithFrame:frame];
    return screenDimmerView;
}

+ (instancetype)spotlightWithFrame:(CGRect)frame atPoint:(CGPoint)spotlightCenter
{
    EBShadedView *spotlightView = [[EBSpotlightShadeView alloc] initWithFrame:frame
                                                             spotlightAtPoint:spotlightCenter];
    return spotlightView;
}

- (id)init
{
    self = [super init];
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

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self initialize];
    }
    return self;
}

- (void)initialize
{
    [self setNeedsDisplay];
    [self beginObservations];
}

- (void)dealloc
{
    [self stopObservations];
}

#pragma mark - Key Value observing

- (void)beginObservations
{
    [self addObserver:self forKeyPath:FrameKeyPath options:NSKeyValueObservingOptionNew context:nil];
}

- (void)stopObservations
{
    [self removeObserver:self forKeyPath:FrameKeyPath];
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    if(object == self && [keyPath isEqualToString:FrameKeyPath]){
        [self setNeedsDisplay];
    }
}
@end


@implementation EBGradientView
- (void)initialize
{
    [super initialize];
    [self setUserInteractionEnabled:NO];
    [self setOpaque:NO];
    [self setGradientRef:[self blackFadeGradientRefReversed:NO]];
}

- (void)setReversed:(BOOL)reverse{
    [self setGradientRef:[self blackFadeGradientRefReversed:reverse]];
}

- (void)setGradientRef:(CGGradientRef)gradientRef
{
    CGGradientRelease(_gradientRef);
    _gradientRef = nil;
    
    _gradientRef = gradientRef;
    CGGradientRetain(_gradientRef);
    
    [self setNeedsDisplay];
}

- (void)drawRect:(CGRect)rect
{
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    CGContextSaveGState(context);
    CGContextDrawLinearGradient(context,
                                self.gradientRef,
                                CGPointMake(0, CGRectGetMinY(self.bounds)),
                                CGPointMake(0, CGRectGetMaxY(self.bounds)),
                                0);
    
    CGContextRestoreGState(context);
}

- (CGGradientRef)blackFadeGradientRefReversed:(BOOL)reverse
{
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    
    
    CGGradientRef gradient;
    if(reverse){
        gradient = CGGradientCreateWithColorComponents
        (colorSpace,
         (const CGFloat[8]){0.0f, 0.0f, 0.0f, 0.9f,
             0.0f, 0.0f, 0.0f, 0.0f},
         (const CGFloat[2]){0.0f,1.0f},
         2);
    } else {
        gradient = CGGradientCreateWithColorComponents
        (colorSpace,
         (const CGFloat[8]){0.0f, 0.0f, 0.0f, 0.0f,
             0.0f, 0.0f, 0.0f, 0.9f},
         (const CGFloat[2]){0.0f,1.0f},
         2);
    }
    
    
    
    CGColorSpaceRelease(colorSpace);
    
    return gradient;
}

- (void)dealloc
{
    CGGradientRelease(self.gradientRef);
    [self setGradientRef:nil];
}
@end

@implementation EBDimmedScreenView
- (void)initialize
{
    [super initialize];
    [self setUserInteractionEnabled:NO];
    [self setAutoresizingMask:UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight];
    [self setOpaque:NO];
    [self setBackgroundColor:[UIColor blackColor]];
}
@end

@implementation EBSpotlightShadeView
- (id)initWithFrame:(CGRect)frame spotlightAtPoint:(CGPoint)spotlightCenter
{
    self = [super initWithFrame:frame];
    if (self) {
        [self setSpotlightCenter:spotlightCenter];
        [self initialize];
        [self setOpaque:NO];
    }
    return self;
}

- (void)initialize
{
    [super initialize];
    [self setSpotlightBlackOpacity:0.65];
    [self setSpotlightStartRadius:0];
    [self setSpotlightEndRadius:160];
}

- (void)drawRect:(CGRect)rect
{
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    size_t locationsCount = 2;
    CGFloat locations[2] = {0.0f, 1.0f,};
    CGFloat colors[12] = {0.0f,0.0f,0.0f,0.0f,
        0.0f,0.0f,0.0f, self.spotlightBlackOpacity};
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    CGGradientRef gradient = CGGradientCreateWithColorComponents(colorSpace, colors, locations, locationsCount);
    
    float radius = self.spotlightEndRadius;
    float startRadius = self.spotlightStartRadius;
    CGContextDrawRadialGradient (context, gradient, self.spotlightCenter, startRadius, self.spotlightCenter, radius, kCGGradientDrawsAfterEndLocation);
    
    CGColorSpaceRelease(colorSpace);
    CGGradientRelease(gradient);
}




@end