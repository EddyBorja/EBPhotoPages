//
//  Created by Eddy Borja.
//  Copyright (c) 2014 Eddy Borja. All rights reserved.
//
/*
 Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:
 
 The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.
 
 THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
 */



static NSString *EBPhotoPagesControllerWillDismissNotification = @"PhotoPagesControllerWillDismiss";
static NSString *EBPhotoPagesControllerDidDismissNotification = @"PhotoPageControllerDismissed";
static NSString *EBPhotoPagesControllerDidCancelTaggingNotification = @"PhotoPagesControllerCancelTag";
static NSString *EBPhotoPagesControllerDidToggleTagsOff = @"PhotoPagesControllerTurnTagsOff";
static NSString *EBPhotoPagesControllerDidToggleTagsOn = @"PhotoPagesControllerTurnTagsOn";
static NSString *EBPhotoPagesControllerDidToggleCommentsOff = @"PhotoPagesControllerTurnCommentsOff";
static NSString *EBPhotoPagesControllerDidToggleCommentsOn = @"PhotoPagesControllerTurnCommentsOn";
static NSString *EBPhotoPagesControllerDidCancelCommentingNotification = @"PhotoPagesControllerCancelCommenting";
#pragma unused(EBPhotoPagesControllerWillDismissNotification)
#pragma unused(EBPhotoPagesControllerDidDismissNotification)
#pragma unused(EBPhotoPagesControllerDidCancelTaggingNotification)
#pragma unused(EBPhotoPagesControllerDidToggleTagsOff)
#pragma unused(EBPhotoPagesControllerDidToggleTagsOn)
#pragma unused(EBPhotoPagesControllerDidToggleCommentsOff)
#pragma unused(EBPhotoPagesControllerDidToggleCommentsOn)
#pragma unused(EBPhotoPagesControllerDidCancelCommentingNotification)


static NSString *EBPhotoViewControllerDidSetImageNotification = @"PhotoViewControllerImageSet";
static NSString *EBPhotoViewControllerDidSetCaptionNotification = @"PhotoViewControllerCaptionSet";
static NSString *EBPhotoViewControllerDidSetMetaDataNotification = @"PhotoViewControllerMetaDataSet";
static NSString *EBPhotoViewControllerDidUpdateTagsNotification = @"PhotoViewControllerTagsUpdate";
static NSString *EBPhotoViewControllerDidUpdateCommentsNotification = @"PhotoViewControllerCommentsSet";
static NSString *EBPhotoViewControllerDidCreateTagNotification = @"PhotoViewControllerCreatedTag";
static NSString *EBPhotoViewControllerDidBeginCommentingNotification = @"PhotoViewControllerDidBeginCommenting";
static NSString *EBPhotoViewControllerDidEndCommentingNotification = @"PhotoViewControllerDidEndCommenting";
#pragma unused(EBPhotoViewControllerDidSetImageNotification)
#pragma unused(EBPhotoViewControllerDidSetCaptionNotification)
#pragma unused(EBPhotoViewControllerDidSetMetaDataNotification)
#pragma unused(EBPhotoViewControllerDidUpdateTagsNotification)
#pragma unused(EBPhotoViewControllerDidUpdateCommentsNotification)
#pragma unused(EBPhotoViewControllerDidCreateTagNotification)
#pragma unused(EBPhotoViewControllerDidBeginCommentingNotification)
#pragma unused(EBPhotoViewControllerDidEndCommentingNotification)


static NSString *EBPhotoViewSingleTapNotification = @"PhotoViewDidRecognizeSingleTapNotification";
static NSString *EBPhotoViewDoubleTapNotification = @"PhotoViewDidRecognizeDoubleTapNotification";
static NSString *EBPhotoViewTouchDidEndNotification = @"PhotoViewWasTouchedNotification";
static NSString *EBPhotoViewLongPressNotification = @"PhotoViewDidRecognizeLongPressNotification";
#pragma unused(EBPhotoViewSingleTapNotification)
#pragma unused(EBPhotoViewDoubleTapNotification)
#pragma unused(EBPhotoViewTouchDidEndNotification)
#pragma unused(EBPhotoViewLongPressNotification)
