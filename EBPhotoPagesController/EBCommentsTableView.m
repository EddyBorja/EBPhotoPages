//
//  Created by Eddy Borja.
//  Copyright (c) 2014 Eddy Borja. All rights reserved.
/*
 Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:
 
 The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.
 
 THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
 */


#import "EBCommentsTableView.h"

@implementation EBCommentsTableView

- (instancetype)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self) {
        [self initialize];
    }
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame style:(UITableViewStyle)style
{
    self = [super initWithFrame:frame style:style];
    if (self) {
        [self initialize];
    }
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self initialize];
    }
    return self;
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        [self initialize];
    }
    return self;
}

- (void)initialize
{
    
}


- (void)drawRect:(CGRect)rect
{
    [super drawRect:rect];
    
    if(self.drawsDividerLine){
        //draw divider
        CGFloat marginSize = 10;
        CGPoint lineEndPoints[] =  {CGPointMake(marginSize, CGRectGetMaxY(rect)),
            CGPointMake(CGRectGetMaxX(rect)-marginSize, CGRectGetMaxY(rect))
        };
        
        CGContextRef context = UIGraphicsGetCurrentContext();
        CGFloat strokeColor[4] = {1,1,1,0.35};
        CGContextSetStrokeColor(context, strokeColor);
        CGContextSetLineWidth(context, 2);
        CGContextAddLines(context, lineEndPoints, 2);
        CGContextStrokePath(context);
    }
}

- (void)setDrawsDividerLine:(BOOL)drawsDividerLine
{
    _drawsDividerLine = drawsDividerLine;
    [self setNeedsDisplay];
}

- (void)reloadData
{
    [super reloadData];

    [self recalculateContentInset];
    [self recalculateScrollIndicator];
}

- (void)recalculateContentInset
{
    CGFloat contentInsetHeight = MAX(self.frame.size.height - self.contentSize.height, 0);
    CGFloat duration = 0.0;
    [UIView animateWithDuration:duration
                          delay:0
                        options:UIViewAnimationOptionCurveEaseOut
                     animations:^{
        [self setContentInset:UIEdgeInsetsMake(contentInsetHeight, 0, 0, 0)];
    }completion:nil];
}

- (void)recalculateScrollIndicator
{
    if(self.contentSize.height >= self.frame.size.height){
        [self setShowsVerticalScrollIndicator:YES];
    } else {
        [self setShowsVerticalScrollIndicator:NO];
    }
}


@end
