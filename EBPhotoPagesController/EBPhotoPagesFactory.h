// 
//  Created by Eddy Borja.
//  Copyright (c) 2014 Eddy Borja. All rights reserved.
/*
 Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:
 
 The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.
 
 THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
 */

#import <Foundation/Foundation.h>
#import "EBPhotoTagProtocol.h"

/*
 EBPhotoPagesFactory is an abstract class responsible for creating all kinds
 of controls for a photo pages controller.
 */

@class EBPhotoPagesController;
@class EBShadedView;
@class EBCaptionView;
@class EBPhotoPagesState;
@class EBPhotoViewController;
@class EBTagPopover;
@class EBCommentsView;
@interface EBPhotoPagesFactory : NSObject

- (EBPhotoViewController *)photoViewControllerWithIndex:(NSInteger)index
                                 forPhotoPagesController:(EBPhotoPagesController *)controller;

- (EBShadedView *)upperGradientViewForPhotoPagesController:(EBPhotoPagesController *)controller;
- (EBShadedView *)lowerGradientViewForPhotoPagesController:(EBPhotoPagesController *)controller;

- (EBShadedView *)screenDimmerForPhotoPagesController:(EBPhotoPagesController *)controller;

- (EBTagPopover *)photoPagesController:(EBPhotoPagesController *)controller
                       tagPopoverForTag:(id<EBPhotoTagProtocol>)tag
                         inPhotoAtIndex:(NSInteger)index;

- (EBCommentsView *)photoPagesController:(EBPhotoPagesController *)photoPagesController
       commentsViewForPhotoViewController:(EBPhotoViewController *)photoViewController;

- (Class)commentCellClass;

- (UINib *)commentCellNib;

- (UIToolbar *)upperToolbarForPhotoPagesController:(EBPhotoPagesController *)controller;
- (UIToolbar *)lowerToolbarForPhotoPagesController:(EBPhotoPagesController *)controller;
- (NSArray *)upperToolbarItemsForPhotoPagesController:(EBPhotoPagesController *)controller
                                              inState:(EBPhotoPagesState *)state;
- (NSArray *)lowerToolbarItemsForPhotoPagesController:(EBPhotoPagesController *)controller
                                              inState:(EBPhotoPagesState *)state;

- (EBCaptionView *)captionViewForPhotoPagesController:(EBPhotoPagesController *)controller;

- (UILabel *)taggingLabelForPhotoPagesController:(EBPhotoPagesController *)controller;

- (UIBarButtonItem *)doneBarButtonItemForPhotoPagesController:(EBPhotoPagesController *)controller;
- (UIBarButtonItem *)cancelBarButtonItemForPhotoPagesController:(EBPhotoPagesController *)controller;
- (UIBarButtonItem *)tagBarButtonItemForPhotoPagesController:(EBPhotoPagesController *)controller;
- (UIBarButtonItem *)doneTaggingBarButtonItemForPhotoPagesController:(EBPhotoPagesController *)controller;


- (UIActionSheet *)photoPagesController:(EBPhotoPagesController *)controller
               actionSheetForTagPopover:(EBTagPopover *)tagPopover
                         inPhotoAtIndex:(NSInteger)index;
- (UIActionSheet *)photoPagesController:(EBPhotoPagesController *)controller
             actionSheetForPhotoAtIndex:(NSInteger)index;
- (NSInteger)tagIdForTagActionSheet;
- (NSInteger)tagIdForPhotoActionSheet;
- (NSString *)actionSheetReportButtonTitle;
- (NSString *)actionSheetDeleteButtonTitle;
- (NSString *)actionSheetCancelButtonTitle;
- (NSString *)actionSheetTagPhotoButtonTitle;

- (UIBarButtonItem *)barButtonItemWithTitle:(NSString *)title
                                      style:(UIBarButtonItemStyle)style
                                     target:(id)aTarget
                                   selector:(SEL)aSelector;

- (UIBarButtonItem *)flexibleSpaceItemForPhotoPagesController:(EBPhotoPagesController *)controller;

- (NSString *)doneBarButtonTitleForPhotoPagesController:(EBPhotoPagesController *)controller;
- (NSString *)cancelBarButtonTitleForPhotoPagesController:(EBPhotoPagesController *)controller;
- (NSString *)tagBarButtonTitleForPhotoPagesController:(EBPhotoPagesController *)controller;
- (NSString *)doneTaggingBarButtonTitleForPhotoPagesController:(EBPhotoPagesController *)controller;

- (UIBarButtonItem *)activityBarButtonItemForPhotoPagesController:(EBPhotoPagesController *)controller;
- (UIBarButtonItem *)miscBarButtonItemForPhotoPagesController:(EBPhotoPagesController *)controller;
- (UIBarButtonItem *)commentsExitBarButtonItemForPhotoPagesController:(EBPhotoPagesController *)controller
                                                                count:(NSInteger)numberOfComments;
- (UIBarButtonItem *)commentsBarButtonItemForPhotoPagesController:(EBPhotoPagesController *)controller
                                                            count:(NSInteger)numberOfComments;
- (UIBarButtonItem *)toggleTagsBarButtonItemForPhotoPagesController:(EBPhotoPagesController *)controller;

- (UIActivityViewController *)activityViewControllerForPhotoPagesController:(EBPhotoPagesController *)controller
                                                                  withImage:(UIImage *)anImage
                                                                    caption:(NSString*)aCaption;


- (UIImage *)upperToolbarBackgroundForPhotoPagesController:(EBPhotoPagesController *)controller
                                                   inState:(EBPhotoPagesState *)state;
- (UIImage *)lowerToolbarBackgroundForPhotoPagesController:(EBPhotoPagesController *)controller
                                                   inState:(EBPhotoPagesState *)state;

- (UIImage *)defaultUpperToolbarBackgroundForPhotoPagesController:(EBPhotoPagesController *)controller;
- (UIImage *)defaultLowerToolbarBackgroundForPhotoPagesController:(EBPhotoPagesController *)controller;
- (UIImage *)defaulToolbarBackgroundForPhotoPagesController:(EBPhotoPagesController *)controller;

- (UIImage *)iconForToggleTagsBarButtonItemForPhotoPagesController:(EBPhotoPagesController *)controller
                                                          forState:(UIControlState)state;
- (UIImage *)iconForMiscBarButtonItemForPhotoPagesController:(EBPhotoPagesController *)controller
                                                    forState:(UIControlState)state;
- (UIImage *)iconForCommentsBarButtonItemForPhotoPagesController:(EBPhotoPagesController *)controller
                                                        forState:(UIControlState)state
                                                       withCount:(NSInteger)count;

@end
