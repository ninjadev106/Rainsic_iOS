//
//  AISliderView.m
//  PageViewDemo
//
//  Created by An Nguyen on 2/18/17.
//  Copyright © 2017 Appcoda. All rights reserved.
//

#import "AISliderView.h"
#import "AIExtentions.h"
#import "UIColor+HexString.h"

//#define AISliderViewAdditionObjectTag 67

@interface AISliderView()
@property CGPoint initialPoint;
@property CGFloat rangeUnit;
@property BOOL isShowFloatValue;
@property BOOL isRateMode;
@property NSMutableArray * rateViews;
@property NSMutableArray * additionViews;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *trailingLabelCst;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *leadingLabelCst;
@end

@implementation AISliderView
- (void)renderView{
    [self setNeedsLayout];
    [self layoutIfNeeded];
    [self refixUnit];
    self.additionViews = [NSMutableArray new];
    self.frontbarView.frame = self.backbarView.frame;
    self.frontbarView.frame = [self reframeFrontView];
    self.backbarView.layer.cornerRadius = self.slidebarHeightCst.constant/2;
    self.frontbarView.layer.cornerRadius = self.slidebarHeightCst.constant/2;
    
    [self addAdditionViewsObject];
    
    if (self.isRateMode) {
        self.firstDotView.hidden = true;
    }else{
        
        [self moveDot:self.firstDotView toValue:_firstValue animation:false];
        [self moveDot:self.secondDotView toValue:_secondValue animation:false];
        if ([self.delegate respondsToSelector:@selector(dlgAISliderViewOnChangingValue:)]) {
            [self.delegate dlgAISliderViewOnChangingValue:self];
        }
        [self updateFloatDotLabel:self.firstDotView withValue:_firstValue];
        [self updateFloatDotLabel:self.secondDotView withValue:_secondValue];
        if (_sliderType == AISliderTypeProcessFill) {
            self.firstDotView.hidden = true;
            self.isFixValue = true;
            self.isSingleValue = false;
            self.frontbarView.hidden = false;
            [self addPanProgress];
            [self addTapToSelectSingleValue];
        }else{
            [self addTapToDotView:self.firstDotView];
            if (!self.isSingleValue) {
                self.secondDotView.hidden = false;
                [self addTapToDotView:self.secondDotView];
                self.frontbarView.hidden = false;
            }
        }
    }

    
}
- (void)finishInit{
    [self renderView];
}
- (void)removeAdditionViewsObject{
    for(UIView *view in self.additionViews){
        [view removeFromSuperview];
    }
    [self.additionViews removeAllObjects];
    
    for(UIView *view in self.rateViews){
        [view removeFromSuperview];
    }
    [self.rateViews removeAllObjects];
}
- (void)addAdditionViewsObject{
    switch (self.sliderType) {
        case AISliderTypeText:{
            [self addValueLabel];
        }
            break;
        case AISliderTypeTextPlus:{
            [self addValueLabel];
            
        }
            break;
        case AISliderTypeHour:{
            [self addValueLabel];
            
        }
            break;
        case AISliderTypeCurrency:{
            [self addValueLabel];
            
        }
            break;
            
        case AISliderTypeDot:{
            [self addValueDot];
            
        }
            break;
            
        case AISliderTypeRateImage:{
            [self addRateObject];
            
        }
            break;
            
        case AISliderTypeRateColor:{
            [self addRateObject];
            
        }
            break;
            
        default:
            break;
    }
}
- (void)setSliderType:(AISliderType)sliderType{
    _sliderType = sliderType;
    if (_sliderType == AISliderTypeCurrency) {
        self.symbol = @"$";
    }
    self.showTextValue = 1;
}
- (void)initCustom{

}

- (void)hideCanTouchDot:(UIView*)dot{
    
    for (UIView *view in dot.subviews){
        view.alpha = 0;
    }
    
}

- (void)resetFirstValue:(CGFloat)firstValue{
    _firstValue = firstValue;
    [self moveDot:self.firstDotView toValue:_firstValue animation:true];
    [self updateFloatDotLabel:self.firstDotView withValue:_firstValue];
}

- (void)resetSecondValue:(CGFloat)secondValue{
    _secondValue = secondValue;
    [self moveDot:self.secondDotView toValue:_secondValue animation:true];
    [self updateFloatDotLabel:self.secondDotView withValue:_secondValue];
}
- (void)resetFirstValue:(CGFloat)firstValue secondValue:(CGFloat)secondValue{
    [self resetFirstValue:firstValue];
    [self resetSecondValue:secondValue];
}
- (void)resetMinValue:(CGFloat)minVlue maxValue:(CGFloat)maxValue{
    _minValue = minVlue;
    _maxValue = maxValue;
    [self.leadingLabel setText:[self textFromValue:self.minValue]];
    [self.trailingLabel setText:[self textFromValue:self.maxValue]];
    [self refixUnit];
    [self removeAdditionViewsObject];
    [self addAdditionViewsObject];
}
- (void)addRateObject{
    self.isRateMode = true;
    [self addTapToSelectSingleValue];
    [self addPanProgress];
    self.firstDotView.hidden = true;
    self.secondDotView.hidden = true;
    self.rateViews = [NSMutableArray new];
    CGFloat widthRange = self.backbarView.bounds.size.width/(self.maxValue - self.minValue);
    for (NSInteger i = self.minValue; i < self.maxValue; i++) {
        if (self.sliderType == AISliderTypeRateColor) {
            UIView *rateView = [[UIView alloc]initWithFrame:CGRectMake(i*widthRange, 0, widthRange, self.slidebarHeightCst.constant)];
            rateView.alpha = 0;
            rateView.layer.cornerRadius = self.slidebarHeightCst.constant/2;
            rateView.backgroundColor = self.rateOnObjects[i];
            [self.backbarView addSubview:rateView];
            [self.rateViews addObject:rateView];
        }else if(self.sliderType == AISliderTypeRateImage) {
            
            UIImageView *rateView = [[UIImageView alloc]initWithFrame:CGRectMake(i*widthRange, 0, widthRange, self.slidebarHeightCst.constant)];
            rateView.alpha = 0;
            rateView.contentMode = UIViewContentModeScaleAspectFit;
            rateView.image = self.rateOnObjects[i];
            [self.backbarView addSubview:rateView];
            [self.rateViews addObject:rateView];
        }
    }
    [self didSelectedSingleValue:_firstValue];
}

- (void)addFloatValueOffset:(CGFloat)offset{
    [self addFloatValueOffset:offset dotView:self.firstDotView];
    [self addFloatValueOffset:offset dotView:self.secondDotView];
}
- (void)addFloatValueOffset:(CGFloat)offset dotView:(UIView*)dotView{
    self.isShowFloatValue = true;
    UILabel *floatLabel = [dotView viewWithTag:110];
    floatLabel.hidden = false;
    floatLabel.center = CGPointMake(dotView.width/2 , dotView.height/2+offset);
    
}
- (void)addHeadTrailLabelOffset:(CGFloat)offset{
    self.leadingLabel.hidden = false;
    self.trailingLabel.hidden = false;
    [self.leadingLabel setText:[self textFromValue:self.minValue]];
    [self.trailingLabel setText:[self textFromValue:self.maxValue]];
    CGFloat convertOffset = -offset - (self.slidebarHeightCst.constant + self.leadingLabel.height)/2;
    self.leadingLabelCst.constant = convertOffset;
    self.trailingLabelCst.constant = convertOffset;
}
- (void)addValueDot{
    CGFloat widthRange = (self.backbarView.bounds.size.width - self.valueDotSize)/(self.maxValue - self.minValue);
    for (NSInteger i = self.minValue; i <= self.maxValue; i++) {
        UIView *dotView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, self.valueDotSize, self.valueDotSize)];
        dotView.backgroundColor = self.valueDotColor;
        dotView.layer.cornerRadius = self.valueDotSize/2;
        NSInteger yOffset = self.valueObjectOffset;//-24;
        
        dotView.center = CGPointMake(widthRange*i + self.slidebarLeadingCst.constant + self.valueDotSize/2, self.backbarView.frame.origin.y + yOffset);
        [self.additionViews addObject:dotView];
        [self addSubview:dotView];
    }
}
- (void)addValueLabel{
    if (self.showTextValue == 0) {
        return;
    }
    CGFloat widthRange = self.backbarView.bounds.size.width/(self.maxValue - self.minValue);
    for (NSInteger i = self.minValue; i <= self.maxValue; i++) {
        if (self.showTextValue == 1 || (self.showTextValue == 2 && (i = self.minValue || i == self.maxValue))) {
            UILabel *label = [[UILabel alloc]initWithFrame:CGRectMake(0,0, widthRange, 16)];
            label.font = [UIFont systemFontOfSize:11];
            label.textColor = [UIColor colorWithHexString:@"777777"];
            label.textAlignment = NSTextAlignmentCenter;
            NSInteger yOffset = self.valueObjectOffset;
            label.center = CGPointMake(widthRange*(i - self.minValue) + self.slidebarLeadingCst.constant, self.backbarView.frame.origin.y + yOffset);
            label.text = [self textFromValue:i];
            [self.additionViews addObject:label];
            [self addSubview:label];
            
        }
    }
}

#pragma mark - Multi pan dot view
- (void)addTapToDotView:(UIView*)view{
    UILongPressGestureRecognizer *ges = [[UILongPressGestureRecognizer alloc]initWithTarget:self action:@selector(handleDotPan:)];
    ges.minimumPressDuration = 0.0f;
    [view addGestureRecognizer:ges];
}

- (void)handleDotPan:(UIGestureRecognizer *)recognizer{
    CGPoint point = [recognizer locationInView:recognizer.view.superview];
    if (recognizer.state == UIGestureRecognizerStateBegan) {
        [self refixUnit];
    }else if (recognizer.state == UIGestureRecognizerStateChanged) {
        CGPoint center = recognizer.view.center;
        center.x += point.x - self.initialPoint.x;
        if (self.isDotInRange) {
//            NSLog(@"Dot frame %@", NSStringFromCGRect(recognizer.view.frame));
            if (center.x - recognizer.view.frame.size.width/2 < self.backbarView.frame.origin.x) {
                center.x = self.backbarView.frame.origin.x + recognizer.view.frame.size.width/2;
            }
            if (center.x + recognizer.view.frame.size.width/2 > self.backbarView.frame.origin.x + self.backbarView.frame.size.width) {
                center.x = self.backbarView.frame.origin.x + self.backbarView.frame.size.width -  recognizer.view.frame.size.width/2 ;
            }
        }else{
            if (center.x < self.backbarView.frame.origin.x) {
                center.x = self.backbarView.frame.origin.x;
            }
            if (center.x > self.backbarView.frame.origin.x + self.backbarView.frame.size.width) {
                center.x = self.backbarView.frame.origin.x + self.backbarView.frame.size.width;
            }
        }
        recognizer.view.center = center;
        [self updateFloatDotLabel:recognizer.view];
        if (!self.isSingleValue) {
            self.frontbarView.frame = [self reframeFrontView];
        }
        [self correctValue];
        if ([self.delegate respondsToSelector:@selector(dlgAISliderViewOnChangingValue:)]) {
            [self.delegate dlgAISliderViewOnChangingValue:self];
        }
    }else if (recognizer.state == UIGestureRecognizerStateEnded){
        CGFloat val =  [self valueOfDot:recognizer.view];
        if (self.isFixValue) {
            NSInteger fixVal = (int)(val+0.5);
            [self moveDot:recognizer.view toValue: fixVal animation:true];
            [self updateFloatDotLabel:recognizer.view withValue:fixVal+self.minValue];
        }
        if (recognizer.view == self.firstDotView) {
            self.firstValue     = val;
        }else{
            self.secondValue    = val;
        }
        [self correctValue];
        if ([self.delegate respondsToSelector:@selector(dlgAISliderViewDidChangedValue:)]) {
            [self.delegate dlgAISliderViewDidChangedValue:self];
        }
    }
    self.initialPoint = point;
}

- (void)correctValue{
    CGFloat fValue = [self valueOfDot:self.firstDotView] + self.minValue;
    CGFloat sValue = [self valueOfDot:self.secondDotView] + self.minValue;
    if (self.isSingleValue) {
        self.firstValue = fValue;
    }else{
        if (fValue<sValue) {
            self.firstValue = fValue;
            self.secondValue = sValue;
        }else{
            self.firstValue = sValue;
            self.secondValue = fValue;
            
        }
    }
}

#pragma mark - Tap To Select Single Value

- (void)addTapToSelectSingleValue{
    UITapGestureRecognizer *tapGes = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(handleTapSingleValue:)];
    [self addGestureRecognizer:tapGes];
    
}
- (void)handleTapSingleValue:(UIGestureRecognizer *)recognizer{
    
    if (recognizer.state == UIGestureRecognizerStateEnded) {
        CGPoint point = [recognizer locationInView:self.backbarView];
        CGFloat val = point.x/self.rangeUnit;
        [self didSelectedSingleValue:val];
    }
}


#pragma  mark - Pan Progress

- (void)addPanProgress{
    
    UIPanGestureRecognizer *panGes = [[UIPanGestureRecognizer alloc]initWithTarget:self action:@selector(handleProgressPan:)];
    [self addGestureRecognizer:panGes];
}

- (void)handleProgressPan:(UIPanGestureRecognizer *)recognizer{
    CGPoint point = [recognizer locationInView:self.backbarView];
    CGFloat val = point.x/self.rangeUnit;
    
    if (recognizer.state == UIGestureRecognizerStateEnded) {
        [self didSelectedSingleValue:val];
    }else{
        [self onSelectingSingleValue:val];
    }
}


#pragma mark - helper

- (void)onSelectingSingleValue:(CGFloat)value{
    if (self.isRateMode) {
        NSInteger fixVal = (int)(value);
        for (int i = 0; i < self.rateViews.count; i++) {
            UIView *rateView = [self.rateViews objectAtIndex:i];
            if (i<fixVal) {
                rateView.alpha = 1;
            }else if (i>fixVal){
                rateView.alpha = 0;
            }else{
                rateView.alpha = value - fixVal ;
            }
        }
    }else{
        [self moveDot:self.firstDotView toValue:value animation:false];
        [self updateFloatDotLabel:self.firstDotView];
    }
}
- (void)didSelectedSingleValue:(CGFloat)value{
    
    if (self.isRateMode) {
        NSInteger fixVal = (int)(value+0.5);
        for (int i = 0; i < self.rateViews.count; i++) {
            UIView *rateView = [self.rateViews objectAtIndex:i];
            if (i+1<fixVal) {
                [rateView anmationAlpha:1];
            }else if(i+1>fixVal){
                [rateView anmationAlpha:0];
            }else{
                [rateView anmationAlpha:1];
                [rateView animationSpringScale:0.8];
            }
        }
        self.firstValue = fixVal;
    }else{
        NSInteger fixVal = (int)(value+0.5);
        if (self.isFixValue) {
            [self moveDot:self.firstDotView toValue:fixVal animation:true];
            self.firstValue = fixVal+self.minValue;
            
        }else{
            [self moveDot:self.firstDotView toValue:value animation:false];
            self.firstValue = value+self.minValue;
        }
        [self updateFloatDotLabel:self.firstDotView withValue:self.firstValue];
        [self correctValue];
    }
    if ([self.delegate respondsToSelector:@selector(dlgAISliderViewDidChangedValue:)]) {
        [self.delegate dlgAISliderViewDidChangedValue:self];
    }
}

- (CGRect)reframeFrontView{
    NSInteger minX = MIN(self.firstDotView.center.x, self.secondDotView.center.x);
    NSInteger maxX = MAX(self.firstDotView.center.x, self.secondDotView.center.x);
    CGRect frontFrame = self.backbarView.frame;
    frontFrame.origin.x = minX;
    frontFrame.size.width = maxX - minX;
    return frontFrame;
    
}
- (void)refixUnit{
    self.rangeUnit = self.backbarView.frame.size.width/ (self.maxValue - self.minValue);
//    NSLog(@"refixUnit %g",self.rangeUnit);
    
}
- (CGFloat)valueOfDot:(UIView*)dotView{
    if (self.isDotInRange) {
        return (dotView.center.x - (self.backbarView.frame.origin.x + dotView.frame.size.width/2))/((self.backbarView.frame.size.width-dotView.frame.size.width)/ (self.maxValue - self.minValue));
    }
    return (dotView.center.x - self.backbarView.frame.origin.x)/self.rangeUnit;
}

- (void)updateFloatDotLabel:(UIView*)view{
    if (!self.isShowFloatValue)return;
    CGFloat realVal = [self valueOfDot:view];
    [self updateFloatDotLabel:view withValue:realVal+self.minValue];
}
- (void)updateFloatDotLabel:(UIView*)view withValue:(CGFloat)value{
    UILabel * label = [view viewWithTag:110];
    if (label.hidden) {
        return;
    }
    if (self.isFixValue) {
        NSInteger displayVal = (int)(value+0.5);
        NSInteger oldVal = [label.text integerValue];
        if (oldVal!=displayVal) {
            [label animationSpringScale:2.0f];
            [label setText:[self textFromValue:displayVal]];
        }
    }else{
        [label setText:[self textFromValue:value]];
    }
}
- (void)moveDot:(UIView*)dotView toValue:(CGFloat)value animation:(BOOL)isAnimation{
    CGFloat moveVal = value;
    if (isAnimation) {
        
        [UIView animateWithDuration:0.2 animations:^{
            [self moveDot:dotView moveVal:moveVal];
        }];
    }else{
        
        [self moveDot:dotView moveVal:moveVal];
    }
}
- (void)moveDot:(UIView*)dotView moveVal:(CGFloat)moveVal{
    CGPoint center = CGPointMake(self.rangeUnit*(moveVal-self.minValue)+self.backbarView.frame.origin.x, self.backbarView.center.y +30);
    
    
    if (self.isDotInRange) {
//        NSLog(@"Dot frame %@", NSStringFromCGRect(dotView.frame));
        if (center.x - dotView.frame.size.width/2 < self.backbarView.frame.origin.x) {
            center.x = self.backbarView.frame.origin.x + dotView.frame.size.width/2;
        }
        if (center.x + dotView.frame.size.width/2 > self.backbarView.frame.origin.x + self.backbarView.frame.size.width) {
            center.x = self.backbarView.frame.origin.x + self.backbarView.frame.size.width -  dotView.frame.size.width/2 ;
        }
    }else{
        if (center.x < self.backbarView.frame.origin.x) {
            center.x = self.backbarView.frame.origin.x;
        }
        if (center.x > self.backbarView.frame.origin.x + self.backbarView.frame.size.width) {
            center.x = self.backbarView.frame.origin.x + self.backbarView.frame.size.width;
        }
    }
    
    dotView.center = center;
    
    if (!self.isSingleValue) {
        self.frontbarView.frame = [self reframeFrontView];
    }
}
- (NSString*)textFromValue:(CGFloat)val{
    switch (self.sliderType) {
        case AISliderTypeTextPlus:
            return [NSString stringWithFormat:@"%g+",val];
            break;
        case AISliderTypeCurrency:
//            return [NSString stringWithFormat:@"%.2f%@",val,self.symbol];
            return [NSString stringWithFormat:@"%g%@",val,self.symbol];
            break;
        case AISliderTypeHour:{
            NSInteger hour = (int)val;
            NSInteger minute = ((val - hour)*60+0.5);
            return [NSString stringWithFormat:@"%02ld:%02ld",(long)hour,(long)minute];
        }
            break;
            
        default:
            return [NSString stringWithFormat:@"%g",val];
            break;
    }
}
@end
