// 
//  Created by Eddy Borja.
//  Copyright (c) 2014 Eddy Borja. All rights reserved.
/*
 Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:
 
 The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.
 
 THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
 */

#import <UIKit/UIKit.h>
#import "EBPhotoPagesDataSource.h"
#import "EBPhotoPagesDelegate.h"
#import "EBPhotoPagesStateDelegate.h"
#import "EBTagPopoverDelegate.h"
#import "EBPhotoViewControllerDelegate.h"

@class EBPhotoViewController;
@class EBPhotoPagesFactory;
@interface EBPhotoPagesController : UIPageViewController <UIPageViewControllerDelegate, UIPageViewControllerDataSource, UITextFieldDelegate, UIActionSheetDelegate, EBPhotoViewControllerDelegate>

@property (readonly) NSInteger currentPhotoIndex;

@property (nonatomic, strong) id<EBPhotoPagesStateDelegate> currentState;
@property (weak) id<EBPhotoPagesDelegate> photoPagesDelegate;
@property (strong) id<EBPhotoPagesDataSource> photosDataSource;
@property (strong) EBPhotoPagesFactory *photoPagesFactory;

@property (nonatomic, readonly) UIBarButtonItem *doneBarButtonItem;
@property (nonatomic, readonly) UIBarButtonItem *cancelBarButtonItem;
@property (nonatomic, readonly) UIBarButtonItem *tagBarButtonItem;
@property (nonatomic, readonly) UIBarButtonItem *doneTaggingBarButtonItem;
@property (nonatomic, readonly) UIBarButtonItem *activityBarButtonItem;
@property (nonatomic, readonly) UIBarButtonItem *miscBarButtonItem;
@property (nonatomic, readonly) UIBarButtonItem *commentsBarButtonItem;
@property (nonatomic, readonly) UIBarButtonItem *commentsExitBarButtonItem;
@property (nonatomic, readonly) UIBarButtonItem *toggleTagsBarButtonItem;


//Set to NO to prevent tags from showing on photos
@property (assign) BOOL tagsHidden;

@property (assign) BOOL commentsHidden;

- (id)initWithDataSource:(id<EBPhotoPagesDataSource>)dataSource;

- (id)initWithDataSource:(id<EBPhotoPagesDataSource>)dataSource photoAtIndex:(NSInteger)index;

- (id)initWithDataSource:(id<EBPhotoPagesDataSource>)dataSource
                delegate:(id<EBPhotoPagesDelegate>)aDelegate;

- (id)initWithDataSource:(id<EBPhotoPagesDataSource>)dataSource
                delegate:(id<EBPhotoPagesDelegate>)aDelegate
            photoAtIndex:(NSInteger)index;

- (id)initWithDataSource:(id<EBPhotoPagesDataSource>)dataSource
       photoPagesFactory:(EBPhotoPagesFactory *)factory;

- (id)initWithDataSource:(id<EBPhotoPagesDataSource>)dataSource
                delegate:(id<EBPhotoPagesDelegate>)aDelegate
       photoPagesFactory:(EBPhotoPagesFactory *)factory;

- (id)initWithDataSource:(id<EBPhotoPagesDataSource>)dataSource
                delegate:(id<EBPhotoPagesDelegate>)aDelegate
       photoPagesFactory:(EBPhotoPagesFactory *)factory
            photoAtIndex:(NSInteger)index;

- (void)dismiss;

- (void)setInterfaceHidden:(BOOL)hidden; //private
- (void)setUpperBarAlpha:(CGFloat)alpha;
- (void)setCaptionAlpha:(CGFloat)alpha;
- (void)setCommentsTableViewAlpha:(CGFloat)alpha;
- (void)setLowerBarAlpha:(CGFloat)alpha;
- (void)setLowerGradientAlpha:(CGFloat)alpha;
- (void)setLowerToolbarBackgroundForState:(EBPhotoPagesState *)state; //private
- (void)setUpperToolbarBackgroundForState:(EBPhotoPagesState *)state; //private
- (void)setTaggingLabelHidden:(BOOL)hidden;
- (void)setComments:(NSArray *)comments forPhotoAtIndex:(NSInteger)index;

- (EBPhotoViewController *)currentPhotoViewController;

- (void)enterBrowsingMode;
- (void)enterBrowsingModeWithInterfaceHidden;
- (void)enterTaggingMode; 
- (void)enterTagEntryMode;
- (void)enterCommentsMode;

- (void)setUpperToolbarItems:(NSArray *)items;
- (void)setLowerToolbarItems:(NSArray *)items;

- (void)updateTagsToggleButton;

- (void)showActionSheetForPhotoAtIndex:(NSInteger)index;

- (void)showActionSheetForTagPopover:(EBTagPopover *)tagPopover inPhotoAtIndex:(NSInteger)index;

- (void)deletePhotoAtIndex:(NSInteger)index;
- (void)deleteTagPopover:(EBTagPopover *)tagPopover inPhotoAtIndex:(NSInteger)index;

- (void)presentActivitiesForPhotoViewController:(EBPhotoViewController *)photoViewController;
- (void)cancelCurrentTagging;

- (void)startCommenting;
- (void)cancelCommenting;



- (void)didSelectActivityButton:(id)sender;
- (void)didSelectMiscButton:(id)sender;
- (void)didSelectCommentsButton:(id)sender;
- (void)didSelectDoneButton:(id)sender;
- (void)didSelectCancelButton:(id)sender;
- (void)didSelectTagButton:(id)sender;
- (void)didSelectTagDoneButton:(id)sender;
- (void)didSelectToggleTagsButton:(id)sender;



@end


