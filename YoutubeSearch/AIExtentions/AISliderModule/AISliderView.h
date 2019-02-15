//
//  AISliderView.h
//  PageViewDemo
//
//  Created by An Nguyen on 2/18/17.
//  Copyright © 2017 Appcoda. All rights reserved.
//

#import "AINibView.h"

typedef NS_ENUM(NSInteger, AISliderType)
{
    AISliderTypeNone,
    AISliderTypeText,
    AISliderTypeCurrency,
    AISliderTypeTextPlus,
    AISliderTypeHour,
    AISliderTypeDot,
    AISliderTypeRateColor,
    AISliderTypeRateImage,
    AISliderTypeProcessFill,
};


@class AISliderView;

@protocol AISliderDelegate <NSObject>

@optional
- (void)dlgAISliderViewDidChangedValue:(AISliderView*)sender;
- (void)dlgAISliderViewOnChangingValue:(AISliderView*)sender;

@end

@interface AISliderView : AINibView
@property (weak, nonatomic) id<AISliderDelegate> delegate;
@property (weak, nonatomic) IBOutlet UIView *backbarView;
@property (weak, nonatomic) IBOutlet UIView *frontbarView;
@property (weak, nonatomic) IBOutlet UIView *firstDotView;
@property (weak, nonatomic) IBOutlet UILabel *firstFloatLabel;
@property (weak, nonatomic) IBOutlet UILabel *secondFloatLabel;
@property (weak, nonatomic) IBOutlet UIImageView *firstDotImageView;
@property (weak, nonatomic) IBOutlet UIImageView *secondDotImageView;

@property (weak, nonatomic) IBOutlet UIView *secondDotView;
@property (weak, nonatomic) IBOutlet UIView *rootView;
@property (weak, nonatomic) IBOutlet UILabel *leadingLabel;
@property (weak, nonatomic) IBOutlet UILabel *trailingLabel;
@property (weak, nonatomic) IBOutlet UIImageView *backbarImageView;
@property (weak, nonatomic) IBOutlet UIImageView *frontbarImageView;

//require
@property (nonatomic) BOOL isSingleValue;
@property (nonatomic) BOOL isFixValue;
@property (nonatomic) CGFloat minValue;
@property (nonatomic) CGFloat maxValue;
@property (nonatomic) CGFloat firstValue;
@property (nonatomic) CGFloat secondValue;
- (void)finishInit;
- (void)renderView;
//optional
@property (nonatomic) BOOL isDotInRange; //fix percent range
@property (nonatomic) UIColor *valueDotColor;
@property (nonatomic) CGFloat valueDotSize;
@property (nonatomic) NSInteger showTextValue;
@property (nonatomic) CGFloat valueObjectOffset;//atTop?20:-24;
@property (nonatomic) AISliderType sliderType;
@property (nonatomic) NSString *symbol;
@property (nonatomic) NSMutableArray* rateOnObjects;
@property (nonatomic) NSMutableArray * rateOffObjects;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *slidebarHeightCst;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *slidebarTopSpaceCst;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *slidebarLeadingCst;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *slidebarTrailingCst;
- (void)addTapToSelectSingleValue;
- (void)addFloatValueOffset:(CGFloat)offset dotView:(UIView*)dotView;
- (void)addFloatValueOffset:(CGFloat)offset;
- (void)addHeadTrailLabelOffset:(CGFloat)offset;//12
- (void)hideCanTouchDot:(UIView*)dot;
// Not use for init
- (void)resetFirstValue:(CGFloat)firstValue;
- (void)resetSecondValue:(CGFloat)secondValue;
- (void)resetFirstValue:(CGFloat)firstValue secondValue:(CGFloat)secondValue;
- (void)resetMinValue:(CGFloat)minVlue maxValue:(CGFloat)maxValue;
@end
