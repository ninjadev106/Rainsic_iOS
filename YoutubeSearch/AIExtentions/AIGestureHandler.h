//
//  AIGestureHandler.h
//  Home Caravan
//
//  Created by An Nguyen on 4/27/17.
//  Copyright © 2017 Home Caravavan. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface AIGestureHandler : NSObject
@property (weak, nonatomic)     UIView *locationRefView;
@property (weak, nonatomic)     UIGestureRecognizer *gesture;
@property (nonatomic)   CGPoint delta;
@property (nonatomic)   CGPoint centerDelta;
@property (nonatomic)   CGPoint beginCenter;
@property (nonatomic)   CGPoint lastBehaviourDelta;
@end
