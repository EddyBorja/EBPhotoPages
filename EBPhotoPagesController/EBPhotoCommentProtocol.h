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

/*
 The EBPhotoCommentProtocol should be implemented by an object
 that owns comment information about a photo.
 */
@protocol EBPhotoCommentProtocol <NSObject>

@optional

/* At least one of these two methods should be implemented. attributedCommentText takes priority over commentText*/
- (NSAttributedString *)attributedCommentText;
- (NSString *)commentText;

//This is the date when the comment was posted.
- (NSDate *)postDate;

//This is the name that will be displayed for whoever posted the comment.
- (NSString *)authorName;

//This is an image of the person who posted the comment
- (UIImage *)authorAvatar;

//This may contain additional application specific information you want to provide about the comment.
- (NSDictionary *)metaInfo;

@end
