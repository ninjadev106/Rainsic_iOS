//
//  AIUtility.m
//  AIFramework
//
//  Created by An Nguyen on 9/25/17.
//  Copyright © 2017 An Nguyen. All rights reserved.
//

#import "AIUtility.h"

@implementation AIUtility
+ (CGFloat)aiDegreeToRadian:(CGFloat)degree{
    return degree * M_PI / 180;
}
+ (CGFloat)aiRadianToDegree:(CGFloat)radian{
    
    return radian * 180 / M_PI;
}

+ (NSInteger)aiRandomIntFrom:(NSInteger)from to:(NSInteger)to{
    return  arc4random_uniform((int)to - (int)from + 1) + from;
}
+ (NSString*)aiDocumentFilePath:(NSString*)fileName{
    
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    return [documentsDirectory stringByAppendingPathComponent:fileName];
}
+ (void)aiDismissKeyboard{
    [[UIApplication sharedApplication] sendAction:@selector(resignFirstResponder) to:nil from:nil forEvent:nil];
}

+ (UIViewController*)veryTopViewController{
    UIViewController *topController = [UIApplication sharedApplication].keyWindow.rootViewController;
    while (topController.presentedViewController) {
        topController = topController.presentedViewController;
    }
    return topController;
}
@end
