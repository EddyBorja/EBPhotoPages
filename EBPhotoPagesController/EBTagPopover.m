//
//  Created by Eddy Borja.
//  Copyright (c) 2014 Eddy Borja. All rights reserved.
/*
 Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:
 
 The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.
 
 THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
 */


#import "EBTagPopover.h"
#import "EBPhotoPagesController.h"
#import "EBPhotoPagesNotifications.h"
#import <QuartzCore/QuartzCore.h>


@interface EBTagPopover ()
@property (weak) UIView *contentView;
@property (weak) UITextField *tagTextField;
@property (assign, getter = isCanceled) BOOL canceled;
@end

#pragma mark - EBTagPopover

@implementation EBTagPopover

- (id)init
{
    self = [super init];
    if (self) {
        [self initialize];
    }
    return self;
}

- (id)initWithDelegate:(id<EBTagPopoverDelegate>)delegate
{
    self = [super init];
    if (self) {
        NSAssert([(NSObject *)delegate conformsToProtocol:@protocol(EBTagPopoverDelegate)],
                 @"A tag popover's delegate must conform to the EBTagPopoverDelegate protocol.");
        [self initialize];
        [self setDelegate:delegate];
    }
    return self;
}

- (id)initWithTag:(id<EBPhotoTagProtocol>)aTag
{
    self = [super init];
    if(self){
        NSAssert([(NSObject *)aTag conformsToProtocol:@protocol(EBPhotoTagProtocol)],
                 @"A tag's data source must conform to EBPhotoTagProtocol.");
        [self initialize];
        [self setDataSource:aTag];
        [self setText:self.dataSource.tagText];
    }
    return self;
}

- (void)initialize
{
    [self loadContentView];
    [self loadGestureRecognizers];
    
    CGSize tagInsets = CGSizeMake(-7, -6);
    CGRect tagBounds = CGRectInset(self.contentView.bounds, tagInsets.width, tagInsets.height);
    tagBounds.size.height += 10.0f;
    tagBounds.origin.x = 0;
    tagBounds.origin.y = 0;
    
    [self setFrame:tagBounds];
    
    [self setMinimumTextFieldSize:CGSizeMake(25, 14)];
    [self setMinimumTextFieldSizeWhileEditing:CGSizeMake(54, 14)];
    [self setMaximumTextLength:40];
    
    [self setNormalizedArrowOffset:CGPointMake(0.0, 0.02)];
    
    [self setOpaque:NO];
    [self.contentView setFrame:CGRectOffset(self.contentView.frame,
                                            -(tagInsets.width),
                                            -(tagInsets.height)+10)];
    
    [self beginObservations];
}

- (void)dealloc
{
    [self stopObservations];
}

#pragma mark -

- (void)loadContentView
{
    UIView *contentView = [self newContentView];
    [self addSubview:contentView];
    [self setContentView:contentView];
}

- (void)loadGestureRecognizers
{
    UITapGestureRecognizer *singleTapGesture = [[UITapGestureRecognizer alloc]
                                                initWithTarget:self
                                                        action:@selector(didRecognizeSingleTap:)];
    [singleTapGesture setNumberOfTapsRequired:1];
    
    [self addGestureRecognizer:singleTapGesture];
}

- (UIView *)newContentView
{
    NSString *placeholderText = NSLocalizedString(@"New Tag",
                                                  @"Appears as placeholder text before a user enters text for a photo tag.");
    UIFont *textFieldFont = [UIFont fontWithName:@"HelveticaNeue-Bold" size:12];
    CGSize tagSize = [placeholderText sizeWithAttributes:@{NSFontAttributeName: [UIFont fontWithName:@"HelveticaNeue-Bold" size:12]}];
    UITextField *textField = [[UITextField alloc] initWithFrame:CGRectMake(0, 0, tagSize.width, tagSize.height)];
    [textField setFont:textFieldFont];
    [textField setBackgroundColor:[UIColor clearColor]];
    [textField setTextColor:[UIColor whiteColor]];
    [textField setPlaceholder:placeholderText];
    [textField setAutocorrectionType:UITextAutocorrectionTypeNo];
    [textField setKeyboardAppearance:UIKeyboardAppearanceAlert];
    [textField setTextAlignment:NSTextAlignmentCenter];
    [textField setReturnKeyType:UIReturnKeyDone];
    [textField setEnablesReturnKeyAutomatically:YES];
    [textField setDelegate:self];
    [textField setUserInteractionEnabled:NO];
    
    [self setTagTextField:textField];
    return textField;
}


#pragma mark - Notifications

- (void)beginObservations
{
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(tagTextFieldDidChangeWithNotification:)
                                                 name:UITextFieldTextDidChangeNotification
                                               object:nil];
    
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(didReceiveCancelNotification:)
                                                name:EBPhotoPagesControllerDidCancelTaggingNotification object:nil];
}


- (void)stopObservations
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark - 

- (void)tagTextFieldDidChangeWithNotification:(NSNotification *)aNotification
{
    //resize, reposition
    if(aNotification.object == self.tagTextField){
        [self resizeTextField];
    }
}


- (NSString *)text
{
    return self.tagTextField.text;
}

- (void)setText:(NSString *)text
{
    [self.tagTextField setText:text];
    [self resizeTextField];
}

- (void)setDelegate:(id<EBTagPopoverDelegate>)aDelegate
{
    NSAssert([aDelegate conformsToProtocol:@protocol(EBTagPopoverDelegate)],
             @"EBTagPopover delegates must conform to EBTagPopoverDelegate protocol.");
    _delegate = aDelegate;
}


- (void)presentPopoverFromPoint:(CGPoint)point
                         inView:(UIView *)view
                       animated:(BOOL)animated
{
    [self presentPopoverFromPoint:point
                           inRect:view.frame
                           inView:view
         permittedArrowDirections:UIPopoverArrowDirectionUp
                         animated:animated];
}



- (void)presentPopoverFromPoint:(CGPoint)point
                         inView:(UIView *)view
       permittedArrowDirections:(UIPopoverArrowDirection)arrowDirections
                       animated:(BOOL)animated
{
    [self presentPopoverFromPoint:point
                           inRect:view.frame
                           inView:view
         permittedArrowDirections:arrowDirections
                         animated:animated];
}


- (void)presentPopoverFromPoint:(CGPoint)point
                         inRect:(CGRect)rect
                         inView:(UIView *)view
       permittedArrowDirections:(UIPopoverArrowDirection)arrowDirections
                       animated:(BOOL)animated;
{
    //[self setCenter:point];
    
    [view addSubview:self];
    
    CGPoint difference = CGPointMake(0,//(newCenter.x - point.x)/self.frame.size.width,
                                     0.5);
    
    [self.layer setAnchorPoint:CGPointMake(0.5-difference.x,0.5-difference.y)];
    
    [self setCenter:point];
    
    CGFloat tagMaximumX = CGRectGetMaxX(self.frame);
    CGFloat tagMinimumX = CGRectGetMinX(self.frame);
    CGFloat tagMaximumY = CGRectGetMaxY(self.frame);
    CGFloat tagMinimumY = CGRectGetMinY(self.frame);
    
    CGRect tagBoundary = CGRectInset(view.frame, 5, 5);
    CGFloat boundsMinimumX = CGRectGetMinX(tagBoundary);
    CGFloat boundsMaximumX = CGRectGetMaxX(tagBoundary);
    CGFloat boundsMinimumY = CGRectGetMinY(tagBoundary);
    CGFloat boundsMaximumY = CGRectGetMaxY(tagBoundary);
    
    CGFloat xOffset = ((MIN(0, tagMinimumX - boundsMinimumX) + MAX(0, tagMaximumX - boundsMaximumX))/1.0);
    CGFloat yOffset = ((MIN(0, tagMinimumY - boundsMinimumY) + MAX(0, tagMaximumY - boundsMaximumY))/1.0);
    
    
    CGPoint newCenter = CGPointMake(point.x - xOffset,
                                    point.y - yOffset);
    
    [self setCenter:newCenter];

    
/*
    CGRect newFrame = self.frame;
    newFrame.origin.x = point.x;
    newFrame.origin.y = point.y;
    //[self setFrame:newFrame];
    
    [self setTransform:CGAffineTransformMakeScale(0.3, 0.3)];
    [UIView animateWithDuration:0.3 delay:0 options:UIViewAnimationOptionCurveEaseOut animations:^{
        [self setTransform:CGAffineTransformMakeScale(1,1)];
    }completion:nil];
*/
    
}


- (void)drawRect:(CGRect)fullRect
{
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    
	float radius = 4.0f;
    float arrowHeight =  10.0f; //this is how far the arrow extends from the rect
    float arrowWidth = 20.0;
    
    fullRect = CGRectInset(fullRect, 1, 1);
    
    CGRect containerRect = CGRectMake(fullRect.origin.x,
                      fullRect.origin.y+arrowHeight,
                      fullRect.size.width,
                      fullRect.size.height-arrowHeight);
    
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    
    
    CGMutablePathRef tagPath = CGPathCreateMutable();
    
    //the starting point, top left corner
    CGPathMoveToPoint(tagPath, NULL, CGRectGetMinX(containerRect) + radius, CGRectGetMinY(containerRect));
    
    //draw the arrow
    CGPathAddLineToPoint(tagPath, NULL, CGRectGetMidX(containerRect)-(arrowWidth*0.5), CGRectGetMinY(containerRect));
    CGPathAddLineToPoint(tagPath, NULL, CGRectGetMidX(containerRect), CGRectGetMinY(fullRect));
    CGPathAddLineToPoint(tagPath, NULL, CGRectGetMidX(containerRect)+(arrowWidth*0.5), CGRectGetMinY(containerRect));
    
    //top right corner
    CGPathAddArc(tagPath, NULL, CGRectGetMaxX(containerRect) - radius, CGRectGetMinY(containerRect) + radius, radius, 3 * (float)M_PI / 2, 0, 0);
    
    //bottom right corner
    CGPathAddArc(tagPath, NULL, CGRectGetMaxX(containerRect) - radius, CGRectGetMaxY(containerRect) - radius, radius, 0, (float)M_PI / 2, 0);
    
    //bottom left corner
    CGPathAddArc(tagPath, NULL, CGRectGetMinX(containerRect) + radius, CGRectGetMaxY(containerRect) - radius, radius, (float)M_PI / 2, (float)M_PI, 0);
    
    //top left corner, the ending point
    CGPathAddArc(tagPath, NULL, CGRectGetMinX(containerRect) + radius, CGRectGetMinY(containerRect) + radius, radius, (float)M_PI, 3 * (float)M_PI / 2, 0);
    
    //we are done
    CGPathCloseSubpath(tagPath);
    
    
                                                                               
    CGContextAddPath(context, tagPath);
    //CGContextSetShadowWithColor(context, CGSizeMake(0, 2), 1.5, [[UIColor colorWithRed:0 green:0 blue:20/255.0 alpha:0.35] CGColor]);
    CGContextSetFillColorWithColor(context, [[UIColor colorWithWhite:0.11 alpha:0.75] CGColor]);
    
    
    CGContextFillPath(context);
    
    //Draw stroke
    CGContextAddPath(context, tagPath);
    CGContextSetStrokeColorWithColor(context, [[UIColor colorWithWhite:0.85 alpha:1] CGColor]);
    CGContextSetLineWidth(context, 1);
    CGContextSetLineJoin(context, kCGLineJoinRound);
    CGContextStrokePath(context);
    
    
    
    //CGContextAddPath(context, tagPath);
 
    
    //CGPathRelease(arrowPath);
    CGPathRelease(tagPath);
    CGColorSpaceRelease(colorSpace);
    
}

- (void)repositionInRect:(CGRect)rect
{
    [self.layer setAnchorPoint:CGPointMake(0.5,0)];
    CGPoint popoverPoint = CGPointMake(rect.origin.x, rect.origin.y);
    popoverPoint.x += rect.size.width * (self.normalizedArrowPoint.x + self.normalizedArrowOffset.x);
    popoverPoint.y += rect.size.height * (self.normalizedArrowPoint.y + self.normalizedArrowOffset.y);
    
    [self setCenter:popoverPoint];
    
    CGFloat rightX = self.frame.origin.x+self.frame.size.width;
    CGFloat leftXClip = MAX(rect.origin.x - self.frame.origin.x, 0);
    CGFloat rightXClip = MIN((rect.origin.x+rect.size.width)-rightX, 0);
    
    CGRect newFrame = self.frame;
    newFrame.origin.x += leftXClip;
    newFrame.origin.x += rightXClip;
    
    [self setFrame:newFrame];
    
    
}

#pragma mark - Event Hooks

- (void)didRecognizeSingleTap:(UITapGestureRecognizer *)tapGesture
{
    if(self.isFirstResponder == NO){
        [self.delegate tagPopover:self didReceiveSingleTap:tapGesture];
    }
}

- (void)didReceiveCancelNotification:(NSNotification *)aNotification
{
    if(self.isFirstResponder){
        [self setCanceled:YES];
        [self resignFirstResponder];
        [self removeFromSuperview];
    }
}

#pragma mark - UITextField Delegate


- (BOOL)textField:(UITextField *)textField
    shouldChangeCharactersInRange:(NSRange)range
                replacementString:(NSString *)string {
    BOOL result = NO;
    
    if(textField == self.tagTextField){
        NSUInteger newLength = [textField.text length] + [string length] - range.length;
        if((!self.maximumTextLength) || (newLength <= self.maximumTextLength)){
            result = YES;
        }
    }
    
    return result;
}

- (void)textFieldDidBeginEditing:(UITextField *)textField
{
    if(textField == self.tagTextField){
        [textField setTextAlignment:NSTextAlignmentLeft];
        [self resizeTextField];
    }
}

- (void)textFieldDidEndEditing:(UITextField *)textField
{
    if(textField == self.tagTextField){
        [textField setTextAlignment:NSTextAlignmentCenter];
        [self resizeTextField];
        if([self isCanceled] == NO){
            [self.delegate tagPopoverDidEndEditing:self];
        }
        [self resignFirstResponder];
    }
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    if(textField == self.tagTextField){
        [self resignFirstResponder];
    }
    return YES;
}

- (BOOL)becomeFirstResponder
{
    [self.tagTextField setUserInteractionEnabled:YES];
    if([self.tagTextField canBecomeFirstResponder]){
        [self.tagTextField becomeFirstResponder];
        [self resizeTextField];
        return YES;
    }
    
    [self.tagTextField setUserInteractionEnabled:NO];
    return NO;
}

- (BOOL)isFirstResponder
{
    return self.tagTextField.isFirstResponder;
}

- (BOOL)resignFirstResponder
{
    [self.tagTextField setUserInteractionEnabled:NO];
    return self.tagTextField.resignFirstResponder;
}

# pragma mark -

- (void)resizeTextField
{
    CGSize newTagSize = CGSizeZero;
    if(self.tagTextField.text && ![self.tagTextField.text isEqualToString:@""]){
        newTagSize = [self.tagTextField.text sizeWithAttributes:@{NSFontAttributeName: self.tagTextField.font}];
    } else if (self.tagTextField.placeholder && ![self.tagTextField.placeholder isEqualToString:@""]){
        newTagSize = [self.tagTextField.text sizeWithAttributes:@{NSFontAttributeName: self.tagTextField.font}];
    }
    
    if(self.tagTextField.isFirstResponder){
        //This gives some extra room for the cursor.
        newTagSize.width += 3;
    }
    
    CGRect newTextFieldFrame = self.tagTextField.frame;
    CGSize minimumSize = self.tagTextField.isFirstResponder ? self.minimumTextFieldSizeWhileEditing :
                                                              self.minimumTextFieldSize;
    
    newTextFieldFrame.size.width = MAX(newTagSize.width, minimumSize.width);
    newTextFieldFrame.size.height = MAX(newTagSize.height, minimumSize.height);
    [self.tagTextField setFrame:newTextFieldFrame];
    
    
    CGSize tagInsets = CGSizeMake(-7, -6);
    CGRect tagBounds = CGRectInset(self.tagTextField.bounds, tagInsets.width, tagInsets.height);
    tagBounds.size.height += 10.0f;
    tagBounds.origin.x = 0;
    tagBounds.origin.y = 0;
    

    CGPoint originalCenter = self.center;
    [self setFrame:tagBounds];
    [self setCenter:originalCenter];
    
    [self setNeedsDisplay];
}



@end
