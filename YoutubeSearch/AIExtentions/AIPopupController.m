//
//  WGPopupController.m
//  Wegolala
//
//  Created by An Nguyen on 1/9/18.
//  Copyright © 2018 An Nguyen. All rights reserved.
//

#import "AIPopupController.h"

@interface AIPopupController ()

@property AIPopupDismissCallback mDismissCallback;
@end

@implementation AIPopupController

- (void)viewDidLoad {
    [super viewDidLoad];
}
- (void)addTapDismissToView:(UIView*)view{
    
    UITapGestureRecognizer* tapDismissGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(dismissGestureHandler:)];
    [view addGestureRecognizer:tapDismissGesture];
}
- (void)addSwipeDismissToView:(UIView*)view{
    UISwipeGestureRecognizer * swipeDismissGesture = [[UISwipeGestureRecognizer alloc]initWithTarget:self action:@selector(dismissGestureHandler:)];
    swipeDismissGesture.direction = UISwipeGestureRecognizerDirectionUp | UISwipeGestureRecognizerDirectionDown;
    [view addGestureRecognizer:swipeDismissGesture];
}

- (void)dismissGestureHandler:(UIGestureRecognizer*)sender{
    [self dismiss];
}

- (void)dismiss{
    [UIViewController ai_dismissPopupViewController:self];
    if (_mDismissCallback) {
        _mDismissCallback();
    }
}
- (void)show{
    [UIViewController ai_presentVeryTopPopupViewController:self];
}

- (AIPopupController*)callbackDismiss:(AIPopupDismissCallback)callback{
    _mDismissCallback = callback;
    return self;
}
@end
