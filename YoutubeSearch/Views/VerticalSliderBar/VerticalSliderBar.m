//
//  VerticalSliderBar.m
//  YoutubeSearch
//
//  Created by An Nguyen on 3/16/18.
//  Copyright © 2018 An Nguyen. All rights reserved.
//

#import "VerticalSliderBar.h"
#import "AISliderBarValueVimod.h"

@interface VerticalSliderBar()<AISliderDotVimodDelegate>{
    CAGradientLayer *gradient;
}
@property (weak, nonatomic) IBOutlet UIView *pointView;
@property (weak, nonatomic) IBOutlet UIView *barView;
@property AISliderBarValueVimod *barValue;
@property AISliderDotVimod* firstDot;

@end

@implementation VerticalSliderBar

- (void)initCustom{
    [super initCustom];
    [self initSilder];
}


- (void)setValue:(CGFloat)value{
    CGFloat rangeValue = value - self.min;
    CGFloat maxRange = self.max - self.min;
    CGFloat realValue = rangeValue/maxRange;
    [self.firstDot setvalue:realValue];
}

- (CGFloat)value{
    CGFloat maxRange = self.max - self.min;
    CGFloat realValue = self.firstDot.value*maxRange + self.min;
    NSLog(@"self.max %f",self.max);
    NSLog(@"self.min %f",self.min);
    NSLog(@"realValue %f",realValue);
    NSLog(@"maxRange %f",maxRange);
   
    
    /*[gradient removeFromSuperlayer];
    gradient = [CAGradientLayer layer];
    gradient.frame = _barView.bounds;
    gradient.startPoint = CGPointMake(0.0, self.firstDot.value);   // start at left middle
    gradient.endPoint = CGPointMake(1.0, self.firstDot.value);
    gradient.colors = @[(id)[UIColor redColor].CGColor,
                            (id)[UIColor redColor].CGColor,
                            (id)[UIColor blueColor].CGColor,
                            (id)[UIColor blueColor].CGColor];
//    gradient.locations = @[@0.0, @0.10, @0.90, @1.0];
    [_barView.layer addSublayer:gradient];
    [_barView setNeedsDisplay];
    [_barView.layer setNeedsDisplay];*/
    
    return realValue;
}



- (void)initSilder{
    
    self.firstDot = [[AISliderDotVimod alloc]init];
    self.firstDot.verticalMode = false;
    self.firstDot.delegate = self;
    self.firstDot.dotView = self.pointView;
    self.firstDot.barView = self.barView;
    //[self.firstDot setvalue:0];
    
    self.barValue = [[AISliderBarValueVimod alloc]init];
    self.barValue.barView = self.barView;
    self.barValue.firstDot = self.firstDot;
    

    [self.barValue update];
    
}

- (CGPoint)dlgAISliderDotVimod:(AISliderDotVimod*)sender moveFixedBy:(CGPoint)delta{
   // return CGPointMake(0, [sender fixDeltaY:delta.y]);
     return CGPointMake([sender fixDeltaX:delta.x], 0);
}

- (void)dlgAISliderDotVimodChanged:(AISliderDotVimod*)sender{
    if ([self.delegate respondsToSelector:@selector(dlgVerticalSliderBarChanged:)]) {
        [self.delegate dlgVerticalSliderBarChanged:self];
    }
}

- (IBAction)onRefreshTouched:(UIButton *)sender {
    if ([self.delegate respondsToSelector:@selector(dlgVerticalSliderBarRefresh:)]) {
        [self.delegate dlgVerticalSliderBarRefresh:self];
    }
}

@end
