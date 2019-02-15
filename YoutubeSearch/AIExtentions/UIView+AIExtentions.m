//
//  UIView+AIExtentions.m
//  Wegolala
//
//  Created by An Nguyen on 3/28/18.
//  Copyright © 2018 An Nguyen. All rights reserved.
//

#import "UIView+AIExtentions.h"

@implementation UIView (AIExtentions)


@dynamic borderColor,borderWidth,cornerRadius,addBottomLineColor,addShadow,addTopLineColor;

-(void)setBorderColor:(UIColor *)borderColor{
    [self.layer setBorderColor:borderColor.CGColor];
}

-(void)setBorderWidth:(CGFloat)borderWidth{
    [self.layer setBorderWidth:borderWidth];
}

-(void)setCornerRadius:(CGFloat)cornerRadius{
    [self.layer setCornerRadius:cornerRadius];
}

- (void)setAddShadow:(BOOL)addShadow{
    //    self.layer.borderColor = [[[UIColor blackColor] colorWithAlphaComponent:0.5] CGColor];
    //    self.layer.borderWidth = 0.5;
    self.layer.masksToBounds = NO;
    self.layer.shadowOffset = CGSizeMake(0, 0);
    self.layer.shadowRadius = 2;
    self.layer.shadowOpacity = 0.2;
    
}


- (void)setAddBottomLineColor:(UIColor *)addBottomLineColor{
    UIView *line = [[UIView alloc]initWithFrame:CGRectMake(0, self.bounds.size.height-1, self.bounds.size.width, 1)];
    line.backgroundColor = addBottomLineColor;
    [self addSubview:line];
    line.autoresizingMask = UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleWidth;
}

- (void)setAddTopLineColor:(UIColor *)addTopLineColor{
    UIView *line = [[UIView alloc]initWithFrame:CGRectMake(0,0, self.bounds.size.width, 1)];
    line.backgroundColor = addTopLineColor;
    [self addSubview:line];
    line.autoresizingMask = UIViewAutoresizingFlexibleBottomMargin |UIViewAutoresizingFlexibleWidth;
    
}

- (CGRect)frameInScreen{
    CGRect frame = [self.superview convertRect:self.frame toView:[UIApplication sharedApplication].keyWindow];
    return frame;
}

- (UIImage *)captureView {
    //hide controls if needed
    CGRect rect = [self bounds];
    
    UIGraphicsBeginImageContext(rect.size);
    CGContextRef context = UIGraphicsGetCurrentContext();
    [self.layer renderInContext:context];
    UIImage *img = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return img;
    
}

- (CGFloat)heightWithMaxWidth:(CGFloat)maxWidth{
    return self.frame.size.height;
}
@end
