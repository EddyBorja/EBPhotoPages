//
//  NSDate+TimeAgo.m
//  EBPhotoPagesControllerDemo
//
//  Created by Jesse Onolememen on 11/08/2017.
//  Copyright © 2017 Eddy Borja. All rights reserved.
//

#import "NSDate+TimeAgo.h"

@implementation NSDate (TimeAgo)
    
    
    - (NSString *)relativeDateString
    {
        const int SECOND = 1;
        const int MINUTE = 60 * SECOND;
        const int HOUR = 60 * MINUTE;
        const int DAY = 24 * HOUR;
        const int MONTH = 30 * DAY;
        
        NSDate *now = [NSDate date];
        NSTimeInterval delta = [self timeIntervalSinceDate:now] * -1.0;
        
        NSCalendar *calendar = [NSCalendar currentCalendar];
        NSCalendarUnit unitFlags = NSCalendarUnitYear | NSCalendarUnitMonth |  NSCalendarUnitDay | NSCalendarUnitHour | NSCalendarUnitMinute | NSCalendarUnitSecond;
//        NSDateComponents *components = [calendar components:units fromDate:self toDate:now options:0];
        NSDateComponents *components = [calendar components:unitFlags fromDate:self toDate:now options:0];
        NSString *relativeString;
        
        if (delta < 0) {
            relativeString = @"!n the future!";
            
        } else if (delta < 1 * MINUTE) {
            relativeString = (components.second == 1) ? @"One second ago" : [NSString stringWithFormat:@"%ld seconds ago",(long)components.second];
            
        } else if (delta < 2 * MINUTE) {
            relativeString =  @"a minute ago";
            
        } else if (delta < 45 * MINUTE) {
            relativeString = [NSString stringWithFormat:@"%ld minutes ago",(long)components.minute];
            
        } else if (delta < 90 * MINUTE) {
            relativeString = @"an hour ago";
            
        } else if (delta < 24 * HOUR) {
            relativeString = [NSString stringWithFormat:@"%ld hours ago",(long)components.hour];
            
        } else if (delta < 48 * HOUR) {
            relativeString = @"yesterday";
            
        } else if (delta < 30 * DAY) {
            relativeString = [NSString stringWithFormat:@"%ld days ago",(long)components.day];
            
        } else if (delta < 12 * MONTH) {
            relativeString = (components.month <= 1) ? @"one month ago" : [NSString stringWithFormat:@"%ld months ago",(long)components.month];
            
        } else {
            relativeString = (components.year <= 1) ? @"one year ago" : [NSString stringWithFormat:@"%ld years ago",(long)components.year];
            
        }
        
        return relativeString;
    }
    
    
    @end
