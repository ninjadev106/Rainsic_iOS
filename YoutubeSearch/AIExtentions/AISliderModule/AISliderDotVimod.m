//
//  AISliderDotVimod.m
//  Home Caravan
//
//  Created by An Nguyen on 8/9/17.
//  Copyright © 2017 Home Caravavan. All rights reserved.
//

#import "AISliderDotVimod.h"

@interface AISliderDotVimod()

@property CGPoint prevPoint;
@property CGFloat lastValue;
@end

@implementation AISliderDotVimod
- (void)setDotView:(UIView *)dotView{
    _dotView = dotView;
    UIPanGestureRecognizer *panGesture = [[UIPanGestureRecognizer alloc]initWithTarget:self action:@selector(panGestureHandle:)];
    [_dotView addGestureRecognizer:panGesture];
}

- (void)panGestureHandle:(UIPanGestureRecognizer*)sender{
    CGPoint point = [sender locationInView:_dotView.superview];
    if (sender.state == UIGestureRecognizerStateChanged) {
        CGPoint delta = CGPointMake(point.x - self.prevPoint.x, point.y - self.prevPoint.y);
        CGPoint deltaFix = [self.delegate dlgAISliderDotVimod:self moveFixedBy:delta];
        if (deltaFix.x != 0 || deltaFix.y != 0) {
//            NSLog(@"Delta Fix %@", NSStringFromCGPoint(deltaFix));
            self.dotView.center = CGPointMake(self.dotView.center.x + deltaFix.x, self.dotView.center.y + deltaFix.y);
        }
        self.lastValue = [self value];
        
        if([self.delegate respondsToSelector:@selector(dlgAISliderDotVimodChanged:)]){
            [self.delegate dlgAISliderDotVimodChanged:self];
        }
    }
    if (sender.state == UIGestureRecognizerStateBegan) {
        if([self.delegate respondsToSelector:@selector(dlgAISliderDotVimodBegan:)]){
            [self.delegate dlgAISliderDotVimodBegan:self];
        }
    }
    if (sender.state == UIGestureRecognizerStateEnded) {
        if([self.delegate respondsToSelector:@selector(dlgAISliderDotVimodEnded:)]){
            [self.delegate dlgAISliderDotVimodEnded:self];
        }
    }
    self.prevPoint = point;
}

- (CGFloat)fixDeltaX:(CGFloat)deltaX{
    CGRect barFrame = [self frameInScreenOfView:self.barView];
    CGPoint center = [self centerInScreenOfView:self.dotView];
    CGFloat minX = barFrame.origin.x;
    CGFloat maxX = barFrame.origin.x + barFrame.size.width;
    CGFloat centerX = center.x;
    CGFloat nextX = centerX + deltaX;
    if (nextX < minX) {
        return minX - centerX;
    }
    if (nextX > maxX) {
        return maxX - centerX;
    }
    return deltaX;
}

- (CGFloat)fixDeltaY:(CGFloat)deltaY{
    CGRect barFrame = [self frameInScreenOfView:self.barView];
    CGPoint center = [self centerInScreenOfView:self.dotView];
    CGFloat minY = barFrame.origin.y;
    CGFloat maxY = barFrame.origin.y + barFrame.size.height;
    CGFloat centerY = center.y;
    CGFloat nextY = centerY + deltaY;
    if (nextY < minY) {
        return minY - centerY;
    }
    if (nextY > maxY) {
        return maxY - centerY;
    }
    return deltaY;
    
}
- (CGFloat)value{
    CGRect barFrame = [self frameInScreenOfView:self.barView];
    CGPoint center = [self centerInScreenOfView:self.dotView];
    if (self.verticalMode) {
        CGFloat refY = center.y - barFrame.origin.y;
        self.lastValue = (1.0f - refY/barFrame.size.height);
    }else{
        CGFloat refX = center.x - barFrame.origin.x;
        self.lastValue = refX/barFrame.size.width;
    }
    return self.lastValue;
}

- (void)setvalue:(CGFloat)value{
    CGRect barFrame = [self frameInScreenOfView:self.barView];
    CGPoint center = [self centerInScreenOfView:self.dotView];
    if (self.verticalMode) {
        CGFloat y = (1.0f - value) * barFrame.size.height + barFrame.origin.y;
        center.y = y;
    }else{
        CGFloat x = value * barFrame.size.width + barFrame.origin.x;
        center.x = x;
    }
    CGPoint centerInView = [self screentPoint:center inView:self.dotView];
    self.dotView.center = centerInView;
    self.lastValue = value;
}
- (void)update{
    [self setvalue:self.lastValue];
}
- (CGRect)frameInScreenOfView:(UIView*)view{
    CGRect frame = [view.superview convertRect:view.frame toView:[UIApplication sharedApplication].keyWindow];
    return frame;
}

- (CGPoint)centerInScreenOfView:(UIView*)view{
    CGPoint center = [view.superview convertPoint:view.center toView:[UIApplication sharedApplication].keyWindow];
    return center;
}
- (CGPoint)screentPoint:(CGPoint)point inView:(UIView*)view{
    return [view.superview convertPoint:point fromView:[UIApplication sharedApplication].keyWindow];
}
@end
