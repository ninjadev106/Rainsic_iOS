//
//  AISliderDotFillRangeVimod.h
//  Home Caravan
//
//  Created by An Nguyen on 8/9/17.
//  Copyright © 2017 Home Caravavan. All rights reserved.
//

@class AISliderDotFillRangeVimod;

#import <UIKit/UIKit.h>
#import "AISliderDotVimod.h"


@protocol AISliderDotFillRangeVimodDelegate <NSObject>

- (void)dlgAISliderDotFillRangeVimodDidChange:(AISliderDotFillRangeVimod*)sender;

@end

@interface AISliderDotFillRangeVimod : NSObject
@property (weak) id<AISliderDotFillRangeVimodDelegate> delegate;
//Set value follow priority top down
@property (nonatomic) AISliderDotVimod *dotVimod;
@property (nonatomic, weak) UIView *barView;
@property (nonatomic) CGFloat widthPercent;
@property (nonatomic) CGFloat valuePercent;
@end
