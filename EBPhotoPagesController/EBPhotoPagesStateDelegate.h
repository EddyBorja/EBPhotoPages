//
//  Created by Eddy Borja.
//  Copyright (c) 2014 Eddy Borja. All rights reserved.
//
/*
 Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:
 
 The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.
 
 THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
 */


#import <Foundation/Foundation.h>

@class EBPhotoPagesController;
@class EBTagPopover;
@class EBPhotoPagesState;
@class EBPhotoView;
@class EBPhotoViewController;
@protocol EBPhotoPagesStateDelegate <NSObject>

#pragma mark - Transitions

- (void)photoPagesController:(EBPhotoPagesController *)controller
      didTransitionFromState:(EBPhotoPagesState *)previousState;

- (void)photoPagesController:(EBPhotoPagesController *)controller
     willTransitionToState:(EBPhotoPagesState *)nextState;

- (void)photoPagesController:(EBPhotoPagesController *)controller
  didTransitionToPageAtIndex:(NSInteger)pageIndex;

#pragma mark - Button Hooks


- (void)photoPagesController:(EBPhotoPagesController *)controller
         didSelectDoneButton:(id)sender;

- (void)photoPagesController:(EBPhotoPagesController *)controller
         didSelectCancelButton:(id)sender;

- (void)photoPagesController:(EBPhotoPagesController *)controller
            didSelectTagButton:(id)sender;

- (void)photoPagesController:(EBPhotoPagesController *)controller
         didSelectActivityButton:(id)sender;


- (void)photoPagesController:(EBPhotoPagesController *)controller
         didSelectMiscButton:(id)sender;

- (void)photoPagesController:(EBPhotoPagesController *)controller
         didSelectCommentsButton:(id)sender;

- (void)photoPagesController:(EBPhotoPagesController *)controller
   didSelectToggleTagsButton:(id)sender;

- (void)photoPagesController:(EBPhotoPagesController *)controller
  didSelectPostCommentButton:(id)sender;

- (void)photoPagesController:(EBPhotoPagesController *)controller
         didSelectTagPopover:(EBTagPopover *)tagPopover
              inPhotoAtIndex:(NSInteger)index;

#pragma mark - Events

- (void)photoPagesControllerDidFinishLoadingView:(EBPhotoPagesController *)controller;

- (void)photoPagesController:(EBPhotoPagesController *)controller
 didTouchPhotoViewController:(EBPhotoViewController *)photoViewController
           atNormalizedPoint:(CGPoint)normalizedTouchPoint;

- (void)photoPagesController:(EBPhotoPagesController *)controller
         didReceiveSingleTap:(UITapGestureRecognizer *)singleTapGesture
            withNotification:(NSNotification *)aNotification;

- (void)photoPagesController:(EBPhotoPagesController *)controller
         didReceiveDoubleTap:(UITapGestureRecognizer *)doubleTapGesture
            withNotification:(NSNotification *)aNotification;

- (void)photoPagesController:(EBPhotoPagesController *)controller
         didReceiveLongPress:(UILongPressGestureRecognizer *)longPressGesture
            withNotification:(NSNotification *)aNotification;

- (void)photoPagesController:(EBPhotoPagesController *)controller
         didFinishAddingTag:(EBTagPopover *)tagPopover
            forPhotoAtIndex:(NSInteger)index;

- (void)photoPagesController:(EBPhotoPagesController *)controller
          textFieldDidReturn:(UITextField *)textField;

#pragma mark - Rotation

- (BOOL)shouldAutorotatePhotoPagesController:(EBPhotoPagesController *)controller;

@end
