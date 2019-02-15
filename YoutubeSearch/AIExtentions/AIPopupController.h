//
//  WGPopupController.h
//  Wegolala
//
//  Created by An Nguyen on 1/9/18.
//  Copyright © 2018 An Nguyen. All rights reserved.
//

#import "UIViewController+AIPresented.h"


typedef void(^AIPopupDismissCallback)();

@interface AIPopupController : UIViewController

- (AIPopupController*)callbackDismiss:(AIPopupDismissCallback)callback;
- (void)addTapDismissToView:(UIView*)view;
- (void)addSwipeDismissToView:(UIView*)view;
- (void)dismiss;
- (void)show;
@end
