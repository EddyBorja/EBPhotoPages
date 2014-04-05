//
//  Created by Eddy Borja.
//  Copyright (c) 2014 Eddy Borja. All rights reserved.
/*
 Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:
 
 The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.
 
 THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
 */


#import <UIKit/UIKit.h>
#import "EBTagPopoverDelegate.h"
#import "EBPhotoTagProtocol.h"

/*EBTagPopover is a UIView subclass that displays the text for a tag 
 within a callout bubble coming from a specific point in a photo*/

@interface EBTagPopover : UIView <UITextFieldDelegate>

@property (strong) id <EBPhotoTagProtocol> dataSource;
@property (nonatomic, weak) id <EBTagPopoverDelegate> delegate;
@property (assign) CGPoint normalizedArrowPoint;
@property (assign) CGPoint normalizedArrowOffset;
@property (assign) CGSize minimumTextFieldSize;
@property (assign) CGSize minimumTextFieldSizeWhileEditing;
@property (assign) NSInteger maximumTextLength; //set to 0 for no limit on a tag's length.


- (id)initWithDelegate:(id<EBTagPopoverDelegate>)delegate;
- (id)initWithTag:(id<EBPhotoTagProtocol>)aTag;

- (NSString *)text;
- (void)setText:(NSString *)text;

- (void)presentPopoverFromPoint:(CGPoint)point
                         inView:(UIView *)view
                       animated:(BOOL)animated;

- (void)presentPopoverFromPoint:(CGPoint)point
                         inView:(UIView *)view
       permittedArrowDirections:(UIPopoverArrowDirection)arrowDirections
                       animated:(BOOL)animated;

- (void)presentPopoverFromPoint:(CGPoint)point
                         inRect:(CGRect)rect
                         inView:(UIView *)view
       permittedArrowDirections:(UIPopoverArrowDirection)arrowDirections
                       animated:(BOOL)animated;

- (void)repositionInRect:(CGRect)rect;


@end






