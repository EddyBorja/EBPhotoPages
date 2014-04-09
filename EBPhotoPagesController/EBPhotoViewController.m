//
//  Created by Eddy Borja.
//  Copyright (c) 2014 Eddy Borja. All rights reserved.
//
/*
 Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:
 
 The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.
 
 THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
 */



#import "EBPhotoViewController.h"
#import "EBPhotoPagesNotifications.h"
#import "EBPhotoView.h"
#import "EBPhotoPagesDataSource.h"
#import "EBPhotoTagProtocol.h"
#import "EBPhotoCommentProtocol.h"
#import "EBTagPopover.h"
#import "EBCommentsView.h"
#import "EBPhotoPagesController.h"
#import "EBCommentCell.h"
#import "EBCommentsTableView.h"

static NSString *TagPopoversKeyPath = @"tagPopovers";

@interface EBPhotoViewController ()
@property (assign) NSInteger photoIndex;
@property (weak, readwrite) EBPhotoView *photoView;
@property (weak, readwrite) EBCommentsView *commentsView;
@property (strong) NSMutableSet *activeOperations;
@property (strong, readwrite) UIView *activityIndicator;

@property (readwrite) NSArray *tagPopovers;

@end



#pragma mark -
#pragma mark - EBPhotoViewController
@implementation EBPhotoViewController

- (id)init
{
    self = [super init];
    if (self) {
        NSAssert(0, @"EBPhotoViewController class must init with the index for a photo and a delegate.");
    }
    return self;
}

- (id)initWithIndex:(NSInteger)photoIndex delegate:(id<EBPhotoViewControllerDelegate>)aDelegate
{
    self = [super init];
    if (self) {
        NSAssert(photoIndex >= 0, @"Photo Index cannot be negative for an EBPhotoViewController class.");
        NSAssert([aDelegate conformsToProtocol:@protocol(EBPhotoViewControllerDelegate)],
                 @"An EBPhotoViewController class requires a delegate conforming to the proper protocol.");
        
        [self setPhotoIndex:photoIndex];
        [self setDelegate:aDelegate];
        [self initialize];
    }
    return self;
}

- (void)initialize
{
    [self setActiveOperations:[NSMutableSet set]];
    
    CGRect viewFrame = [[UIScreen mainScreen] bounds];
    UIView *mainView = [[UIView alloc] initWithFrame:viewFrame];
    [self setView:mainView];
    
    EBPhotoView *newPhotoScrollView = [[EBPhotoView alloc]
                                        initWithFrame:viewFrame];
    [self setPhotoView:newPhotoScrollView];
    [mainView addSubview:newPhotoScrollView];
    
    [self loadCommentsView];
    
    [self beginObservations];
}

- (void)dealloc
{
    [self stopObservations];
    [self setActiveOperations:nil];
}

#pragma mark - Notifications

- (void)beginObservations
{
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardDidShow:)
                                                 name:UIKeyboardDidShowNotification object:nil];
    
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillShow:)
                                                 name:UIKeyboardWillShowNotification object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillBeHidden:)
                                                 name:UIKeyboardWillHideNotification object:nil];

    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardDidChangeFrame:)
                                                 name:UIKeyboardWillChangeFrameNotification
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(hideTags)
                                                 name:EBPhotoPagesControllerDidToggleTagsOff object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(showTags)
                                                 name:EBPhotoPagesControllerDidToggleTagsOn object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(hideComments)
                                                 name:EBPhotoPagesControllerDidToggleCommentsOff object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(showComments)
                                                 name:EBPhotoPagesControllerDidToggleCommentsOn object:nil];
    
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(cancelCommentingWithNotification:)
                                                 name:EBPhotoPagesControllerDidCancelCommentingNotification
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(deleteCellWithNotification:) name:@"CellDidRequestSelfDeletion"
                                               object:nil];

    [self addObserver:self
           forKeyPath:TagPopoversKeyPath
              options:NSKeyValueObservingOptionNew
              context:nil];
    
}

- (void)stopObservations
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [self removeObserver:self forKeyPath:TagPopoversKeyPath];
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    if([keyPath isEqualToString:TagPopoversKeyPath]){
        [[NSNotificationCenter defaultCenter] postNotificationName:EBPhotoViewControllerDidUpdateTagsNotification object:self];
    }
    
}

#pragma mark - Loading


- (void)loadCommentsView
{
    EBCommentsView *commentsView = [self.delegate commentsViewForPhotoViewController:self];
    
    [self.view addSubview:commentsView];
    [self setCommentsView:commentsView];
    [commentsView setNeedsLayout];
}



#pragma mark - Keyboard Handling


- (void)keyboardDidShow:(NSNotification*)notification
{
    NSDictionary* info = [notification userInfo];
    CGSize keyboardSize = [[info objectForKey:UIKeyboardFrameBeginUserInfoKey] CGRectValue].size;
    NSValue* value = [info objectForKey:UIKeyboardAnimationDurationUserInfoKey];
    NSTimeInterval duration;
    [value getValue:&duration];
    
    EBTagPopover *activeTagPopover = [self.photoView activeTagPopover];
    if(activeTagPopover){

        
        
        CGFloat bufferSpace = 15;
        CGRect visibleRectAboveKeyboard = self.view.bounds;
        visibleRectAboveKeyboard.size.height -= keyboardSize.height;
        visibleRectAboveKeyboard.size.height -= bufferSpace;
        
        CGPoint tagBottomPoint = CGPointMake(activeTagPopover.center.x,
                                             activeTagPopover.frame.origin.y+
                                             activeTagPopover.frame.size.height);
        
        CGPoint tagPosition = [self.photoView convertPoint:tagBottomPoint
                                                    toView:nil];
        NSLog(@"tag position is %f,%f", tagPosition.x, tagPosition.y);
        
        if (CGRectContainsPoint(visibleRectAboveKeyboard, tagPosition) == NO) {
            CGPoint adjustment = CGPointMake(0.0,
                                             -(tagPosition.y-visibleRectAboveKeyboard.size.height));
            CGPoint newCenter = CGPointMake(self.view.center.x+adjustment.x,
                                            self.view.center.y+adjustment.y);
            [UIView animateWithDuration:duration
                                  delay:0
                                options:UIViewAnimationCurveEaseOut|    UIViewAnimationOptionBeginFromCurrentState
                             animations:^{
                                 [self.view setCenter:newCenter];
                             }completion:nil];
        }
    }
}

- (void)keyboardWillShow:(NSNotification *)notification
{
    EBTagPopover *activeTagPopover = [self.photoView activeTagPopover];
    if(activeTagPopover == nil){
        
        /*NSDictionary* info = [notification userInfo];
        CGSize keyboardSize = [[info objectForKey:UIKeyboardFrameBeginUserInfoKey] CGRectValue].size;
        NSValue* value = [info objectForKey:UIKeyboardAnimationDurationUserInfoKey];
        NSTimeInterval duration;
        [value getValue:&duration];
        
        
        CGPoint adjustment = CGPointMake(0.0,
                                         -(keyboardSize.height));
        CGPoint newCenter = CGPointMake(self.commentsView.center.x+adjustment.x,
                                        self.commentsView.center.y+adjustment.y);
        [UIView animateWithDuration:duration
                              delay:0
                            options:UIViewAnimationCurveEaseOut|
         UIViewAnimationOptionBeginFromCurrentState
                         animations:^{
                             [self.commentsView setCenter:newCenter];
                         }completion:nil];*/
    }
}


- (void)keyboardWillBeHidden:(NSNotification*)notification
{
    NSDictionary* info = [notification userInfo];
    //CGSize keyboardSize = [[info objectForKey:UIKeyboardFrameBeginUserInfoKey] CGRectValue].size;
    NSValue* value = [info objectForKey:UIKeyboardAnimationDurationUserInfoKey];
    NSTimeInterval duration;
    [value getValue:&duration];
    
    //This happens because of TAGS
    [UIView animateWithDuration:duration
                          delay:0
                        options:UIViewAnimationCurveEaseOut|UIViewAnimationOptionBeginFromCurrentState
                     animations:^{
                         [self.view setFrame:self.view.bounds];
                     }completion:nil];
}

- (void)keyboardDidChangeFrame:(NSNotification *)notification
{
    NSDictionary* info = [notification userInfo];
    CGRect keyboardFrame = [[info objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue];
    keyboardFrame = [self.view convertRect:keyboardFrame fromView:nil];
    NSValue* value = [info objectForKey:UIKeyboardAnimationDurationUserInfoKey];
    NSTimeInterval duration;
    [value getValue:&duration];
    
    //NSLog(@"Keyboard frame with conversion is %f,%f,%f,%f", keyboardFrame.origin.x, keyboardFrame.origin.y, keyboardFrame.size.width, keyboardFrame.size.height);
    
    CGPoint newCenter = CGPointMake(self.commentsView.frame.size.width*0.5,
                                    keyboardFrame.origin.y - (self.commentsView.frame.size.height*0.5));
    [UIView animateWithDuration:duration
                          delay:0
                        options:UIViewAnimationCurveEaseOut|
     UIViewAnimationOptionBeginFromCurrentState
                     animations:^{
                         [self.commentsView setCenter:newCenter];
                     }completion:nil];
    
}




#pragma mark - Actions

- (void)showActivityIndicator
{
    if(self.activityIndicator){
        return;
    }
    
    UIActivityIndicatorView *activityIndicator = [[UIActivityIndicatorView alloc]
                                                  initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
    [activityIndicator setAutoresizingMask:UIViewAutoresizingFlexibleTopMargin|
                                           UIViewAutoresizingFlexibleLeftMargin|
                                           UIViewAutoresizingFlexibleRightMargin|
                                           UIViewAutoresizingFlexibleBottomMargin];
    [activityIndicator setHidesWhenStopped:NO];
    [activityIndicator startAnimating];
    
    [activityIndicator setCenter:self.view.center];
    [self.view addSubview:activityIndicator];
    [self setActivityIndicator:activityIndicator];
    
    
    if([activityIndicator isKindOfClass:[UIActivityIndicatorView class]]){
        [activityIndicator setAlpha:0];
        [UIView animateWithDuration:0.1
                              delay:0
                            options:UIViewAnimationOptionCurveEaseOut|UIViewAnimationOptionBeginFromCurrentState
                         animations:^{
                             [activityIndicator setAlpha:1];
                         }completion:nil];
    }
    
}

- (void)hideActivityIndicator
{
    if([self.activityIndicator isKindOfClass:[UIActivityIndicatorView class]]){
        UIActivityIndicatorView *indicator = (UIActivityIndicatorView *)self.activityIndicator;
        [UIView animateWithDuration:0.5
                              delay:0.0
                            options:UIViewAnimationOptionCurveEaseOut|UIViewAnimationOptionBeginFromCurrentState
                         animations:^{
                             [indicator setAlpha:0];
                         }completion:^(BOOL finished){
                             [indicator stopAnimating];
                             [self.activityIndicator removeFromSuperview];
                         }];
    } else {
        [self.activityIndicator removeFromSuperview];
    }
    
    [self setActivityIndicator:nil];
}

#pragma mark - Rotation

- (void)willAnimateRotationToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration
{
    [self.photoView setNeedsLayout];
    [self.commentsView setNeedsLayout];
}

- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation
{
    [self.photoView setNeedsLayout];
}


- (BOOL)shouldAutomaticallyForwardRotationMethods
{
    return YES;
}




@end

#pragma mark - (Image)
@implementation EBPhotoViewController (Image)

- (void)setImage:(UIImage *)image
{
    [self.photoView setImage:image];
    [[NSNotificationCenter defaultCenter] postNotificationName:EBPhotoViewControllerDidSetImageNotification object:self];
}

- (UIImage *)image
{
    return [self.photoView image];
}

@end

#pragma mark - (Captions)
@implementation EBPhotoViewController (Captions)

- (void)setCaption:(NSString *)caption
{
    _caption = caption;
    [[NSNotificationCenter defaultCenter] postNotificationName:EBPhotoViewControllerDidSetCaptionNotification object:self];
}

- (void)setAttributedCaption:(NSAttributedString *)attributedCaption
{
    _attributedCaption = attributedCaption;
    [[NSNotificationCenter defaultCenter] postNotificationName:EBPhotoViewControllerDidSetCaptionNotification object:self];
}

@end

#pragma mark - (Meta Data)
@implementation EBPhotoViewController (MetaData)

- (void)setMetaData:(NSDictionary *)metaData
{
    _metaData = metaData;
    [[NSNotificationCenter defaultCenter] postNotificationName:EBPhotoViewControllerDidSetMetaDataNotification object:self];
}

@end


#pragma mark - (Comments)
@implementation EBPhotoViewController (Comments)



- (void)setCommentsHidden:(BOOL)commentsHidden
{
    commentsHidden ? [self hideComments] : [self showComments];
}


- (void)hideComments
{
    //self.commentsAreHidden = YES;
    [self.commentsView setHidden:YES];
}

- (void)showComments
{
    //self.commentsAreHidden = NO;
    [self.commentsView setHidden:NO];
}

- (void)cancelCommentingWithNotification:(NSNotification *)aNotification
{
    [self.commentsView cancelCommenting];
}

- (void)loadComments:(NSArray *)comments
{
    [self setComments:comments];
    [self.commentsView reloadComments];
}

- (void)setCommentingEnabled:(BOOL)enableCommenting
{
    if(enableCommenting){
        [self.commentsView enableCommenting];
    } else {
        [self.commentsView disableCommenting];
    }
}

- (void)startCommenting
{
    [self.commentsView startCommenting];
}

#pragma mark - Comments Tableview Datasource & Delegate


- (void)deleteCellWithNotification:(NSNotification *)notification
{
    UITableViewCell *cell = notification.object;
    
    if([cell isKindOfClass:[UITableViewCell class]] == NO){
        return;
    }
    
    NSIndexPath *indexPath = [self.commentsView.tableView indexPathForCell:cell];
    
    if(indexPath){
        id<EBPhotoCommentProtocol>deletedComment = self.comments[indexPath.row];
        
        NSMutableArray *remainingComments = [NSMutableArray arrayWithArray:self.comments];
        [remainingComments removeObjectAtIndex:indexPath.row];
        [self setComments:[NSArray arrayWithArray:remainingComments]];
        
        [self.commentsView.tableView beginUpdates];
        [self.commentsView.tableView deleteRowsAtIndexPaths:@[indexPath]
                                           withRowAnimation:UITableViewRowAnimationLeft];
        [self.commentsView.tableView endUpdates];
        
        [self.delegate photoViewController:self didDeleteComment:deletedComment];
        
        [self.commentsView.tableView reloadData];
        
    //[self reloadData];
    }
}


- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.comments.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    EBCommentCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    
    id <EBPhotoCommentProtocol> comment = self.comments[indexPath.row];
    NSAssert([comment conformsToProtocol:@protocol(EBPhotoCommentProtocol)],
             @"Comment objects must conform to the EBPhotoCommentProtocol.");
    [self configureCell:cell
         atRowIndexPath:indexPath
            withComment:comment];
    
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    const CGFloat MinimumRowHeight = 60;
    
    id<EBPhotoCommentProtocol> comment = self.comments[indexPath.row];
    CGFloat rowHeight = 0;
    NSString *textForRow = nil;
    
    if([comment respondsToSelector:@selector(attributedCommentText)] &&
       [comment attributedCommentText]){
        textForRow = [[comment attributedCommentText] string];
    } else {
        textForRow = [comment commentText];
    }
    
    //Get values from the comment cell itself, as an abstract class perhaps.
    //OR better, from reference cells dequeued from the table
    //http://stackoverflow.com/questions/10239040/dynamic-uilabel-heights-widths-in-uitableviewcell-in-all-orientations
    /*
     NSAttributedString *attributedText = [[NSAttributedString alloc] initWithString:textForRow attributes:@{NSFontAttributeName:@"HelveticaNeue-Light"}];
     
     CGRect textViewRect = [attributedText boundingRectWithSize:(CGSize){285, CGFLOAT_MAX}
     options:NSStringDrawingUsesLineFragmentOrigin
     context:nil];
     CGSize textViewSize = textViewRect.size;
     */
    
    CGRect textViewSize = [textForRow boundingRectWithSize:CGSizeMake(285, 1000) options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName: [UIFont fontWithName:@"HelveticaNeue-Bold" size:16]} context:nil];
    CGFloat textViewHeight = 25;
    const CGFloat additionalSpace = MinimumRowHeight - textViewHeight + 10;
    
    rowHeight = textViewSize.size.height + additionalSpace;
    
    return rowHeight;
}

- (void)configureCell:(EBCommentCell *)cell
       atRowIndexPath:(NSIndexPath *)indexPath
          withComment:(id<EBPhotoCommentProtocol>)comment
{
    EBCommentsView *commentsView = [self.delegate commentsViewForPhotoViewController:self];
    
    BOOL configureCell = [self.delegate respondsToSelector:@selector(photoViewController:shouldConfigureCommentCell:forRowAtIndexPath:withComment:)] ?
            [self.delegate photoViewController:self shouldConfigureCommentCell:cell forRowAtIndexPath:indexPath withComment:comment] : YES;
    
    if([cell isKindOfClass:[EBCommentCell class]] && configureCell){
        [cell setComment:comment];
        [cell setHighlightColor:commentsView.commentCellHighlightColor];
    }
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    [cell setBackgroundColor:[UIColor clearColor]];
}

- (BOOL)tableView:(UITableView *)tableView shouldShowMenuForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return YES;
}

- (BOOL)tableView:(UITableView *)tableView canPerformAction:(SEL)action forRowAtIndexPath:(NSIndexPath *)indexPath withSender:(id)sender
{
    if (action == @selector(copy:)) {
        return YES;
    }
    
    if (action == @selector(delete:)) {
        id<EBPhotoCommentProtocol> commentToDelete = self.comments[indexPath.row];
        if([self.delegate photoViewController:self
                             canDeleteComment:commentToDelete]){
            return YES;
        }
    }
    
    return NO;
}

- (void)tableView:(UITableView *)tableView performAction:(SEL)action forRowAtIndexPath:(NSIndexPath *)indexPath withSender:(id)sender
{
    if (action == @selector(copy:)) {
        id<EBPhotoCommentProtocol> comment = self.comments[indexPath.row];
        NSString *copiedText = nil;
        if([comment respondsToSelector:@selector(attributedCommentText)]){
            copiedText = [[comment attributedCommentText] string];
        }
        
        if(copiedText == nil){
            copiedText = [comment commentText];
        }
        
        [[UIPasteboard generalPasteboard] setString:copiedText];
    } else if (action == @selector(delete:)) {
        [self tableView:tableView
     commitEditingStyle:UITableViewCellEditingStyleDelete
      forRowAtIndexPath:indexPath];
    }
}


- (UITableViewCellEditingStyle)tableView:(UITableView *)aTableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return UITableViewCellEditingStyleNone;
}


- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        id<EBPhotoCommentProtocol>deletedComment = self.comments[indexPath.row];
        
        NSMutableArray *remainingComments = [NSMutableArray arrayWithArray:self.comments];
        [remainingComments removeObjectAtIndex:indexPath.row];
        [self setComments:[NSArray arrayWithArray:remainingComments]];
        
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
        [self.delegate photoViewController:self didDeleteComment:deletedComment];
    }
    else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }
}


#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Navigation logic may go here. Create and push another view controller.
    /*
     <#DetailViewController#> *detailViewController = [[<#DetailViewController#> alloc] initWithNibName:@"<#Nib name#>" bundle:nil];
     // ...
     // Pass the selected object to the new view controller.
     [self.navigationController pushViewController:detailViewController animated:YES];
     */
}

#pragma mark - Comments View Delegate

- (void)commentsView:(id)view didPostNewComment:(NSString *)commentText
{
    [self.delegate photoViewController:self didPostNewComment:commentText];
}

#pragma mark - Comments UITextViewDelegate

#pragma mark - UITextView Delegate


- (BOOL)textViewShouldEndEditing:(UITextView *)textView
{
    //clear out text
    [textView setText:nil];
    return YES;
}

- (void)textViewDidBeginEditing:(UITextView *)textView
{
    [[NSNotificationCenter defaultCenter] postNotificationName:EBPhotoViewControllerDidBeginCommentingNotification object:self];
}


- (void)textViewDidEndEditing:(UITextView *)textView
{
    [[NSNotificationCenter defaultCenter] postNotificationName:EBPhotoViewControllerDidEndCommentingNotification object:self];
    
    [self.commentsView setInputPlaceholderEnabled:YES];
    [self.commentsView setPostButtonHidden:YES];
}

- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text
{
    //check message length
    return YES;
}


- (void)textViewDidChange:(UITextView *)textView
{
    if(textView.isFirstResponder){
        if(textView.text == nil || [textView.text isEqualToString:@""]){
            [self.commentsView setPostButtonHidden:YES];
            [self.commentsView setInputPlaceholderEnabled:YES];
        } else {
            [self.commentsView setPostButtonHidden:NO];
            [self.commentsView setInputPlaceholderEnabled:NO];
        }
    }
}



@end


#pragma mark - (Tags)
@implementation EBPhotoViewController (Tags)


- (void)setTags:(NSArray *)tagsToShow
{
    NSMutableArray *newTagPopovers = [NSMutableArray array];
    for(id<EBPhotoTagProtocol>tag in tagsToShow){
        EBTagPopover *tagPopover = [self.delegate photoViewController:self
                                                      tagPopoverForTag:tag];
        [tagPopover setNormalizedArrowPoint:tag.normalizedPosition];
        [tagPopover setDelegate:self];
        [tagPopover setAlpha:0];
        [newTagPopovers addObject:tagPopover];
    }
    
    [self setTagPopovers:[NSArray arrayWithArray:newTagPopovers]];
    
    [self setTagsHidden:self.tagsHidden];
    
    for(EBTagPopover *tagPopover in self.tagPopovers){
        [self.photoView addSubview:tagPopover];
    }
}

- (void)setTagsHidden:(BOOL)tagsHidden
{
    tagsHidden ? [self hideTags] : [self showTags];
}

- (void)showTags
{
    [self setTagsAsHidden:NO];
}

- (void)hideTags
{
    [self setTagsAsHidden:YES];
}

- (void)setTagsAsHidden:(BOOL)hidden
{
    _tagsHidden = hidden;
    CGFloat alpha = hidden ? 0 : 1;
    [UIView animateWithDuration:0.2
                          delay:0
                        options:UIViewAnimationOptionBeginFromCurrentState|
     UIViewAnimationOptionCurveEaseOut
                     animations:^{
                         
                         for(EBTagPopover *tag in self.tagPopovers){
                             if([tag isKindOfClass:[EBTagPopover class]]){
                                 [tag setAlpha:alpha];
                             }
                         }
                     }completion:^(BOOL finished){
                         for(EBTagPopover *tag in self.tagPopovers){
                             if([tag isKindOfClass:[EBTagPopover class]]){
                                 [tag setAlpha:alpha];
                             }
                         }
                     }];
}

- (void)tagPhotoAtNormalizedPoint:(CGPoint)normalizedPoint
{
    EBTagPopover *tagPopover = [[EBTagPopover alloc]
                                 initWithDelegate:self];
    
    [self startTag:tagPopover atNormalizedPoint:normalizedPoint];
}

- (void)startTag:(EBTagPopover *)tagPopover atNormalizedPoint:(CGPoint)normalizedPoint
{
    [tagPopover setDelegate:self];
    [self.photoView startNewTagPopover:tagPopover
                     atNormalizedPoint:normalizedPoint];
    
    NSMutableArray *mutableTagPopovers = [NSMutableArray arrayWithArray:self.tagPopovers];
    [mutableTagPopovers addObject:tagPopover];
    [self setTagPopovers:[NSArray arrayWithArray:mutableTagPopovers]];
}

#pragma mark - Tag Popover Delegate

- (void)tagPopoverDidEndEditing:(EBTagPopover *)tagPopover
{
    NSDictionary *tagInfo = @{@"tagPopover": tagPopover,
                              @"taggedPhotoIndex" : [NSNumber numberWithInteger:self.photoIndex]};
    
    [[NSNotificationCenter defaultCenter] postNotificationName:EBPhotoViewControllerDidCreateTagNotification object:self userInfo:tagInfo];
}

- (void)tagPopover:(EBTagPopover *)tagPopover
didReceiveSingleTap:(UITapGestureRecognizer *)singleTap

{
    [self.delegate photoViewController:self didSelectTagPopover:tagPopover];
}

@end


#pragma mark - (Operations)
@implementation EBPhotoViewController (Operations)

- (void)operationWillStartLoading:(NSOperation *)operation
{
    NSAssert(self.activeOperations, @"Must have a pendingOperations set.");
    [self.activeOperations addObject:operation];
    [self showActivityIndicator];
}

- (void)operationDidStopLoading:(NSOperation *)operation
{
    NSAssert(self.activeOperations, @"Must have a pendingOperations set.");
    NSAssert([self.activeOperations containsObject:operation], @"PendingOperations did not contain given operation.");
    
    [self.activeOperations removeObject:operation];
    if(self.activeOperations.count == 0){
        [self hideActivityIndicator];
    }
}

@end


#pragma mark -
#pragma mark -

