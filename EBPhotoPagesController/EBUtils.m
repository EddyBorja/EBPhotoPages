//
//  NSObject+EBUtils.m
//  EBPhotoPagesControllerDemo
//
//  Created by Marco Ricca on 28/10/21.
//  Copyright © 2021 Eddy Borja. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "EBUtils.h"

@implementation EBUtils

+ (BOOL)hasNotch {
    if (@available(iOS 11.0, *)) {
        UIWindow *mainWindow = [[[UIApplication sharedApplication] delegate] window];
        if (mainWindow.safeAreaInsets.bottom > 0.0) {
            return true;
        }
    }
    return false;
}

@end
