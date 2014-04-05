//
//  Created by Eddy Borja.
//  Copyright (c) 2014 Eddy Borja. All rights reserved.
/*
 Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:
 
 The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.
 
 THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
 */


#import "EBPhotoPagesState.h"
#import "EBPhotoPagesController.h"
#import "EBTagPopover.h"
#import "EBPhotoView.h"
#import "EBPhotoViewController.h"
#import "EBPhotoPagesFactory.h"

@implementation EBPhotoPagesState

#pragma mark - Transitions

- (void)photoPagesController:(EBPhotoPagesController *)controller
      didTransitionFromState:(EBPhotoPagesState *)previousState{}

- (void)photoPagesController:(EBPhotoPagesController *)controller
       willTransitionToState:(EBPhotoPagesState *)nextState{}

- (void)photoPagesController:(EBPhotoPagesController *)controller
  didTransitionToPageAtIndex:(NSInteger)pageIndex{};

#pragma mark - Button Hooks

- (void)photoPagesController:(EBPhotoPagesController *)controller
         didSelectDoneButton:(id)sender{}

- (void)photoPagesController:(EBPhotoPagesController *)controller
       didSelectCancelButton:(id)sender{}

- (void)photoPagesController:(EBPhotoPagesController *)controller
       didSelectTagButton:(id)sender{}

- (void)photoPagesController:(EBPhotoPagesController *)controller
     didSelectActivityButton:(id)sender{}

- (void)photoPagesController:(EBPhotoPagesController *)controller
         didSelectMiscButton:(id)sender{}

- (void)photoPagesController:(EBPhotoPagesController *)controller
     didSelectCommentsButton:(id)sender{}

- (void)photoPagesController:(EBPhotoPagesController *)controller
   didSelectToggleTagsButton:(id)sender{}

- (void)photoPagesController:(EBPhotoPagesController *)controller
  didSelectPostCommentButton:(id)sender{}

- (void)photoPagesController:(EBPhotoPagesController *)controller
         didSelectTagPopover:(EBTagPopover *)tagPopover
              inPhotoAtIndex:(NSInteger)index{}

#pragma mark - Events

- (void)photoPagesControllerDidFinishLoadingView:(EBPhotoPagesController *)controller{}

- (void)photoPagesController:(EBPhotoPagesController *)controller
 didTouchPhotoViewController:(EBPhotoViewController *)photoViewController
           atNormalizedPoint:(CGPoint)normalizedTouchPoint{}

- (void)photoPagesController:(EBPhotoPagesController *)controller
         didReceiveSingleTap:(UITapGestureRecognizer *)singleTapGesture
            withNotification:(NSNotification *)aNotification{}

- (void)photoPagesController:(EBPhotoPagesController *)controller
         didReceiveDoubleTap:(UITapGestureRecognizer *)doubleTapGesture
            withNotification:(NSNotification *)aNotification{}

- (void)photoPagesController:(EBPhotoPagesController *)controller
         didReceiveLongPress:(UILongPressGestureRecognizer *)longPressGesture
            withNotification:(NSNotification *)aNotification{}

- (void)photoPagesController:(EBPhotoPagesController *)controller
          didFinishAddingTag:(EBTagPopover *)tagPopover
            forPhotoAtIndex:(NSInteger)index{}

- (void)photoPagesController:(EBPhotoPagesController *)controller
          textFieldDidReturn:(UITextField *)textField{}

#pragma mark - Rotation

- (BOOL)shouldAutorotatePhotoPagesController:(EBPhotoPagesController *)controller
{
    return YES;
}

@end


#pragma mark -
#pragma mark - EBPhotoPagesStateUninitialized
@implementation EBPhotoPagesStateUninitialized

- (void)photoPagesControllerDidFinishLoadingView:(EBPhotoPagesController *)controller
{
    [controller enterBrowsingMode];
}

@end


#pragma mark -
#pragma mark - EBPhotoPagesStateBrowsing
@implementation EBPhotoPagesStateBrowsing


- (void)photoPagesController:(EBPhotoPagesController *)controller
       willTransitionToState:(EBPhotoPagesState *)nextState
{
    
}


- (void)photoPagesController:(EBPhotoPagesController *)controller
         didSelectMiscButton:(id)sender
{
    NSInteger photoIndex = [controller currentPhotoIndex];
    [controller showActionSheetForPhotoAtIndex:photoIndex];
}


- (void)photoPagesController:(EBPhotoPagesController *)controller
     didSelectCommentsButton:(id)sender
{
    [controller enterCommentsMode];
}

- (void)photoPagesController:(EBPhotoPagesController *)controller
         didSelectDoneButton:(id)sender
{
    [controller dismiss];
}

- (void)photoPagesController:(EBPhotoPagesController *)controller
          didSelectTagButton:(id)sender
{
    [controller enterTaggingMode];
}

- (void)photoPagesController:(EBPhotoPagesController *)controller
 didTouchPhotoViewController:(EBPhotoViewController *)photoViewController
           atNormalizedPoint:(CGPoint)normalizedTouchPoint
{
    [photoViewController.photoView bouncePhoto];
}


- (void)photoPagesController:(EBPhotoPagesController *)controller
         didReceiveLongPress:(UILongPressGestureRecognizer *)longPressGesture
            withNotification:(NSNotification *)aNotification
{
    if(longPressGesture.state == UIGestureRecognizerStateBegan){
        NSNumber *photoIndex = aNotification.userInfo[@"currentPhotoIndex"];
        
        if([controller.photosDataSource respondsToSelector:@selector(photoPagesController:didReceiveLongPress:forPhotoAtIndex:)])
        {
            [controller.photosDataSource photoPagesController:controller
                                          didReceiveLongPress:longPressGesture
                                              forPhotoAtIndex:[photoIndex integerValue]];
            
        } else {
            [controller showActionSheetForPhotoAtIndex:[photoIndex integerValue]];
        }
    }
}


- (void)photoPagesController:(EBPhotoPagesController *)controller
         didReceiveSingleTap:(UITapGestureRecognizer *)singleTapGesture
            withNotification:(NSNotification *)aNotification
{
    [controller enterBrowsingModeWithInterfaceHidden];
}


- (void)photoPagesController:(EBPhotoPagesController *)controller
         didReceiveDoubleTap:(UITapGestureRecognizer *)doubleTapGesture
            withNotification:(NSNotification *)aNotification
{
    if([aNotification.object isKindOfClass:[EBPhotoView class]]){
        EBPhotoView *photoView = aNotification.object;
        [photoView zoomToPoint:[doubleTapGesture locationInView:photoView]];
    }
}

- (void)photoPagesController:(EBPhotoPagesController *)controller didSelectActivityButton:(id)sender
{
    EBPhotoViewController *photoViewController = [controller currentPhotoViewController];    
    [controller presentActivitiesForPhotoViewController:photoViewController];
}


- (void)photoPagesController:(EBPhotoPagesController *)controller
   didSelectToggleTagsButton:(id)sender
{
    [controller setTagsHidden:!controller.tagsHidden];
}


- (void)photoPagesController:(EBPhotoPagesController *)controller
         didSelectTagPopover:(EBTagPopover *)tagPopover
              inPhotoAtIndex:(NSInteger)index
{
    if([controller.photosDataSource respondsToSelector:@selector(photoPagesController:didSelectTagPopover:inPhotoAtIndex:)]){
        
        [controller.photosDataSource photoPagesController:controller
                                      didSelectTagPopover:tagPopover
                                           inPhotoAtIndex:index];
    } else {
        [controller showActionSheetForTagPopover:tagPopover inPhotoAtIndex:index];
    }
}

@end


#pragma mark -
#pragma mark - EBPhotoPagesStateBrowsingInterfaceHidden
@implementation EBPhotoPagesStateBrowsingInterfaceHidden

- (void)photoPagesController:(EBPhotoPagesController *)controller
      didTransitionFromState:(EBPhotoPagesState *)previousState
{
    [controller setInterfaceHidden:YES];
}


- (void)photoPagesController:(EBPhotoPagesController *)controller
       willTransitionToState:(EBPhotoPagesState *)nextState
{
    [controller setInterfaceHidden:NO];
}


- (void)photoPagesController:(EBPhotoPagesController *)controller
         didReceiveSingleTap:(UITapGestureRecognizer *)singleTapGesture
            withNotification:(NSNotification *)aNotification
{
    [controller enterBrowsingMode];
}


@end


#pragma mark -
#pragma mark - EBPhotoPagesStateTaggingNew
@implementation EBPhotoPagesStateTaggingNew


- (void)photoPagesController:(EBPhotoPagesController *)controller
      didTransitionFromState:(EBPhotoPagesState *)previousState
{
    [controller setCaptionAlpha:0];
    [controller setLowerBarAlpha:0];
    [controller setTaggingLabelHidden:YES];
}

- (void)photoPagesController:(EBPhotoPagesController *)controller willTransitionToState:(EBPhotoPagesState *)nextState
{
    
}

- (void)photoPagesController:(EBPhotoPagesController *)controller
          didFinishAddingTag:(EBTagPopover *)tagPopover
             forPhotoAtIndex:(NSInteger)index
{
    id<EBPhotoPagesDataSource> datasource = controller.photosDataSource;
    if([datasource respondsToSelector:@selector(photoPagesController:
                                                             didAddNewTagAtPoint:
                                                             withText:
                                                             forPhotoAtIndex:
                                                             tagInfo:)]){
        
        [datasource  photoPagesController:controller
                    didAddNewTagAtPoint:tagPopover.normalizedArrowPoint
                               withText:tagPopover.text
                        forPhotoAtIndex:index
                                tagInfo:nil];
    }
    
    //[tagPopover removeFromSuperview];
    [controller enterTaggingMode];
}


- (void)photoPagesController:(EBPhotoPagesController *)controller
       didSelectCancelButton:(id)sender
{
    [controller cancelCurrentTagging];
    [controller enterTaggingMode];
}

- (void)photoPagesController:(EBPhotoPagesController *)controller didTransitionToPageAtIndex:(NSInteger)pageIndex
{
    [controller cancelCurrentTagging];
    [controller enterBrowsingMode];
}

@end


#pragma mark -
#pragma mark - EBPhotoPagesStateTaggingIdle
@implementation EBPhotoPagesStateTaggingIdle

- (void)photoPagesController:(EBPhotoPagesController *)controller
 didTouchPhotoViewController:(EBPhotoViewController *)photoViewController
        atNormalizedPoint:(CGPoint)normalizedTouchPoint
{
    BOOL taggingIsAllowed = [controller.photosDataSource respondsToSelector:
                         @selector(photoPagesController:shouldAllowTaggingForPhotoAtIndex:)] ?
    [controller.photosDataSource photoPagesController:controller
                    shouldAllowTaggingForPhotoAtIndex:photoViewController.photoIndex] : YES;
    
    if(taggingIsAllowed &&
       [photoViewController.photoView canTagPhotoAtNormalizedPoint:normalizedTouchPoint]){
        [controller enterTagEntryMode];
        [photoViewController tagPhotoAtNormalizedPoint:normalizedTouchPoint];
    }
    
 
}

- (void)photoPagesController:(EBPhotoPagesController *)controller
      didTransitionFromState:(EBPhotoPagesState *)previousState
{
    [controller setTagsHidden:NO];
    [controller setCaptionAlpha:0];
    [controller setLowerBarAlpha:0];
    [controller setTaggingLabelHidden:NO];
}

- (void)photoPagesController:(EBPhotoPagesController *)controller willTransitionToState:(EBPhotoPagesState *)nextState
{
    [controller setTaggingLabelHidden:YES];
    [controller setCaptionAlpha:1.0];
    [controller setLowerBarAlpha:1.0];
}

- (void)photoPagesController:(EBPhotoPagesController *)controller
         didSelectDoneButton:(id)sender
{
    [controller enterBrowsingMode];
}

- (void)photoPagesController:(EBPhotoPagesController *)controller
  didTransitionToPageAtIndex:(NSInteger)pageIndex
{
    [controller enterBrowsingMode];
}

@end


#pragma mark -
#pragma mark - EBPhotoPagesStateCommentingIdle
@implementation EBPhotoPagesStateCommentingIdle

- (void)photoPagesController:(EBPhotoPagesController *)controller
      didTransitionFromState:(EBPhotoPagesState *)previousState
{
    //[controller setTagsHidden:NO];
    [controller setCaptionAlpha:0];
    [controller setLowerGradientAlpha:0];
    [controller setCommentsHidden:NO];
    //[controller startCommenting];
    
}

- (void)photoPagesController:(EBPhotoPagesController *)controller
       willTransitionToState:(EBPhotoPagesState *)nextState
{
    [controller setCaptionAlpha:1];
    [controller setLowerGradientAlpha:1];
    [controller setCommentsHidden:YES];
}

- (void)photoPagesController:(EBPhotoPagesController *)controller
     didSelectCommentsButton:(id)sender
{
    [controller enterBrowsingMode];
}

@end


#pragma mark -
#pragma mark - EBPhotoPagesStateCommentingNew
@implementation EBPhotoPagesStateCommentingNew

- (void)photoPagesController:(EBPhotoPagesController *)controller
      didTransitionFromState:(EBPhotoPagesState *)previousState
{
    [controller setCaptionAlpha:0];
    [controller setLowerGradientAlpha:0];
    [controller setCommentsHidden:NO];
}



- (void)photoPagesController:(EBPhotoPagesController *)controller
       didSelectCancelButton:(id)sender
{
    [controller cancelCommenting];
}

- (void)photoPagesController:(EBPhotoPagesController *)controller didTransitionToPageAtIndex:(NSInteger)pageIndex
{
    [controller cancelCommenting];
}

@end
