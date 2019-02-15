//
//  AISliderBarValueVimod.m
//  YoutubeSearch
//
//  Created by An Nguyen on 1/29/18.
//  Copyright © 2018 An Nguyen. All rights reserved.
//

#import "AISliderBarValueVimod.h"

@implementation AISliderBarValueVimod
- (void)update{
    if (self.secondDot) {
        [self updateRange];
    }else{
        [self updateLeftSide];
    }
}

- (CGFloat)minValue{
    return MIN([self.firstDot value], [self.secondDot value]);
}
- (CGFloat)maxValue{
    return MAX([self.firstDot value], [self.secondDot value]);
}
- (CGFloat)value{
    return ABS([self.firstDot value] - [self.secondDot value]);
}
- (void)updateLeftSide{
    
    CGFloat value = [self.firstDot value];
    CGFloat maxWidth = self.firstDot.barView.frame.size.width;
    CGFloat x = 0;
    CGFloat w = value*maxWidth - x;
    CGRect rangeFrame = self.firstDot.barView.bounds;
    rangeFrame.origin.x = x;
    rangeFrame.size.width = w;
    self.barView.frame = rangeFrame;
}
- (void)updateRange{
    CGFloat firstValue = [self.firstDot value];
    CGFloat secondValue = [self.secondDot value];
    
    CGFloat maxWidth = self.firstDot.barView.frame.size.width;
    CGFloat x = MIN(firstValue, secondValue)*maxWidth;
    CGFloat w = MAX(firstValue, secondValue)*maxWidth - x;
    CGRect rangeFrame = self.firstDot.barView.bounds;
    rangeFrame.origin.x = x;
    rangeFrame.size.width = w;
    self.barView.frame = rangeFrame;
}
@end
