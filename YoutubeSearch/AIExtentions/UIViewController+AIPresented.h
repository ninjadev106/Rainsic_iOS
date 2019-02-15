//
//  AIPresented+ViewController.h
//  Wegolala
//
//  Created by An Nguyen on 1/15/18.
//  Copyright © 2018 An Nguyen. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface AIPopupManager : NSObject
@property (weak, nonatomic) UIViewController *viewController;
@property (weak, nonatomic) UIView           *popupView;
@end

@interface UIViewController (AIPresented)
+ (UIViewController*)ai_veryTopViewController;
+ (void)ai_presentViewController:(UIViewController *)viewControllerToPresent animated: (BOOL)flag completion:(void (^)(void))completion;
@end

@interface UIViewController (AIPresented_Popup)
- (void)ai_presentPopupViewController:(UIViewController*)viewController;
+ (void)ai_presentVeryTopPopupViewController:(UIViewController*)viewController;
+ (void)ai_dismissPopupViewController:(UIViewController*)viewController;
+ (void)ai_dismissPopupViewController;
+ (void)ai_presentChildViewController:(UIViewController*)viewController;
- (void)ai_dismissChildViewController;
@end


@interface UIViewController (Storyboard)
+ (id)ai_createFromStoryboard:(NSString*)storyboard;
@end

