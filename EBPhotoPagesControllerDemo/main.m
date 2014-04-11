//
//  main.m
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

#import <UIKit/UIKit.h>

#import "DEMOAppDelegate.h"
#import "GAI.h"
#import "GAIDictionaryBuilder.h"
#import <sys/utsname.h>

int main(int argc, char * argv[])
{
    @autoreleasepool {
        NSUUID *device =
        [[UIDevice currentDevice] respondsToSelector:@selector(identifierForVendor)] ?
        [[UIDevice currentDevice] performSelector:@selector(identifierForVendor)] :
        nil;
        
        struct utsname systemInfo;
        uname(&systemInfo);
        NSString *model = [NSString stringWithCString:systemInfo.machine
                                             encoding:NSUTF8StringEncoding];
        NSString *deviceString = [device UUIDString];
        [GAI sharedInstance].trackUncaughtExceptions = YES;
        [GAI sharedInstance].dispatchInterval = 10;
        [[GAI sharedInstance] trackerWithTrackingId:@"UA-41220983-5"];
        [[GAI sharedInstance].defaultTracker
         send:[[GAIDictionaryBuilder createEventWithCategory:model
                                                      action:@"Demo Launch"
                                                       label:deviceString
                                                       value:nil] build]];
        
        return UIApplicationMain(argc, argv, nil, NSStringFromClass([DEMOAppDelegate class]));
    }
}
