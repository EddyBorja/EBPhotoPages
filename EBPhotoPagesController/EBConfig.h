//
//  EBConfig.h
//  EBPhotoPagesControllerDemo
//
//  Created by Jesse Onolememen on 11/08/2017.
//  Copyright © 2017 Eddy Borja. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface EBConfig : NSObject
    
@property (nonatomic, retain) UIFont* bodyFont;
@property (nonatomic, retain) UIFont* titleFont;
@property (nonatomic, retain) UIFont* commentTitleFont;

@property (nonatomic, retain) UIColor* textColor;
@property (nonatomic, retain) UIColor* tintColor;

@property (nonatomic, retain) UIBarButtonItem* doneBarButtonItem;

@property (nonatomic, retain) NSString* postButtonTitle;

@property (nonatomic, retain) NSDateFormatter* dateFormatter;

@property BOOL shouldUseRelativeTimeFormatting;
    
/// This is the font used for the captions and comments
- (UIFont *)bodyFont;
    
/// Sets the font used for the captions and comments
- (void)setBodyFont: (UIFont *) font;
    
/// This is the font used for the comment titles
- (UIFont *)commentTitleFont;
    
/// Sets the font used for the comment avatar title
- (void)setCommentTitleFont: (UIFont *) font;
    
/// This is the font used for buttons and titles
- (UIFont *)titleFont;
    
/// Sets the font used for buttons and titles
- (void)setTitleFont: (UIFont *) font;
    
/// This is the colour for all of the titles
- (UIColor *)textColor;
    
/// Sets the colour for all of the titles
- (void)setTextColor: (UIColor *) textColor;
    
/// This is the color used for all of the buttons
- (UIColor *)tintColor;
    
/// Sets the color used for all of the buttons
- (void)setTintColor: (UIColor *) tintColor;
    
/// This is the title for the post button
- (NSString *)postButtonTitle;
    
/// Sets the title for the post button
- (void)setPostButtonTitle: (NSString *) postButtonTitle;
    
/// This is the formatter used to format the dates for each comment
- (NSDateFormatter *)dateFormatter;
    
/// Sets the formatter used to format the dates for each comment
- (void)setDateFormatter: (NSDateFormatter *) dateFormatter;
    
/// This is the formatter used to format the dates for each comment
- (BOOL)shouldUseRelativeTimeFormatting;
    
/// This is the formatter used to format the dates for each comment
- (void)setShouldUseRelativeTimeFormatting: (BOOL) shouldUseRelativeTimeFormatting;
    
/// Global configuration
+(EBConfig *)sharedConfig;

@end
