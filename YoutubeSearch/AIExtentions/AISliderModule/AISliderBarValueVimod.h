//
//  AISliderBarValueVimod.h
//  YoutubeSearch
//
//  Created by An Nguyen on 1/29/18.
//  Copyright © 2018 An Nguyen. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AISliderDotVimod.h"

@interface AISliderBarValueVimod : NSObject
@property (nonatomic, weak) UIView* barView;
@property (nonatomic, weak) AISliderDotVimod* firstDot;
@property (nonatomic, weak) AISliderDotVimod* secondDot;
@property (nonatomic, readonly) CGFloat minValue;
@property (nonatomic, readonly) CGFloat maxValue;
@property (nonatomic, readonly) CGFloat value;
- (void)update;
@end
