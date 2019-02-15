//
//  UIView+AIExtentions.h
//  Wegolala
//
//  Created by An Nguyen on 3/28/18.
//  Copyright © 2018 An Nguyen. All rights reserved.
//

#import "AIPopupController.h"

@interface UIView (AIExtentions)

@property (nonatomic) IBInspectable UIColor *borderColor;
@property (nonatomic) IBInspectable CGFloat borderWidth;
@property (nonatomic) IBInspectable CGFloat cornerRadius;
@property (nonatomic) IBInspectable BOOL addShadow;
@property (nonatomic) IBInspectable UIColor* addBottomLineColor;
@property (nonatomic) IBInspectable UIColor* addTopLineColor;

@property (nonatomic, readonly) CGRect frameInScreen;

- (UIImage *)captureView;
- (CGFloat)heightWithMaxWidth:(CGFloat)maxWidth;
@end
