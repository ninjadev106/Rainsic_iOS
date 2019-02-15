//
//  AIUtility.h
//  AIFramework
//
//  Created by An Nguyen on 9/25/17.
//  Copyright © 2017 An Nguyen. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface AIUtility : NSObject
+ (CGFloat)aiDegreeToRadian:(CGFloat)degree;
+ (CGFloat)aiRadianToDegree:(CGFloat)radian;
+ (NSInteger)aiRandomIntFrom:(NSInteger)from to:(NSInteger)to;
+ (NSString*)aiDocumentFilePath:(NSString*)fileName;
+ (void)aiDismissKeyboard;
+ (UIViewController*)veryTopViewController;
@end
