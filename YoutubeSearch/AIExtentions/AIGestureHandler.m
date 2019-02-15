//
//  AIGestureHandler.m
//  Home Caravan
//
//  Created by An Nguyen on 4/27/17.
//  Copyright © 2017 Home Caravavan. All rights reserved.
//

#import "AIGestureHandler.h"

@interface AIGestureHandler()
@property CGPoint prevPoint;
@end

@implementation AIGestureHandler

- (CGPoint)delta{
    CGPoint currentPoint = [self.gesture locationInView:self.locationRefView?self.locationRefView:self.gesture.view.superview];
    CGPoint deltaPoint = CGPointZero;
    if (self.gesture.state == UIGestureRecognizerStateBegan) {
        self.beginCenter = self.gesture.view.center;
        self.lastBehaviourDelta = CGPointZero;
    }else{
        deltaPoint.x = currentPoint.x - self.prevPoint.x;
        deltaPoint.y = currentPoint.y - self.prevPoint.y;
        CGFloat yBe = 0;
        if (self.lastBehaviourDelta.y * deltaPoint.y >=0) {
            yBe = self.lastBehaviourDelta.y + deltaPoint.y;
        }else{
            yBe = deltaPoint.y;
        }
        CGFloat xBe = 0;
        if (self.lastBehaviourDelta.x * deltaPoint.x >=0) {
            xBe = self.lastBehaviourDelta.x + deltaPoint.x;
        }else{
            xBe = deltaPoint.x;
        }
        self.lastBehaviourDelta = CGPointMake(xBe, yBe);
    }
    self.prevPoint = currentPoint;
    _delta = deltaPoint;
    return _delta;
}
- (void)setLastBehaviourDelta:(CGPoint)lastBehaviourDelta{
    _lastBehaviourDelta = lastBehaviourDelta;
//    NSLog(@"Last behaviour %@",NSStringFromCGPoint(_lastBehaviourDelta));
}
- (CGPoint)centerDelta{
    CGPoint delta = self.delta;
    CGPoint centerDelta = CGPointMake(self.gesture.view.center.x + delta.x, self.gesture.view.center.y+ delta.y);
    return centerDelta;
}
- (void)moveDelta{
//    if (self.gesture.state == UIGestureRecognizerStateChanged) {
        CGPoint delta = self.delta;
        NSLog(@"Delta %@", NSStringFromCGPoint(delta));
        self.gesture.view.center = CGPointMake(self.gesture.view.center.x+delta.x, self.gesture.view.center.y+delta.y);
//    }
}
@end
