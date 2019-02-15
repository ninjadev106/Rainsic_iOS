//
//  AISliderDotVimod.h
//  Home Caravan
//
//  Created by An Nguyen on 8/9/17.
//  Copyright © 2017 Home Caravavan. All rights reserved.
//

@class AISliderDotVimod;

#import <UIKit/UIKit.h>

@protocol AISliderDotVimodDelegate <NSObject>
@optional
- (CGPoint)dlgAISliderDotVimod:(AISliderDotVimod*)sender moveFixedBy:(CGPoint)delta;
- (void)dlgAISliderDotVimodChanged:(AISliderDotVimod*)sender;
- (void)dlgAISliderDotVimodEnded:(AISliderDotVimod*)sender;
- (void)dlgAISliderDotVimodBegan:(AISliderDotVimod*)sender;

@end

@interface AISliderDotVimod : NSObject
@property (weak) id<AISliderDotVimodDelegate> delegate;
@property (nonatomic, weak) UIView *barView;
@property (nonatomic, weak) UIView *dotView;
@property (nonatomic) BOOL verticalMode;
@property (nonatomic) BOOL HorizontalMode;
- (CGFloat)fixDeltaX:(CGFloat)deltaX;
- (CGFloat)fixDeltaY:(CGFloat)deltaY;
- (CGFloat)value;
- (void)setvalue:(CGFloat)value;
- (void)update;
@end
