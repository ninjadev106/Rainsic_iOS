//
//  AIPresented+ViewController.m
//  Wegolala
//
//  Created by An Nguyen on 1/15/18.
//  Copyright © 2018 An Nguyen. All rights reserved.
//

#import "UIViewController+AIPresented.h"

@implementation AIPopupManager

@end

@implementation UIViewController (AIPresented)
+ (UIViewController*)ai_veryTopViewController{
    UIViewController *topController = [UIApplication sharedApplication].keyWindow.rootViewController;
    while (topController.presentedViewController) {
        topController = topController.presentedViewController;
    }
    return topController;
}

+ (void)ai_presentViewController:(UIViewController *)viewControllerToPresent animated: (BOOL)flag completion:(void (^)(void))completion{
    UIViewController *topController = [UIViewController ai_veryTopViewController];
    if (!topController) {
        [UIApplication sharedApplication].delegate.window.rootViewController = viewControllerToPresent;
    }else{
        [topController presentViewController:viewControllerToPresent animated:flag completion:completion];
    }
}
@end

@implementation UIViewController (AIPresented_Popup)

+ (NSMutableArray<AIPopupManager *> *)ai_popupControllerManager{
    
    static dispatch_once_t onceToken;
    static NSMutableArray<AIPopupManager*>* __aiPopupController;
    dispatch_once(&onceToken, ^{
        __aiPopupController = [NSMutableArray new];
    });
    return __aiPopupController;
}
- (void)ai_presentPopupViewController:(UIViewController*)viewController{
    [UIViewController ai_presentPopupViewController:viewController onViewControler:self];
}

+ (void)ai_presentVeryTopPopupViewController:(UIViewController*)viewController{
    [UIViewController ai_presentPopupViewController:viewController onViewControler:[UIViewController ai_veryTopViewController]];
}
+ (void)ai_dismissPopupViewController:(UIViewController*)viewController{
    for (AIPopupManager* obj in [UIViewController ai_popupControllerManager]) {
        if (obj.viewController == viewController) {
            [self ai_dismissAIPopupController:obj];
            return;
        }
    }
}
+ (void)ai_dismissAIPopupController:(AIPopupManager*)popup{
    
    if (!popup) {
        return;
    }
    UIView *popupView  = popup.popupView;
    UIViewController *controllerView = popup.viewController;
    
    [UIView animateWithDuration:0.2 animations:^{
        popupView.alpha = 0;
    } completion:^(BOOL finished) {
        [popupView removeFromSuperview];
        [controllerView removeFromParentViewController];
        [[UIViewController ai_popupControllerManager] removeObject:popup];
    }];
}
+ (void)ai_dismissPopupViewController{
    AIPopupManager *lastObj = [UIViewController ai_popupControllerManager].lastObject;
    [self ai_dismissAIPopupController:lastObj];
    
}


+ (void)ai_presentPopupViewController:(UIViewController*)viewController onViewControler:(UIViewController*)parentViewController{
    
    [parentViewController addChildViewController:viewController];
    
    UIView *popupView = [[UIView alloc]initWithFrame: parentViewController.view.bounds];
    popupView.alpha = 0;
    
    UIView* dismissView = [[UIView alloc]initWithFrame:popupView.bounds];
    [popupView addSubview:dismissView];
    dismissView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    viewController.view.frame = parentViewController.view.bounds;
    
    [popupView addSubview:viewController.view];
    viewController.view.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    
    [parentViewController.view addSubview:popupView];
    popupView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    [UIView animateWithDuration:0.2 animations:^{
        popupView.alpha = 1;
    }];
    
    UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(ai_dismissPopupViewController)];
    [dismissView addGestureRecognizer:tapGesture];
    
    AIPopupManager *obj = [[AIPopupManager alloc]init];
    obj.popupView = popupView;
    obj.viewController = viewController;
    [[UIViewController ai_popupControllerManager] addObject:obj];
}

+ (void)ai_presentChildViewController:(UIViewController*)viewController{
    UIViewController *topController = [UIViewController ai_veryTopViewController];
    if (topController.navigationController) {
        [topController.navigationController pushViewController:topController animated:true];
    }else{
        [topController presentViewController:viewController animated:true completion:nil];
    }
}

+ (void)ai_dismissChildViewController:(UIViewController*)viewController{
    [viewController ai_dismissChildViewController];
}
- (void)ai_dismissChildViewController{
    
    if (self.navigationController && self.navigationController.viewControllers.count>1) {
        [self.navigationController popViewControllerAnimated:true];
    }else{
        [self dismissViewControllerAnimated:true completion:nil];
    }
}
@end


@implementation UIViewController (Storyboard)
+ (id)ai_createFromStoryboard:(NSString*)storyboard{
    
    id vc = [[UIStoryboard storyboardWithName:storyboard bundle:nil]
             instantiateViewControllerWithIdentifier:NSStringFromClass([self class])];
    return vc;
}
@end
