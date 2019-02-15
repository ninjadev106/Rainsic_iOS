//
//  AISliderDotFillRangeVimod.m
//  Home Caravan
//
//  Created by An Nguyen on 8/9/17.
//  Copyright © 2017 Home Caravavan. All rights reserved.
//

#import "AISliderDotFillRangeVimod.h"
#import "AIExtentions.h"



@interface AISliderDotFillRangeVimod()<AISliderDotVimodDelegate>

@end

@implementation AISliderDotFillRangeVimod

- (void)setDotVimod:(AISliderDotVimod *)dotVimod{
    _dotVimod = dotVimod;
    _dotVimod.delegate = self;
}

- (void)setWidthPercent:(CGFloat)widthPercent{
    _widthPercent                   = widthPercent;
    if (_widthPercent <= 0.0f) {
        _widthPercent = _dotVimod.dotView.width / self.barView.width;
    }
    if (_widthPercent>1) {
        _widthPercent = 1.0f;
    }
    self.dotVimod.dotView.width     = self.barView.width * _widthPercent;
    self.dotVimod.dotView.center    = self.barView.center;
}

- (void)setValuePercent:(CGFloat)valuePercent{
    _valuePercent                   = valuePercent;
    if (_widthPercent + _valuePercent>1) {
        _valuePercent  = 1.0f - _widthPercent;
    }
    if (_valuePercent < 0) {
        _valuePercent = 0;
    }
    self.dotVimod.dotView.center    = self.barView.center;
    self.dotVimod.dotView.x         = self.barView.x + self.barView.width * _valuePercent;
}
#pragma mark - Delegate

- (CGPoint)dlgAISliderDotVimod:(AISliderDotVimod*)sender moveFixedBy:(CGPoint)delta{
    if (self.dotVimod.dotView.x + delta.x < self.barView.x) {//Over left
        delta.x = self.barView.x - self.dotVimod.dotView.x;
    }
    if (self.dotVimod.dotView.x + self.dotVimod.dotView.width + delta.x > self.barView.x + self.barView.width ) {//Over right
        delta.x = (self.barView.x + self.barView.width) - (self.dotVimod.dotView.x + self.dotVimod.dotView.width);
    }
    
    return CGPointMake(delta.x, 0);
}


- (void)dlgAISliderDotVimodDidChanged:(AISliderDotVimod*)sender{
    CGFloat newValue = (sender.dotView.x - self.barView.x)/self.barView.width;
    if (newValue != _valuePercent) {
        _valuePercent = newValue;
        [self.delegate dlgAISliderDotFillRangeVimodDidChange:self];
    }
}
@end
