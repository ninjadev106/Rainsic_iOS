//
//  VerticalSliderBar.h
//  YoutubeSearch
//
//  Created by An Nguyen on 3/16/18.
//  Copyright © 2018 An Nguyen. All rights reserved.
//

#import "AINibView.h"

@class VerticalSliderBar;

@protocol VerticalSliderBarDelegate<NSObject>
@optional
- (void)dlgVerticalSliderBarChanged:(VerticalSliderBar*)sender;
- (void)dlgVerticalSliderBarRefresh:(VerticalSliderBar*)sender;
@end

@interface VerticalSliderBar : AINibView
@property (nonatomic, weak) id<VerticalSliderBarDelegate> delegate;
@property (nonatomic) CGFloat min;
@property (nonatomic) CGFloat max;
@property (nonatomic) CGFloat value;
@end
