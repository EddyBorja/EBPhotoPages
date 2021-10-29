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
#import <UIKit/UIKit.h>

/*
 The EBPhotoTagProtocol should be implemented by an object
 that owns tag information about a photo.
 */

@protocol EBPhotoTagProtocol <NSObject>

/*A tag's position is an x,y coordinate where x and y are normalized to be between 0 and 1.
 A tag at the exact center of an image would have the coordinates (0.5,0.5). The top left corner
 of an image is (0,0) and the bottom right is (1,1). Since the position is normalized, a tag's 
 position is independent of any particular scale factor applied to an image's width or height.
 */
- (CGPoint)normalizedPosition;

@optional

/*This is the text that appears on the tag. Atleast one of these two methods should be implemented for
any text to show on the tag view. attributedTagText takes priority over tagText.*/
- (NSAttributedString *)attributedTagText;
- (NSString *)tagText;

//This may contain additional application specific information you want to provide about the tag.
- (NSDictionary *)metaInfo;


@end
