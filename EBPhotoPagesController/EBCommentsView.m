//
//  Created by Eddy Borja.
//  Copyright (c) 2014 Eddy Borja. All rights reserved.
//
/*
 Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:
 
 The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.
 
 THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
 */


#import "EBCommentsView.h"
#import <QuartzCore/QuartzCore.h>
#import "EBCommentsTableView.h"

@interface EBCommentsView ()
@property (weak, readwrite) EBCommentsTableView *tableView;
@property (weak, readwrite) UIButton *postButton;
@property (weak, readwrite) UITextView *commentTextView;
@property (weak, readwrite) UILabel *commentTextViewPlaceholder;

@end

@implementation EBCommentsView

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
    [self setClipsToBounds:NO];
    UIColor *backgroundColor = [UIColor colorWithWhite:0 alpha:0.75];
    [self setBackgroundColor:backgroundColor];
    [self loadTableView];
    [self loadPostButton];
    [self loadCommentTextView];
    [self loadPlaceholderForTextView:self.commentTextView];
    [self loadKeyboardFillerView];
}


#pragma mark - Loading

- (void)loadTableView
{
    CGRect tableViewFrame = CGRectMake(0,
                                       0,
                                       self.frame.size.width,
                                       self.frame.size.height-40);
    EBCommentsTableView *tableView = [[EBCommentsTableView alloc] initWithFrame:tableViewFrame
                                                          style:UITableViewStylePlain];
    [tableView setBackgroundColor:[UIColor clearColor]];
    [tableView setSeparatorStyle:UITableViewCellSeparatorStyleNone];
    [tableView setIndicatorStyle:UIScrollViewIndicatorStyleWhite];
    //[tableView setContentInset:UIEdgeInsetsMake(70, 0, 0, 0)];
    [tableView setAutoresizingMask:UIViewAutoresizingFlexibleBottomMargin|UIViewAutoresizingFlexibleWidth];
    [self setTableView:tableView];
    [self addSubview:tableView];
    [tableView setDelegate:self];
    [tableView setContentOffset:CGPointMake(0, CGFLOAT_MAX)];
}

- (void)loadCommentTextView
{
    CGPoint textViewOrigin = CGPointMake(5, self.tableView.frame.size.height);
    CGRect textViewFrame = CGRectMake(textViewOrigin.x,
                                      textViewOrigin.y,
                                      self.frame.size.width-(72+textViewOrigin.x),
                                      self.frame.size.height-self.tableView.frame.size.height);
    
    
    
    UITextView *textView = [[UITextView alloc] initWithFrame:textViewFrame];
    [textView setBackgroundColor:[UIColor clearColor]];
    [textView setFont:[UIFont fontWithName:@"HelveticaNeue-Light" size:16]];
    [textView setKeyboardAppearance:UIKeyboardAppearanceAlert];
    [textView setTextColor:[UIColor whiteColor]];
    //[self setAutoresizingMask:UIViewAutoresizingFlexibleTopMargin|  UIViewAutoresizingFlexibleWidth];
    [self setCommentTextView:textView];
    [self addSubview:textView];
    [self setInputPlaceholderEnabled:YES];
    [self.commentTextView setAutoresizingMask:UIViewAutoresizingFlexibleWidth];
}

- (void)loadPlaceholderForTextView:(UITextView *)textView
{
    UILabel *label = [[UILabel alloc] initWithFrame:textView.frame];
    [label setTextAlignment:NSTextAlignmentLeft];
    [label setFont:textView.font];
    [label setBackgroundColor:[UIColor clearColor]];
    [label setTextColor:[UIColor colorWithWhite:0.5 alpha:1]];
    [textView.superview insertSubview:label belowSubview:textView];
    [label setText:[self commentInputPlaceholderText]];
    [label setFrame:CGRectOffset(label.frame, 5, -3)];
    [self setCommentTextViewPlaceholder:label];
}



- (void)loadKeyboardFillerView
{
    UIView *fillerView = [[UIView alloc] initWithFrame:CGRectOffset(self.frame, 0, self.frame.size.height)];
    [fillerView setAutoresizingMask:UIViewAutoresizingFlexibleBottomMargin|UIViewAutoresizingFlexibleWidth];
    [fillerView setBackgroundColor:self.backgroundColor];
    [self addSubview:fillerView];
}

// TODO: Refactor button decoration, use factory instead
- (void)loadPostButton
{
    CGSize buttonSize = CGSizeMake(62, 28);
    CGRect buttonFrame = CGRectMake(self.frame.size.width-buttonSize.width-12,
                                    self.frame.size.height-buttonSize.height-6,
                                    buttonSize.width,
                                    buttonSize.height);
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    [button setFrame:buttonFrame];
    [button setTitle:NSLocalizedString(@"post", @"Appears on a button that posts a comment when tapped.")
            forState:UIControlStateNormal];
    [button addTarget:self
               action:@selector(didSelectPostButton:)
     forControlEvents:UIControlEventTouchUpInside];
    [button setAlpha:0];
    [self setPostButton:button];
    [self addSubview:button];
    
    [self.postButton setAutoresizingMask:UIViewAutoresizingFlexibleLeftMargin];
    
    [button setBackgroundColor:[self postButtonColor]];
    
    [button.layer setCornerRadius:4.0];
    [button.layer setShadowColor:[[UIColor blackColor] CGColor]];
    [button.layer setShadowOffset:CGSizeMake(0, 1)];
    [button.layer setShadowOpacity:0.5];
    [button.layer setShadowRadius:1];
    
    [button.titleLabel setFont:[UIFont systemFontOfSize:16]];
    [button.titleLabel setTextColor:[UIColor colorWithWhite:0.85 alpha:1]];
    [button setTitleColor:[UIColor colorWithWhite:0.25 alpha:1]
                 forState:UIControlStateHighlighted];
    
}

- (void)setNeedsLayout
{
    CGRect newFrame = self.bounds;
    newFrame.size.width = self.bounds.size.width*2;
    [self.tableView setNeedsDisplay];
    [self reloadComments];
}


#pragma mark - Setters


- (void)reloadComments
{
    [self.tableView reloadData];
}


- (void)setPostButtonHidden:(BOOL)hidden
{
    const CGFloat duration = 0.20;
    CGFloat alpha = hidden ? 0 : 1.0;
    CGFloat delay = hidden ? 0 : 0.05;
    
    [UIView animateWithDuration:duration
                          delay:delay
                        options:UIViewAnimationOptionCurveEaseOut
                     animations:^{
                         [self.postButton setAlpha:alpha];
    }completion:nil];
}

- (void)setInputPlaceholderEnabled:(BOOL)enabled
{
    _inputPlaceholderEnabled = enabled;
    [self.commentTextViewPlaceholder setHidden:!enabled];
}

#pragma mark - Events



- (void)didSelectPostButton:(id)sender
{
    if(self.commentTextView.isFirstResponder){
        NSString *commentText = self.commentTextView.text;
        [self.commentTextView resignFirstResponder];
        [self.commentsDelegate commentsView:self didPostNewComment:commentText];
    }
}

- (void)enableCommenting
{
    [self.commentTextView setHidden:NO];
    //[self.commentTextViewPlaceholder setHidden:NO];
    [self.commentTextViewPlaceholder setText:[self commentInputPlaceholderText]];
    [self.tableView setDrawsDividerLine:YES];
}

- (void)disableCommenting
{
    [self.commentTextView setHidden:YES];
    //[self.commentTextViewPlaceholder setHidden:YES];
    [self.commentTextViewPlaceholder setText:[self disabledInputPlaceholderText]];
    [self.tableView setDrawsDividerLine:NO];
}

- (void)startCommenting
{
    [self.commentTextView becomeFirstResponder];
}

- (void)cancelCommenting
{
    [self.commentTextView resignFirstResponder];
}


#pragma mark - Colors and Text


- (UIColor *)postButtonColor
{
    return [UIColor colorWithRed:0 green:118/255.0 blue:1.0 alpha:1.0];
}

- (NSString *)commentInputPlaceholderText
{
    return NSLocalizedString(@"Write a comment...", @"Appears in a textbox where a user can write a comment.");
}

- (NSString *)disabledInputPlaceholderText
{
    return NSLocalizedString(@"Commenting is disabled.", @"Appears in a text box to informa a user no new comments are being accepted for a photo.");
}



#pragma mark -
//Leave this blank to prevent UITextView from scrolling the UIPageViewController when it becomes first responder.
- (void)scrollRectToVisible:(CGRect)rect animated:(BOOL)animated{}


@end
