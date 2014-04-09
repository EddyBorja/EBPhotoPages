//
//  Created by Eddy Borja.
//  Copyright (c) 2014 Eddy Borja. All rights reserved.
/*
 Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:
 
 The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.
 
 THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
 */


#import "EBCaptionView.h"
#import <QuartzCore/QuartzCore.h>

const NSInteger MaximumNumberOfCaptionLines = 1000000;
const NSInteger MaximumCaptionTextHeight = 10000000;

static NSString *FrameKeyPath = @"frame";

@interface EBCaptionView ()
@property (strong) UILabel *textLabel;
@end

#pragma mark - EBCaptionScrollView
@implementation EBCaptionView

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
    
    UILabel *captionLabel = [self newCaptionLabel];
    [self setTextLabel:captionLabel];
    [self setDelegate:self];
    [self setBackgroundColor:[UIColor clearColor]];
    [self setScrollEnabled:YES];
    [self setBounces:YES];
    [self setAlwaysBounceVertical:YES];
    [self setShowsHorizontalScrollIndicator:NO];
    [self setShowsVerticalScrollIndicator:NO];
    [self setAutoresizingMask:UIViewAutoresizingFlexibleWidth|
                              UIViewAutoresizingFlexibleHeight];
    [self beginObservations];
    [self loadContentViews];
}

- (void)dealloc
{
    [self stopObservations];
}

#pragma mark - Key Value Observing

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
        NSLog(@"Update caption");
        [self setNeedsDisplay];
    }
}

#pragma mark - Views

- (void)layoutSubviews
{
    [super layoutSubviews];
    [self resetContentSize];
}

#pragma mark - Loading

- (void)loadContentViews
{
    NSArray *contentViews = [self captionContentViews];
    for(UIView *view in contentViews){
        [self addSubview:view];
    }
    
    [self resetContentSize];
}

#pragma mark - Setters


- (void)setCaption:(NSString *)string
{
    NSAssert(self.textLabel, @"Got to have a text label for caption view in order to set caption.");
    
    [self.textLabel setText:nil];
    if([string isEqualToString:@""] || string == nil){
        [self.textLabel setText:@""];
        [self setHidden:YES];
        [self resetContentSize];
        [self resetContentOffset];
        return;
    } else {
        [self setHidden:NO];
    }
    
    CGFloat totalFadeDuration = 0.2;
    [UIView animateWithDuration:totalFadeDuration/2.0
                          delay:0
                        options:UIViewAnimationCurveEaseOut|
                                UIViewAnimationOptionBeginFromCurrentState
                     animations:^{
                         [self.textLabel setAlpha:0];
                     }
                     completion:^(BOOL finished){
                         [self.textLabel setText:string];
                         [self setFrameForLabel:self.textLabel
                                     withString:string
                                    maximumSize:CGSizeMake(self.frame.size.width,
                                                    MaximumCaptionTextHeight)];
                         [self resetContentSize];
                         [self resetContentOffset];
                         
                         [UIView animateWithDuration:totalFadeDuration/2.0
                                               delay:0
                                             options:UIViewAnimationCurveEaseOut|
                                                     UIViewAnimationOptionBeginFromCurrentState
                                          animations:^{
                             [self.textLabel setAlpha:1];
                                          }
                                          completion:nil];
                     }];
    
    if([string isEqualToString:@""] || string == nil){
        [self setHidden:YES];
    } else {
        [self setHidden:NO];
    }
}

- (void)setAttributedCaption:(NSAttributedString *)attributedString
{
    NSAssert(self.textLabel, @"Got to have a text label for caption view in order to set caption.");
    
    [self.textLabel setAttributedText:nil];
    if([attributedString.string isEqualToString:@""] || attributedString == nil){
        [self.textLabel setText:@""];
        [self setHidden:YES];
        [self resetContentSize];
        [self resetContentOffset];
        return;
    } else {
        [self setHidden:NO];
    }
    
    CGFloat totalFadeDuration = 0.2;
    [UIView animateWithDuration:totalFadeDuration/2.0
                          delay:0
                        options:UIViewAnimationCurveEaseOut|
     UIViewAnimationOptionBeginFromCurrentState
                     animations:^{
                         [self.textLabel setAlpha:0];
                     }
                     completion:^(BOOL finished){
                         [self.textLabel setAttributedText:attributedString];
                         [self setFrameForLabel:self.textLabel
                                     withString:[attributedString string]
                                    maximumSize:CGSizeMake(self.frame.size.width,
                                                    MaximumCaptionTextHeight)];
                         [self resetContentSize];
                         [self resetContentOffset];
                         
                         [UIView animateWithDuration:totalFadeDuration/2.0
                                               delay:0
                                             options:UIViewAnimationCurveEaseOut|
                          UIViewAnimationOptionBeginFromCurrentState
                                          animations:^{
                                              [self.textLabel setAlpha:1];
                                          }
                                          completion:nil];
                     }];
}

- (void)setFrameForLabel:(UILabel *)label
              withString:(NSString *)string
             maximumSize:(CGSize)maximumSize
{
    CGRect expectedLabelSize = [string boundingRectWithSize:maximumSize options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName: label.font} context:nil];
    
    CGRect newFrame = label.frame;
    newFrame.size.height = expectedLabelSize.size.height;
    newFrame.size.width = maximumSize.width;
    [label setFrame:newFrame];
}

- (void)resetContentSize
{
    CGRect subviewsRect = CGRectZero;
    for(UIView *view in self.subviews){
        subviewsRect = CGRectUnion(subviewsRect, view.frame);
    }
    
    CGFloat contentHeight = subviewsRect.size.height + 10;
    [self setContentSize:CGSizeMake(1, contentHeight)];
    CGFloat topInset = self.bounds.size.height - MIN(contentHeight, 65);
    [self setContentInset:UIEdgeInsetsMake(topInset, 0, 0, 0)];
}

- (void)resetContentOffset
{
    [self setContentOffset:
     CGPointMake(-self.contentInset.left,
                 -self.contentInset.top)];
}

#pragma mark - Getters

- (NSArray *)captionContentViews
{
    NSAssert(self.textLabel,
             @"Caption textLabel property must be set before requesting contentViews");
    return @[self.textLabel];
}

- (CGSize)captionContentSize
{
    NSAssert(self.textLabel,
             @"Caption textLabel property must be set before requesting content size");
    return self.textLabel.frame.size;
}




#pragma mark - Overrides

- (void)drawRect:(CGRect)rect
{
    [super drawRect:rect];
    
    CGPoint lineEndPoints[] =  {CGPointMake(0, CGRectGetMaxY(rect)),
        CGPointMake(CGRectGetMaxX(rect), CGRectGetMaxY(rect))
    };
    
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGFloat strokeColor[4] = {1,1,1,0.35};
    CGContextSetStrokeColor(context, strokeColor);
    CGContextSetLineWidth(context, 2);
    CGContextAddLines(context, lineEndPoints, 2);
    CGContextStrokePath(context);
}

- (BOOL)pointInside:(CGPoint)point withEvent:(UIEvent *)event
{
    for(UIView *subview in self.subviews){
        if (CGRectContainsPoint(subview.frame, point)) {
            if(CGRectContainsPoint(self.bounds, point)){
                return YES;
            }
        }
    }
    
    
    
    return NO;
}

#pragma mark - Factory Methods

- (UILabel *)newCaptionLabel
{
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectZero];
    [label setAutoresizingMask:UIViewAutoresizingFlexibleWidth];
    [label setNumberOfLines:MaximumNumberOfCaptionLines];
    [label setBackgroundColor:[UIColor clearColor]];
    [label setTextColor:[UIColor whiteColor]];
    [label setFont:[UIFont fontWithName:@"HelveticaNeue-Light" size:15]];
    [label setShadowColor:[UIColor colorWithWhite:0 alpha:0.5]];
    [label setShadowOffset:CGSizeMake(0, 1)];
    return label;
}
@end