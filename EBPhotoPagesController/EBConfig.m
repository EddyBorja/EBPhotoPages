//
//  EBConfig.m
//  EBPhotoPagesControllerDemo
//
//  Created by Jesse Onolememen on 11/08/2017.
//  Copyright © 2017 Eddy Borja. All rights reserved.
//

#import "EBConfig.h"

@implementation EBConfig
    
@synthesize bodyFont = _bodyFont;
@synthesize titleFont = _titleFont;
@synthesize commentTitleFont = _commentTitleFont;

@synthesize textColor = _textColor;
@synthesize tintColor = _tintColor;
@synthesize postButtonBackgroundColor = _postButtonBackgroundColor;
    
@synthesize postButtonTitle = _postButtonTitle;
    
@synthesize dateFormatter = _dateFormatter;
@synthesize shouldUseRelativeTimeFormatting = _shouldUseRelativeTimeFormatting;
    
+ (EBConfig *)sharedConfig {
    static EBConfig *sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[EBConfig alloc] init];
    });
    return sharedInstance;
}
    
#pragma mark Body Font
    
- (UIFont *)bodyFont {
    return _bodyFont;
}
    
- (void)setBodyFont: (UIFont *) font {
    _bodyFont = font;
}
    
#pragma mark Title Font
    
- (UIFont *)titleFont {
    return _titleFont;
}
    
- (void)setTitleFont: (UIFont *) font {
    _titleFont = font;
}
    
#pragma mark Comment Title Font
    
- (UIFont *)commentTitleFont {
    return _commentTitleFont;
}
    
- (void)setCommentTitleFont:(UIFont *)font {
    _commentTitleFont = font;
}
    
#pragma mark Text Color
    
- (UIColor *)textColor {
    return _textColor;
}
    
- (void)setTextColor: (UIColor *) textColor {
    _textColor = textColor;
}
    
#pragma mark Tint Color
    
- (UIColor *)tintColor {
    return _tintColor;
}
    
- (void)setTintColor:(UIColor *)tintColor {
    _tintColor = tintColor;
}
    
#pragma mark Date Formatter
    
- (NSDateFormatter *)dateFormatter {
    return _dateFormatter;
}
    
- (void)setDateFormatter:(NSDateFormatter *)dateFormatter {
    _dateFormatter = dateFormatter;
}
    
#pragma mark Post Button Title
    
- (NSString *)postButtonTitle {
    return _postButtonTitle;
}
    
- (void)setPostButtonTitle:(NSString *)postButtonTitle {
    _postButtonTitle = postButtonTitle;
}
    
#pragma mark Post Button Background Color
- (UIColor *)postButtonBackgroundColor {
    return _postButtonBackgroundColor;
}
    
- (void)setPostButtonBackgroundColor:(UIColor *)postButtonBackgroundColor {
    _postButtonBackgroundColor = postButtonBackgroundColor;
}

#pragma mark Relative Timing

- (BOOL)shouldUseRelativeTimeFormatting {
    return _shouldUseRelativeTimeFormatting;
}
    
- (void)setShouldUseRelativeTimeFormatting:(BOOL)shouldUseRelativeTimeFormatting {
    _shouldUseRelativeTimeFormatting = shouldUseRelativeTimeFormatting;
}
    
    
@end
