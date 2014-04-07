// 
//  Created by Eddy Borja.
//  Copyright (c) 2014 Eddy Borja. All rights reserved.
/*
 Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:
 
 The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.
 
 THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
 */

#import <Foundation/Foundation.h>
#import "EBPhotoCommentProtocol.h"

@class EBPhotoPagesController;
@class EBPhotoComment;
@class EBTagPopover;
@protocol EBPhotoPagesDataSource <NSObject>

@required
//Return YES if you plan to have an image for the given index, you will be asked for the UIImage later.
- (BOOL)photoPagesController:(EBPhotoPagesController *)photoPagesController
    shouldExpectPhotoAtIndex:(NSInteger)index;


@optional
#pragma mark - Gestures

//Return NO if you do not want the photoPagesController to do the single tap event.
- (BOOL)photoPagesController:(EBPhotoPagesController *)photoPagesController
shouldHandleSingleTapGesture:(UITapGestureRecognizer *)recognizer
             forPhotoAtIndex:(NSInteger)index;

//Return NO if you do not want the photoPagesController to do the single tap event.
- (BOOL)photoPagesController:(EBPhotoPagesController *)photoPagesController
shouldHandleDoubleTapGesture:(UITapGestureRecognizer *)recognizer
             forPhotoAtIndex:(NSInteger)index;

//Return NO if you do not want the photoPagesController to do the long press event.
- (BOOL)photoPagesController:(EBPhotoPagesController *)photoPagesController
shouldHandleLongPressGesture:(UILongPressGestureRecognizer *)recognizer
             forPhotoAtIndex:(NSInteger)index;

//Return NO if you do not want the photoPagesController to do the tap event for a tag popover
- (BOOL)photoPagesController:(EBPhotoPagesController *)photoPagesController
 shouldHandleTapOnTagPopover:(UITapGestureRecognizer *)recognizer
              inPhotoAtIndex:(NSInteger)index;


//Implement this to handle when a user has single tapped a photo with your own custom action.
- (BOOL)photoPagesController:(EBPhotoPagesController *)photoPagesController
         didReceiveSingleTap:(UITapGestureRecognizer *)singleTapGesture
             forPhotoAtIndex:(NSInteger)index;

//Implement this to handle when a user has long pressed a photo with your own custom action.
- (void)photoPagesController:(EBPhotoPagesController *)photoPagesController
         didReceiveLongPress:(UILongPressGestureRecognizer *)recognizer
             forPhotoAtIndex:(NSInteger)index;

//Implement this to handle when a user taps on a tag with your own custom action.
- (void)photoPagesController:(EBPhotoPagesController *)photoPagesController
         didSelectTagPopover:(EBTagPopover *)tagPopover
              inPhotoAtIndex:(NSInteger)index;




#pragma mark - Image Datasource methods
//Expects the UIImage object representing the photo at the specified index.
//Note: This method runs asynchronously in a background queue.
- (UIImage *)photoPagesController:(EBPhotoPagesController *)controller
                     imageAtIndex:(NSInteger)index;

- (void)photoPagesController:(EBPhotoPagesController *)controller
                imageAtIndex:(NSInteger)index
           completionHandler:(void(^)(UIImage *image))handler;

//Default value is FALSE
- (BOOL)photoPagesController:(EBPhotoPagesController *)photoPagesController
    shouldAllowDeleteForPhotoAtIndex:(NSInteger)index;

- (void)photoPagesController:(EBPhotoPagesController *)photoPagesController
       didDeletePhotoAtIndex:(NSInteger)index;

- (BOOL)photoPagesController:(EBPhotoPagesController *)photoPagesController
shouldAllowReportForPhotoAtIndex:(NSInteger)index;

- (void)photoPagesController:(EBPhotoPagesController *)photoPagesController
       didReportPhotoAtIndex:(NSInteger)index;


#pragma mark - Captions Datasource methods
//Implement these methods to return a caption string for a photo.
//For asynchronous loading that won't block the UI, use the methods with completionHandlers
//If attributedCaptionForPhotoAtIndex: is implemented, captionForPhotoAtIndex: will not be called.
- (NSAttributedString *)photoPagesController:(EBPhotoPagesController *)controller
            attributedCaptionForPhotoAtIndex:(NSInteger)index;

- (void)photoPagesController:(EBPhotoPagesController *)controller
    attributedCaptionForPhotoAtIndex:(NSInteger)index
                   completionHandler:(void(^)(NSAttributedString *attributedCaption))handler;

- (NSString *)photoPagesController:(EBPhotoPagesController *)controller
            captionForPhotoAtIndex:(NSInteger)index;

- (void)photoPagesController:(EBPhotoPagesController *)controller
      captionForPhotoAtIndex:(NSInteger)index
           completionHandler:(void(^)(NSString *caption))handler;


#pragma mark - Metadata Datasource methods
//Implement this to return your own dictionary of meta data about a photo (likes, shares, etc..)
//For asynchronous loading that won't block the UI, use metaDataForPhotoAtIndex:completionHandler:
- (NSDictionary *)photoPagesController:(EBPhotoPagesController *)controller
               metaDataForPhotoAtIndex:(NSInteger)index;

- (void)photoPagesController:(EBPhotoPagesController *)controller
     metaDataForPhotoAtIndex:(NSInteger)index
           completionHandler:(void(^)(NSDictionary *metaData))handler;

#pragma mark - ActivityViewController Datasource 
//Return an acivity view controller to use when sharing options are presented.
//If not implemented, a default activity view controller will show.
- (UIActivityViewController *)photoPagesController:(EBPhotoPagesController *)controller
                    activityViewControllerForImage:(UIImage *)image
                                       withCaption:(NSString *)caption
                                           atIndex:(NSInteger)index;

//Default value is TRUE
- (BOOL)photoPagesController:(EBPhotoPagesController *)photoPagesController
    shouldAllowActivitiesForPhotoAtIndex:(NSInteger)index;




#pragma mark - Tag Create, Read, Delete
//Called when the user adds a new tag where tagText is the string they typed in
//tagLocation is the normalized (between 0 and 1) position of the tag within it's image.
//tagInfo can carry additional information about the tag as a key value store.
- (void)photoPagesController:(EBPhotoPagesController *)photoPagesController
         didAddNewTagAtPoint:(CGPoint)tagLocation
                    withText:(NSString *)tagText
             forPhotoAtIndex:(NSInteger)index
                     tagInfo:(NSDictionary *)tagInfo;

//Expects an array of objects that implement the EBPhotoTagProtocol for the given photo at index.
//For asynchronous loading that won't block the UI, use tagsForPhotoAtIndex:completionHandler:
- (NSArray *)photoPagesController:(EBPhotoPagesController *)controller
              tagsForPhotoAtIndex:(NSInteger)index;

- (void)photoPagesController:(EBPhotoPagesController *)controller
         tagsForPhotoAtIndex:(NSInteger)index
           completionHandler:(void (^)(NSArray *tags))handler;

//Default value is TRUE
- (BOOL)photoPagesController:(EBPhotoPagesController *)photoPagesController
    shouldAllowTaggingForPhotoAtIndex:(NSInteger)index;

- (BOOL)photoPagesController:(EBPhotoPagesController *)photoPagesController
     shouldAllowDeleteForTag:(EBTagPopover *)tagPopover
              inPhotoAtIndex:(NSInteger)index;

- (void)photoPagesController:(EBPhotoPagesController *)controller
         didDeleteTagPopover:(EBTagPopover *)tagPopover
              inPhotoAtIndex:(NSInteger)index;

- (BOOL)photoPagesController:(EBPhotoPagesController *)photoPagesController
    shouldAllowEditingForTag:(EBTagPopover *)tagPopover
              inPhotoAtIndex:(NSInteger)index;


#pragma mark - Comment Create, Read, Delete

//Called when a user finishes entering a new comment. The delegate should save the comment and reload data.
- (void)photoPagesController:(EBPhotoPagesController *)controller
              didPostComment:(NSString *)commentText
             forPhotoAtIndex:(NSInteger)index;

//Expects an array of objects that implement the EBPhotoCommentProtocol for the given photo at index.
//For asynchronous loading that won't block the UI, use commentsForPhotoAtIndex:completionHandler:
- (NSArray *)photoPagesController:(EBPhotoPagesController *)controller
          commentsForPhotoAtIndex:(NSInteger)index;

- (void)photoPagesController:(EBPhotoPagesController *)controller
     commentsForPhotoAtIndex:(NSInteger)index
           completionHandler:(void (^)(NSArray *comments))handler;


- (NSInteger)photoPagesController:(EBPhotoPagesController *)controller
  numberOfcommentsForPhotoAtIndex:(NSInteger)index;

- (void)photoPagesController:(EBPhotoPagesController *)controller
numberOfcommentsForPhotoAtIndex:(NSInteger)index
           completionHandler:(void (^)(NSInteger))handler;


- (BOOL)photoPagesController:(EBPhotoPagesController *)controller
            shouldAllowDeleteForComment:(id<EBPhotoCommentProtocol>)comment
             forPhotoAtIndex:(NSInteger)index;

- (void)photoPagesController:(EBPhotoPagesController *)controller
            didDeleteComment:(id<EBPhotoCommentProtocol>)deletedComment
             forPhotoAtIndex:(NSInteger)index;

//Default value is TRUE
- (BOOL)photoPagesController:(EBPhotoPagesController *)photoPagesController
    shouldAllowCommentingForPhotoAtIndex:(NSInteger)index;

//Default value is TRUE
- (BOOL)photoPagesController:(EBPhotoPagesController *)photoPagesController
    shouldShowCommentsForPhotoAtIndex:(NSInteger)index;







@end
