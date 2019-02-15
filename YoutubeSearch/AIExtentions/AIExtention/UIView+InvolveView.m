//
//  UIView+InvolveView.m
//  AIFramework
//
//  Created by An Nguyen on 9/25/17.
//  Copyright © 2017 An Nguyen. All rights reserved.
//

#import "UIView+InvolveView.h"

@implementation UIView (AIInvolveView)

- (UIView *)aiFirstResponseView{
    if (self.isFirstResponder) {
        return self;
    }
    for(UIView *view in self.subviews){
        UIView *frp = view.aiFirstResponseView;
        if (frp) {
            return frp;
        }
    }
    return nil;
}

- (void)aiRemoveAllSubviews{
    for(UIView *view in self.subviews){
        [view removeFromSuperview];
    }
}
@end
