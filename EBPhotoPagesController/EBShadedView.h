//
//  Created by Eddy Borja.
//  Copyright (c) 2014 Eddy Borja. All rights reserved.
/*
 Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:
 
 The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.
 
 THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
 */


#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>

/*EBShadedView is a UIView subclass used for rendering full screen tinting effects*/

@interface EBShadedView : UIView
+ (instancetype)upperGradientWithFrame:(CGRect)frame;
+ (instancetype)lowerGradientWithFrame:(CGRect)frame;
+ (instancetype)screenDimmerWithFrame:(CGRect)frame;
+ (instancetype)spotlightWithFrame:(CGRect)frame atPoint:(CGPoint)spotlightCenter;
@end

@interface EBGradientView : EBShadedView
@property (nonatomic) CGGradientRef gradientRef;
- (void)setReversed:(BOOL)reverse;
@end

@interface EBDimmedScreenView : EBShadedView
@end

@interface EBSpotlightShadeView : EBShadedView
@property (assign) CGPoint spotlightCenter;
@property (assign) CGFloat spotlightEndRadius;
@property (assign) CGFloat spotlightStartRadius;
@property (assign) CGFloat spotlightBlackOpacity;
- (id)initWithFrame:(CGRect)frame spotlightAtPoint:(CGPoint)spotlightCenter;
@end