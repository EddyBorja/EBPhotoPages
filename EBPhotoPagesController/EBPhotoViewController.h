//
//  Created by Eddy Borja.
//  Copyright (c) 2014 Eddy Borja. All rights reserved.
//
/*
 Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:
 
 The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.
 
 THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
 */



#import <UIKit/UIKit.h>
#import "EBPhotoViewControllerDelegate.h"
#import "EBTagPopoverDelegate.h"
#import "EBCommentsViewDelegate.h"



/*EBPhotoViewController is a subclass of UIViewController that holds an imageview for a photo for interacting with, and other associated content
 
 You shouldn't have to create an EBPhotoViewController instance directly unless you're doing very custom behavior.
 */



@class EBPhotoView;
@class EBCommentsView;
@interface EBPhotoViewController : UIViewController 

@property (weak) id <EBPhotoViewControllerDelegate> delegate;

@property (readonly) NSInteger photoIndex;

@property (weak, readonly) EBPhotoView *photoView;
@property (weak, readonly) EBCommentsView *commentsView;
@property (strong, readonly) UIView *activityIndicator;
@property (readonly) NSArray *tagPopovers;
@property (strong) NSArray *comments;
@property (nonatomic, readonly) NSString *caption;
@property (nonatomic, readonly) NSAttributedString *attributedCaption;
@property (nonatomic, readonly) NSDictionary *metaData;
@property (readonly) BOOL tagsHidden;

- (id)initWithIndex:(NSInteger)photoIndex delegate:(id<EBPhotoViewControllerDelegate>)aDelegate;
@end


#pragma mark -
@interface EBPhotoViewController (Image)
- (UIImage *)image;
- (void)setImage:(UIImage *)image;
@end


#pragma mark -
@interface EBPhotoViewController (Captions)
- (void)setCaption:(NSString *)caption;
- (void)setAttributedCaption:(NSAttributedString *)attributedCaption;
@end


#pragma mark -
@interface EBPhotoViewController (MetaData)
- (void)setMetaData:(NSDictionary *)metaData;
@end


#pragma mark -
@interface EBPhotoViewController (Tags) <EBTagPopoverDelegate>
- (void)setTags:(NSArray *)tags;
- (void)setTagsHidden:(BOOL)tagsHidden;
- (void)tagPhotoAtNormalizedPoint:(CGPoint)normalizedPoint;
- (void)startTag:(EBTagPopover *)tagPopover atNormalizedPoint:(CGPoint)normalizedPoint;

- (void)hideTags;
- (void)showTags;
@end


#pragma mark -
@interface EBPhotoViewController (Comments) <UITableViewDataSource, UITableViewDelegate, UITextViewDelegate, EBCommentsViewDelegate>

- (void)deleteCellWithNotification:(NSNotification *)notification;
- (void)setCommentsHidden:(BOOL)commentsHidden;
- (void)loadComments:(NSArray *)comments;
- (void)setCommentingEnabled:(BOOL)enableCommenting;
- (void)startCommenting;
- (void)hideComments;
- (void)showComments;
- (void)cancelCommentingWithNotification:(NSNotification *)notification;

@end


#pragma mark -
@interface EBPhotoViewController (Operations)
- (void)operationWillStartLoading:(NSOperation *)operation;
- (void)operationDidStopLoading:(NSOperation *)operation;
@end