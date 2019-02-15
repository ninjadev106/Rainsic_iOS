//
//  UIView+InvolveView.h
//  AIFramework
//
//  Created by An Nguyen on 9/25/17.
//  Copyright © 2017 An Nguyen. All rights reserved.
//

#import <UIKit/UIKit.h>
@interface UIView (AIInvolveView)
@property (nonatomic, readonly) UIView *aiFirstResponseView;
- (void)aiRemoveAllSubviews;
@end
