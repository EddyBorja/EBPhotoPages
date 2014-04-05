//
//  DEMOComment.m
//  EBPhotoPagesControllerDemo
//
//  Created by Eddy Borja.
//  Copyright (c) 2014 Eddy Borja. All rights reserved.
//
/*
 Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:
 
 The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.
 
 THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
 */

#import "DEMOComment.h"

@implementation DEMOComment

+ (instancetype)commentWithProperties:(NSDictionary*)commentInfo
{
    return [[DEMOComment alloc] initWithProperties:commentInfo];
}

- (id)initWithProperties:(NSDictionary *)commentInfo
{
    self = [super init];
    if (self) {
        [self setText:commentInfo[@"commentText"]];
        [self setAttributedText:commentInfo[@"attributedCommentText"]];
        [self setDate:commentInfo[@"commentDate"]];
        [self setName:commentInfo[@"authorName"]];
        [self setImage:commentInfo[@"authorImage"]];
        [self setMetaData:commentInfo[@"metaData"]];
    }
    return self;
}

- (NSAttributedString *)attributedCommentText
{
    return self.attributedText;
}

- (NSString *)commentText
{
    return self.text;
}

//This is the date when the comment was posted.
- (NSDate *)postDate
{
    return self.date;
}

//This is the name that will be displayed for whoever posted the comment.
- (NSString *)authorName
{
    return self.name;
}

//This is an image of the person who posted the comment
- (UIImage *)authorAvatar
{
    return self.image;
}

@end
