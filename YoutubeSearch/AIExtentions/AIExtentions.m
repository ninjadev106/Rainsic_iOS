//  Created by An on 9/6/16.
//  Copyright © 2016 Mac. All rights reserved.
//

#import "AIExtentions.h"
#import <objc/runtime.h>
#import "NSDate+Utilities.h"

@implementation UIView (AIExtentions)

#pragma mark - Property

- (CGRect)frameWorld{
    CGRect frame = [self.superview convertRect:self.frameWorld toView:[UIApplication sharedApplication].keyWindow];
    return frame;
}

- (UIView *)firstResponseView{
    if (self.isFirstResponder) {
        return self;
    }
    for(UIView *view in self.subviews){
        UIView *frp = view.firstResponseView;
        if (frp) {
            return frp;
        }
    }
    return nil;
}

- (void)setDegree:(CGFloat)degree{
    self.transform = CGAffineTransformMakeRotation([AIExtentions ai_degreeToRadian:degree]);
}

- (CGFloat)degree{
    return -1;
}

- (void)setX:(CGFloat)x{
    CGRect frame = self.frame;
    frame.origin.x = x;
    self.frame = frame;
}
- (CGFloat)x{
    return self.frame.origin.x;
}

- (void)setY:(CGFloat)y{
    
    CGRect frame = self.frame;
    frame.origin.y = y;
    self.frame = frame;
}
- (CGFloat)y{
    return self.frame.origin.y;
}

- (void)setWidth:(CGFloat)width{
    
    CGRect frame = self.frame;
    frame.size.width = width;
    self.frame = frame;
}

- (CGFloat)width{
    return self.frame.size.width;
}
- (void)setHeight:(CGFloat)height{
    
    CGRect frame = self.frame;
    frame.size.height = height;
    self.frame = frame;
}

- (CGFloat)height{
    return self.frame.size.height;
}


- (void)setRotation:(CGFloat)rotation{
//    CGFloat radian = [AIExtentions degreeToRadian:rotation];
//    NSLog(@"radian %f",radian);
    self.transform = CGAffineTransformMakeRotation([AIExtentions ai_degreeToRadian:rotation]);//CGAffineTransformRotate(self.transform, [AIExtentions degreeToRadian:rotation]);
}

- (CGFloat)rotation{
    CGFloat radians = atan2f(self.transform.b, self.transform.a);
    CGFloat degrees = radians * (180 / M_PI);
    return degrees;
}

#define AIExtIndicatorTag 633

- (UIActivityIndicatorView*)showIndicatorView{
    UIActivityIndicatorView *spinnerView = [self getCurrentIndicatorView];
    spinnerView.frame = CGRectMake(self.frame.size.width - 24, (self.frame.size.height)/2-10, 20, 20);
    spinnerView.autoresizingMask = (UIViewAutoresizingFlexibleLeftMargin   |
                                    UIViewAutoresizingFlexibleTopMargin    );
    [spinnerView startAnimating];
    return spinnerView;
}

- (UIActivityIndicatorView*)showIndicatorViewCenter{
    UIActivityIndicatorView *spinnerView = [self getCurrentIndicatorView];
    spinnerView.center  = CGPointMake(self.frame.size.width/2, self.frame.size.height/2);
    spinnerView.autoresizingMask = (UIViewAutoresizingFlexibleLeftMargin   |
                                    UIViewAutoresizingFlexibleRightMargin  |
                                    UIViewAutoresizingFlexibleTopMargin    |
                                    UIViewAutoresizingFlexibleBottomMargin);
    [spinnerView startAnimating];
    return spinnerView;
}

- (UIActivityIndicatorView*)getCurrentIndicatorView{
    
    UIActivityIndicatorView *spinnerView;
    UIView *oldView = [self viewWithTag:AIExtIndicatorTag];
    CGRect frame    = CGRectMake(self.frame.size.width - 24, (self.frame.size.height)/2-10, 0, 0);
    if ([oldView isKindOfClass:[UIActivityIndicatorView class]]) {
        spinnerView         = (UIActivityIndicatorView*)oldView;
        spinnerView.frame   = frame;
    }else{
        spinnerView         = [[UIActivityIndicatorView alloc] initWithFrame:frame];
    }
    spinnerView.tag     = AIExtIndicatorTag;
    [self addSubview:spinnerView];
    return spinnerView;
}

- (void)removeIndicatorView{
    UIActivityIndicatorView *spinnerView = [self viewWithTag:AIExtIndicatorTag];
    if (spinnerView) {
        [spinnerView stopAnimating];
        [spinnerView removeFromSuperview];
    }
}

#pragma mark Animation

- (void)flash{
    self.alpha = 0.5;
    [UIView animateWithDuration:0.1 animations:^{
        self.alpha = 1;
    }];
}
- (void)animationAlpha:(CGFloat)alpha duration:(CGFloat)duration needRemove:(BOOL)needRemove byX:(CGFloat)byX byY:(CGFloat)byY needRestore:(BOOL)needRestore{
    if (alpha>0 && self.hidden) {
        self.hidden = false;
    }
    
    CGRect currentFrame = self.frame;
    
    CGRect anmiationFrame = self.frame;
    anmiationFrame.origin.x+=byX;
    anmiationFrame.origin.y+=byY;
    
    [UIView animateWithDuration:0.5 delay:0 usingSpringWithDamping:1 initialSpringVelocity:0.5 options:UIViewAnimationOptionTransitionNone animations:^{
        if (byX != 0 || byY != 0) {
            self.frame = anmiationFrame;
        }
        self.alpha = 1;
    } completion:^(BOOL finished) {
        if (alpha == 0) {
            self.hidden = true;
        }
        if (needRemove) {
            [self removeFromSuperview];
        }
        if (needRestore) {
            self.frame = currentFrame;
        }
        
    }];
    
}
- (void)alphaHide:(BOOL)isHide isRemove:(BOOL)isRemove{
    if (isHide && self.hidden) {
        return;
    }
    if (!isHide && !self.hidden && self.alpha>0) {
        return;
    }
    if (!isHide) {
        self.hidden = false;
    }
    [UIView animateWithDuration:0.2 animations:^{
        self.alpha = isHide?0:1;
    } completion:^(BOOL finished) {
        self.hidden = isHide;
        if (isHide && isRemove) {
            [self removeFromSuperview];
        }
    }];
}
- (void)alphaHide:(BOOL)isHide{
    [self alphaHide:isHide isRemove:false];
}

- (void)removeFromSuperviewAlpha{
    [self alphaHide:true isRemove:true];
}

- (void)animationSpringScale:(CGFloat)scale{
    [UIView animateWithDuration:0.1 animations:^{
        
        self.transform = CGAffineTransformScale(CGAffineTransformIdentity, scale, scale);
        
    } completion:^(BOOL finished) {
        [UIView animateWithDuration:0.1 animations:^{
            self.transform = CGAffineTransformScale(CGAffineTransformIdentity, 1, 1);
            
        }];
    }];
}
- (void)animationFlash{
    CGFloat currentAlpha = self.alpha;
    [UIView animateWithDuration:0.1 animations:^{
        self.alpha = 0;
        
    } completion:^(BOOL finished) {
        [UIView animateWithDuration:0.1 animations:^{
            self.alpha = currentAlpha;
            
        }];
    }];
}

- (void)animationLayerBlindFlashRepeat:(NSInteger)repeat{
    CAKeyframeAnimation *alpha = [CAKeyframeAnimation animationWithKeyPath:@"opacity"];
    alpha.duration = 1.0;
    alpha.repeatCount = repeat;
    alpha.values = @[@1.0, @0.0];
    alpha.keyTimes = @[@0.0, @1.0];
    [self.layer addAnimation:alpha forKey:nil];
}
- (void)animationLayerBlindFlashReverseRepeat:(NSInteger)repeat{
    CAKeyframeAnimation *alpha = [CAKeyframeAnimation animationWithKeyPath:@"opacity"];
    alpha.duration = 2.0;
    alpha.repeatCount = repeat;
    alpha.values = @[@1.0, @0.0, @1.0];
    //    alpha.keyTimes = @[@0.4, @0.35, @0.35];
    [self.layer addAnimation:alpha forKey:nil];
    
}
- (void)animationLayerPulsingRatio:(CGFloat)ratio repeat:(NSInteger)repeat{
    CAKeyframeAnimation *resize = [CAKeyframeAnimation animationWithKeyPath:@"transform.scale"];
    resize.duration = 1.0;
    resize.repeatCount = repeat;
    resize.values = @[@1.0, @(ratio)];
    resize.keyTimes = @[@0.0, @1.0];
    [self.layer addAnimation:resize forKey:nil];
    
}
- (void)animationLayerStop{
    [self.layer removeAllAnimations];
}
- (void)animationPreY:(CGFloat)y duration:(CGFloat)duration{
    CGRect currentFrame = self.frame;
    CGRect prevFrame = self.frame;
    prevFrame.origin.y = y;
    self.frame = prevFrame;
    [UIView animateWithDuration:0.5 delay:0 usingSpringWithDamping:1 initialSpringVelocity:0.5 options:UIViewAnimationOptionTransitionNone animations:^{
        self.frame = currentFrame;
//        self.alpha = 1;
    } completion:^(BOOL finished) {
    }];
}
- (void)animationBackY:(CGFloat)y duration:(CGFloat)duration{
    CGRect currentFrame = self.frame;
    CGRect animationFrame = self.frame;
    animationFrame.origin.y = y;
    [UIView animateWithDuration:0.5 delay:0 usingSpringWithDamping:1 initialSpringVelocity:0.5 options:UIViewAnimationOptionTransitionNone animations:^{
        self.frame = animationFrame;
//        self.alpha = 0;
    } completion:^(BOOL finished) {
        self.frame = currentFrame;
    }];
}

- (void)animationByY:(CGFloat)byY endY:(CGFloat)endY duration:(CGFloat)duration{
    CGRect endFrame = self.frame;
    endFrame.origin.y = endY;
    CGRect animationFrame = self.frame;
    animationFrame.origin.y += byY;
    
    [UIView animateWithDuration:0.5 delay:0 usingSpringWithDamping:1 initialSpringVelocity:0.5 options:UIViewAnimationOptionTransitionNone animations:^{
        self.frame = animationFrame;
    } completion:^(BOOL finished) {
        self.frame = endFrame;
    }];
}
- (void)animationX:(CGFloat)x duration:(CGFloat)duration{
    
    [UIView animateWithDuration:0.5 delay:0 usingSpringWithDamping:1 initialSpringVelocity:0.5 options:UIViewAnimationOptionTransitionNone animations:^{
        self.x = x;
    } completion:^(BOOL finished) {
    }];
}

- (void)anmationAlpha:(CGFloat)alpha{
    [UIView animateWithDuration:0.2 animations:^{
        self.alpha = alpha;
    }];
}
- (void)animationHideByY:(CGFloat)y duration:(CGFloat)duration restore:(BOOL)restore{
    
//    CGRect currentFrame = self.frame;
    [UIView animateWithDuration:0.5 delay:0 usingSpringWithDamping:1 initialSpringVelocity:0.5 options:UIViewAnimationOptionTransitionNone animations:^{
        self.y += y;
        self.alpha = 1;
    } completion:^(BOOL finished) {
    }];
}

- (void)animationRotationDegree:(CGFloat)degree{
    [UIView animateWithDuration:0.2 animations:^{
        self.transform = CGAffineTransformMakeRotation([AIExtentions ai_degreeToRadian:degree]);
//        self.transform = CGAffineTransformRotate(self.transform, [AIExtentions ai_degreeToRadian:degree]);
    }];
}
- (void)animationRotate:(CGFloat)toValue{
    CABasicAnimation *animation     = [CABasicAnimation animationWithKeyPath:@"transform.rotation"];
    animation.toValue               = @(toValue);
    animation.duration              = 0.2;
    animation.removedOnCompletion   = false;
    animation.fillMode              = kCAFillModeForwards;
    [self.layer addAnimation:animation forKey:nil];
}
#pragma mark - AddSubview

- (void)addSubviewInCenter:(UIView *)view{
    [self addSubview:view];
    [view centerInSuperView];
}

- (void)centerInSuperView{
    if (self.superview) {
        self.center = CGPointMake(self.superview.width/2.0f, self.superview.height/2.0f);
    }
}
#pragma AutoLayout

- (void)pinEdgesToSuperviewEdges{
    if (self.superview==nil) {
        NSLog(@"No superview available");
        return;
    }
    [self pinTrailingToSuperview:0.f multi:1.f];
    [self pinLeadingToSuperview:0.f multi:1.f];
    [self pinTopToSuperview:0.f multi:1.f];
    [self pinBottomToSuperview:0.f multi:1.f];
}

- (NSLayoutConstraint*)pinTrailingToSuperview:(CGFloat)cst multi:(CGFloat)multi{
    self.translatesAutoresizingMaskIntoConstraints = NO;
    NSLayoutConstraint *layout =[NSLayoutConstraint
                                   constraintWithItem:self
                                   attribute:NSLayoutAttributeTrailing
                                   relatedBy:NSLayoutRelationEqual
                                   toItem:self.superview
                                   attribute:NSLayoutAttributeTrailing
                                   multiplier:multi
                                   constant:cst];
    [self.superview addConstraint:layout];
    return layout;
    
}
- (NSLayoutConstraint*)pinLeadingToSuperview:(CGFloat)cst multi:(CGFloat)multi{
    self.translatesAutoresizingMaskIntoConstraints = NO;
    NSLayoutConstraint *layout =[NSLayoutConstraint
                                  constraintWithItem:self
                                  attribute:NSLayoutAttributeLeading
                                  relatedBy:NSLayoutRelationEqual
                                  toItem:self.superview
                                  attribute:NSLayoutAttributeLeading
                                  multiplier:multi
                                  constant:cst];
    [self.superview addConstraint:layout];
    return layout;
    
}
- (NSLayoutConstraint*)pinTopToSuperview:(CGFloat)cst multi:(CGFloat)multi{
    self.translatesAutoresizingMaskIntoConstraints = NO;
    NSLayoutConstraint *layout =[NSLayoutConstraint
                              constraintWithItem:self
                              attribute:NSLayoutAttributeTop
                              relatedBy:NSLayoutRelationEqual
                              toItem:self.superview
                              attribute:NSLayoutAttributeTop
                              multiplier:multi
                              constant:cst];
    [self.superview addConstraint:layout];
    return layout;
    
}
- (NSLayoutConstraint*)pinBottomToSuperview:(CGFloat)cst multi:(CGFloat)multi{
    self.translatesAutoresizingMaskIntoConstraints = NO;
    NSLayoutConstraint *layout =[NSLayoutConstraint
                                 constraintWithItem:self
                                 attribute:NSLayoutAttributeBottom
                                 relatedBy:NSLayoutRelationEqual
                                 toItem:self.superview
                                 attribute:NSLayoutAttributeBottom
                                 multiplier:multi
                                 constant:cst];
    [self.superview addConstraint:layout];
    return layout;
    
}

- (NSLayoutConstraint*)pinLeadingToTrailingView:(UIView*)view constraint:(CGFloat)cst multi:(CGFloat)multi{
    self.translatesAutoresizingMaskIntoConstraints = NO;
    NSLayoutConstraint *layout =[NSLayoutConstraint
                                  constraintWithItem:self
                                  attribute:NSLayoutAttributeLeading
                                  relatedBy:NSLayoutRelationEqual
                                  toItem:view
                                  attribute:NSLayoutAttributeTrailing
                                  multiplier:multi
                                  constant:cst];
    [self.superview addConstraint:layout];
    return layout;
    
//    NSLayoutConstraint *trailing =[NSLayoutConstraint
//                                  constraintWithItem:view
//                                  attribute:NSLayoutAttributeLeading
//                                  relatedBy:NSLayoutRelationEqual
//                                  toItem:self
//                                  attribute:NSLayoutAttributeTrailing
//                                  multiplier:multi
//                                  constant:cst];
//    [self.superview addConstraint:trailing];
    
}

- (NSLayoutConstraint*)pinTopToBottomView:(UIView*)view constraint:(CGFloat)cst multi:(CGFloat)multi{
    
    self.translatesAutoresizingMaskIntoConstraints = NO;
    NSLayoutConstraint *layout =[NSLayoutConstraint
                              constraintWithItem:self
                              attribute:NSLayoutAttributeTop
                              relatedBy:NSLayoutRelationEqual
                              toItem:view
                              attribute:NSLayoutAttributeBottom
                              multiplier:multi
                              constant:cst];
    [self.superview addConstraint:layout];
    return layout;
}

- (NSLayoutConstraint*)pinWidthToWidthParentView:(UIView*)parentView constraint:(CGFloat)cst multi:(CGFloat)multi{
    self.translatesAutoresizingMaskIntoConstraints = NO;
    NSLayoutConstraint *layout =[NSLayoutConstraint
                                 constraintWithItem:self
                                 attribute:NSLayoutAttributeWidth
                                 relatedBy:NSLayoutRelationEqual
                                 toItem:parentView
                                 attribute:NSLayoutAttributeWidth
                                 multiplier:multi
                                 constant:cst];
    [parentView addConstraint:layout];
    return layout;
}
- (NSLayoutConstraint*)pinHeightToWidthParentView:(UIView*)parentView constraint:(CGFloat)cst multi:(CGFloat)multi{
    self.translatesAutoresizingMaskIntoConstraints = NO;
    NSLayoutConstraint *layout =[NSLayoutConstraint
                                 constraintWithItem:self
                                 attribute:NSLayoutAttributeHeight
                                 relatedBy:NSLayoutRelationEqual
                                 toItem:parentView
                                 attribute:NSLayoutAttributeHeight
                                 multiplier:multi
                                 constant:cst];
    [parentView addConstraint:layout];
    return layout;
}
- (NSLayoutConstraint*)pinWidthToWidthView:(UIView*)view constraint:(CGFloat)cst multi:(CGFloat)multi{
    self.translatesAutoresizingMaskIntoConstraints = NO;
    NSLayoutConstraint *layout =[NSLayoutConstraint
                              constraintWithItem:self
                              attribute:NSLayoutAttributeWidth
                              relatedBy:NSLayoutRelationEqual
                              toItem:view
                              attribute:NSLayoutAttributeWidth
                              multiplier:multi
                              constant:cst];
    [self.superview addConstraint:layout];
    return layout;
}

- (NSLayoutConstraint*)pinHeightToWidthView:(UIView*)view constraint:(CGFloat)cst multi:(CGFloat)multi{
    self.translatesAutoresizingMaskIntoConstraints = NO;
    NSLayoutConstraint *layout =[NSLayoutConstraint
                                constraintWithItem:self
                                attribute:NSLayoutAttributeHeight
                                relatedBy:NSLayoutRelationEqual
                                toItem:view
                                attribute:NSLayoutAttributeHeight
                                multiplier:multi
                                constant:cst];
    [self.superview addConstraint:layout];
    return layout;
}
- (NSLayoutConstraint*)pinWidthToConstrant:(CGFloat)cst{
    
    self.translatesAutoresizingMaskIntoConstraints = NO;
    NSLayoutConstraint *layout =[NSLayoutConstraint
                                 constraintWithItem:self
                                 attribute:NSLayoutAttributeWidth
                                 relatedBy:NSLayoutRelationEqual
                                 toItem:nil
                                 attribute:NSLayoutAttributeNotAnAttribute
                                 multiplier:1.0f
                                 constant:cst];
    [self addConstraint:layout];
    return layout;
}

- (NSLayoutConstraint*)pinWidthLessEqualToConstrant:(CGFloat)cst{
    
    self.translatesAutoresizingMaskIntoConstraints = NO;
    NSLayoutConstraint *layout =[NSLayoutConstraint
                                 constraintWithItem:self
                                 attribute:NSLayoutAttributeWidth
                                 relatedBy:NSLayoutRelationLessThanOrEqual
                                 toItem:nil
                                 attribute:NSLayoutAttributeNotAnAttribute
                                 multiplier:1.0f
                                 constant:cst];
    [self addConstraint:layout];
    return layout;
}

- (NSLayoutConstraint*)pinHeightToConstrant:(CGFloat)cst{
    self.translatesAutoresizingMaskIntoConstraints = NO;
    NSLayoutConstraint *layout =[NSLayoutConstraint
                                 constraintWithItem:self
                                 attribute:NSLayoutAttributeHeight
                                 relatedBy:NSLayoutRelationEqual
                                 toItem:nil
                                 attribute:NSLayoutAttributeNotAnAttribute
                                 multiplier:1.0f
                                 constant:cst];
    [self addConstraint:layout];
    return layout;
}

- (NSLayoutConstraint*)pinTrailingToView:(UIView*)view constraint:(CGFloat)cst multi:(CGFloat)multi{
    self.translatesAutoresizingMaskIntoConstraints = NO;
    NSLayoutConstraint *layout =[NSLayoutConstraint
                                 constraintWithItem:self
                                 attribute:NSLayoutAttributeTrailing
                                 relatedBy:NSLayoutRelationEqual
                                 toItem:view
                                 attribute:NSLayoutAttributeTrailing
                                 multiplier:multi
                                 constant:cst];
    [self.superview addConstraint:layout];
    return layout;
}
- (NSLayoutConstraint*)pinLeadingToView:(UIView*)view constraint:(CGFloat)cst multi:(CGFloat)multi{
    self.translatesAutoresizingMaskIntoConstraints = NO;
    NSLayoutConstraint *layout =[NSLayoutConstraint
                                 constraintWithItem:self
                                 attribute:NSLayoutAttributeLeading
                                 relatedBy:NSLayoutRelationEqual
                                 toItem:view
                                 attribute:NSLayoutAttributeLeading
                                 multiplier:multi
                                 constant:cst];
    [self.superview addConstraint:layout];
    return layout;
}
- (NSLayoutConstraint*)pinTopToView:(UIView*)view constraint:(CGFloat)cst multi:(CGFloat)multi{
    self.translatesAutoresizingMaskIntoConstraints = NO;
    NSLayoutConstraint *layout =[NSLayoutConstraint
                                 constraintWithItem:self
                                 attribute:NSLayoutAttributeTop
                                 relatedBy:NSLayoutRelationEqual
                                 toItem:view
                                 attribute:NSLayoutAttributeTop
                                 multiplier:multi
                                 constant:cst];
    [self.superview addConstraint:layout];
    return layout;
}
- (NSLayoutConstraint*)pinBottomToView:(UIView*)view constraint:(CGFloat)cst multi:(CGFloat)multi{
    self.translatesAutoresizingMaskIntoConstraints = NO;
    NSLayoutConstraint *layout =[NSLayoutConstraint
                                 constraintWithItem:self
                                 attribute:NSLayoutAttributeBottom
                                 relatedBy:NSLayoutRelationEqual
                                 toItem:view
                                 attribute:NSLayoutAttributeBottom
                                 multiplier:multi
                                 constant:cst];
    [self.superview addConstraint:layout];
    return layout;
}
#pragma mark
- (void)removeAllSubviews{
    for(UIView *view in self.subviews){
        [view removeFromSuperview];
    }
}

#pragma mark Creator

+ (UIView *)loadWithNibNamed:(NSString *)nibNamed{
    
    return [UIView loadWithNibNamed:nibNamed owner:nil];
    
}
+ (UIView *)loadWithNibNamed:(NSString *)nibNamed owner:(nullable id)ownerOrNil{
    
    UINib * nib = [UINib nibWithNibName:nibNamed bundle:nil];
    Class class = NSClassFromString(nibNamed);
    
    NSArray * objects = [nib instantiateWithOwner:ownerOrNil options:nil];
    if (objects == nil) {
        NSLog(@"Couldn't load nib named %@", nibNamed);
        return nil;
    }
    
    for (id object in objects) {
        if ([object isKindOfClass:class]) {
            return object;
        }
    }
    return nil;
    
}
@end


static NSString *kHandlerAssociatedKey = @"kHandlerAssociatedKey";

@implementation UIAlertView (AIExtentions)

#pragma mark - Showing

/*
 * Shows the receiver alert with the given handler.
 */
- (void)showWithHandler:(UIAlertViewHandler)handler {
    objc_setAssociatedObject(self, (__bridge const void *)(kHandlerAssociatedKey), handler, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    
    [self setDelegate:self];
    [self show];
}

#pragma mark - UIAlertViewDelegate

/*
 * Sent to the delegate when the user clicks a button on an alert view.
 */
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    
    UIAlertViewHandler completionHandler = objc_getAssociatedObject(self, (__bridge const void *)(kHandlerAssociatedKey));
    
    if (completionHandler != nil) {
        
        completionHandler(buttonIndex == 1);
//        completionHandler(alertView, buttonIndex == 1);
    }
}

#pragma mark - Utility methods


+ (void)showMessage:(NSString*)msg{
    UIAlertView *alert = [[UIAlertView alloc]initWithTitle:nil
                                                   message:msg
                                                  delegate:nil
                                         cancelButtonTitle:NSLocalizedString(@"OK", @"")
                                         otherButtonTitles:nil, nil];
    [alert show];
}
+ (void)showYesNo:(NSString*)msg callback:(UIAlertViewHandler)callback{
    
    
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil
                                                    message:msg
                                                   delegate:nil
                                          cancelButtonTitle:NSLocalizedString(@"No", @"")
                                          otherButtonTitles:NSLocalizedString(@"Yes", @""), nil];
    
    [alert showWithHandler:callback];
}

+ (void)showComfirm:(NSString*)msg yesButton:(NSString*)yesButton callback:(UIAlertViewHandler)callback{
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil
                                                    message:msg
                                                   delegate:nil
                                          cancelButtonTitle:NSLocalizedString(@"No", @"")
                                          otherButtonTitles:NSLocalizedString(yesButton, @""), nil];
    
    [alert showWithHandler:callback];
}
@end


@implementation AIExtentions

+ (void)ai_dismissKeyboard{
    [[UIApplication sharedApplication] sendAction:@selector(resignFirstResponder) to:nil from:nil forEvent:nil];
}
+ (CGFloat)ai_degreeToRadian:(CGFloat)degree{
    return degree * M_PI / 180;
}
+ (CGFloat)ai_radianToDegree:(CGFloat)radian{
    
    return radian * 180 / M_PI;
}

+ (NSInteger)ai_randomIntFrom:(NSInteger)from to:(NSInteger)to{
    return  arc4random_uniform(to - from + 1) + from;
}
+ (NSString*)ai_filePath:(NSString*)fileName{
    
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    return [documentsDirectory stringByAppendingPathComponent:fileName];
}
+ (UIViewController*)veryTopViewController{
    UIViewController *topController = [UIApplication sharedApplication].keyWindow.rootViewController;
    while (topController.presentedViewController) {
        topController = topController.presentedViewController;
    }
    return topController;
}
@end


@implementation UIImageView (AIExtentions)

- (void)animationChangeImageNamed:(NSString*)imageNamed{
    [self animationChangeImage:[UIImage imageNamed:imageNamed]];
}
- (void)animationChangeImage:(UIImage*)image{
    [UIView animateWithDuration:0.2 animations:^{
        self.alpha = 0;
    } completion:^(BOOL finished) {
        self.image = image;
        [UIView animateWithDuration:0.2 animations:^{
            self.alpha = 1;
        }];
    }];
}
@end

@implementation UILabel (AIExtentions)
- (void)textAnimation:(NSString*)text{
    [UIView animateWithDuration:0.2 animations:^{
        self.alpha = 0;
    } completion:^(BOOL finished) {
        self.text = text;
        [UIView animateWithDuration:0.2 animations:^{
            self.alpha = 1;
        }];
    }];
}
@end

#import "UIColor+HexString.h"

@implementation UIColor (AIExtentions)
+ (UIColor*)randomColor{
    NSInteger aRedValue = arc4random()%255;
    NSInteger aGreenValue = arc4random()%255;
    NSInteger aBlueValue = arc4random()%255;
    
    UIColor *randColor = [UIColor colorWithRed:aRedValue/255.0f green:aGreenValue/255.0f blue:aBlueValue/255.0f alpha:1.0f];
    
    return randColor;
}

+ (UIColor*)colorWithHexString:(NSString*)hex
{
    NSString *cString = [[hex stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]] uppercaseString];
    
    // String should be 6 or 8 characters
    if ([cString length] < 6) return [UIColor grayColor];
    
    // strip 0X if it appears
    if ([cString hasPrefix:@"0X"]) cString = [cString substringFromIndex:2];
    
    if ([cString length] != 6) return [UIColor grayColor];
    
    // Separate into r, g, b substrings
    NSRange range;
    range.location = 0;
    range.length = 2;
    NSString *rString = [cString substringWithRange:range];
    
    range.location = 2;
    NSString *gString = [cString substringWithRange:range];
    
    range.location = 4;
    NSString *bString = [cString substringWithRange:range];
    
    // Scan values
    unsigned int r, g, b;
    [[NSScanner scannerWithString:rString] scanHexInt:&r];
    [[NSScanner scannerWithString:gString] scanHexInt:&g];
    [[NSScanner scannerWithString:bString] scanHexInt:&b];
    
    return [UIColor colorWithRed:((float) r / 255.0f)
                           green:((float) g / 255.0f)
                            blue:((float) b / 255.0f)
                           alpha:1.0f];
}

@end

@implementation UIButton (AIExtentions)
- (void)moveImageToRight{
    self.transform = CGAffineTransformMakeScale(-1.0, 1.0);
    self.titleLabel.transform = CGAffineTransformMakeScale(-1.0, 1.0);
    self.imageView.transform = CGAffineTransformMakeScale(-1.0, 1.0);
}
@end

@implementation NSObject (AIExtentions)

+ (BOOL)ai_isNil:(NSObject*)obj{
    if (!obj || [obj isKindOfClass:[NSNull class]]) {
        return true;
    }
    return false;
}
- (void)performBlock:(void (^)())block {
    block();
}

- (void)performBlock:(void (^)())block afterDelay:(NSTimeInterval)delay {
    void (^block_)() = [block copy];
    [self performSelector:@selector(performBlock:) withObject:block_ afterDelay:delay];
}

- (void)performInBackgroundBlock:(void (^)())block {
    void (^block_)() = [block copy];
    [self performSelectorInBackground:@selector(performBlock:) withObject:block_];
}

@end
@implementation NSError (AIExtentions)
+ (NSError*)ai_createFromString:(NSString*)string{
    NSDictionary *userInfo = @{
                               NSLocalizedDescriptionKey: NSLocalizedString(string, nil),
                               NSLocalizedFailureReasonErrorKey: NSLocalizedString(string, nil),
                               NSLocalizedRecoverySuggestionErrorKey: NSLocalizedString(string, nil)
                               };
    NSError *error = [NSError errorWithDomain:@"homecaravan.com"
                                         code:-57
                                     userInfo:userInfo];
    return error;
}
@end
@implementation NSString (AIExtentions)
+ (NSString*)ai_shortNumberwithSuffix:(NSNumber*)number{
    if (!number)
        return @"";
    
    long long num = [number longLongValue];
    
    int s = ( (num < 0) ? -1 : (num > 0) ? 1 : 0 );
    NSString* sign = (s == -1 ? @"-" : @"" );
    
    num = llabs(num);
    
    if (num < 1000)
        return [NSString stringWithFormat:@"%@%lld",sign,num];
    
    int exp = (int) (log10l(num) / 3.f); //log10l(1000));
    
    NSArray* units = @[@"K",@"M",@"G",@"T",@"P",@"E"];
    if (exp>1) {
        
        return [NSString stringWithFormat:@"%@%.2f%@",sign, (num / pow(1000, exp)), [units objectAtIndex:(exp-1)]];
    }
    return [NSString stringWithFormat:@"%@%.0f%@",sign, (num / pow(1000, exp)), [units objectAtIndex:(exp-1)]];
    
}
+ (NSString*)shortNumberwithSuffix:(NSNumber*)number{
    return [NSString ai_shortNumberwithSuffix:number];
}

+ (NSString*)stringFromInt:(NSInteger)num{
    return [NSString stringWithFormat:@"%ld",(long)num];
}
- (NSString*)ai_concat:(NSString*)string{
    return [NSString stringWithFormat:@"%@%@",self,string];
}

+ (BOOL)ai_isEmpty:(NSString*)string{
    if (!string || [string isKindOfClass:[NSNull class]]) {
        return true;
    }
    NSString *trim = [string trimBlank];
    if (trim.length==0) {
        return true;
    }
    return false;
}

+ (BOOL)ai_isEmail:(NSString*)string{
    if (!string) {
        return false;
    }
    NSString *phoneRegex = @"^\\w+([-+.]\\w+)*@\\w+([-.]\\w+)*\\.\\w+([-.]\\w+)*$";
    NSPredicate *phoneTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", phoneRegex];
    
    return [phoneTest evaluateWithObject:[string trimBlank]];
    
}
+ (BOOL)ai_isPhoneNumber:(NSString*)string{
    if (!string) {
        return false;
    }
    NSString *phoneRegex = @"^(1[ \\-\\+]{0,3}|\\+1[ -\\+]{0,3}|\\+1|\\+)?((\\(\\+?1-[2-9][0-9]{1,2}\\))|(\\(\\+?[2-8][0-9][0-9]\\))|(\\(\\+?[1-9][0-9]\\))|(\\(\\+?[17]\\))|(\\([2-9][2-9]\\))|([ \\-\\.]{0,3}[0-9]{2,4}))?([ \\-\\.][0-9])?([ \\-\\.]{0,3}[0-9]{2,4}){2,3}$";//82@"^((\\+)|(00))[0-9]{6,14}$";
    NSPredicate *phoneTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", phoneRegex];
    
    return [phoneTest evaluateWithObject:[string trimBlank]] && string.length>9;
}
+ (BOOL)ai_concat:(NSString*)string{
    if (!string) {
        return true;
    }
    NSString *trimmedString = [string trimBlank];
    return trimmedString.length==0;
}
- (NSString*)trimBlank{
    return [self stringByTrimmingCharactersInSet:
     [NSCharacterSet whitespaceCharacterSet]];
}
- (NSString*)ai_stringNumberWithoutCommas{
    return [self stringByReplacingOccurrencesOfString:@"," withString:@""];;
}
- (NSString*)ai_stringNumberWithCommas{
    
    NSNumberFormatter *f = [[NSNumberFormatter alloc] init];
    f.numberStyle = NSNumberFormatterDecimalStyle;
    NSString *result = [f stringFromNumber:[f numberFromString:self]];
    return result;
}
+ (NSString*)ai_stringNumberWithCommasFromFloat:(CGFloat)number{
    return [[NSString stringWithFormat:@"%g", number] ai_stringNumberWithCommas];
}
+ (NSString*)ai_stringNumberWithCommasFromInt:(NSInteger)number{
    return [[NSString stringWithFormat:@"%ld", (long)number] ai_stringNumberWithCommas];
    
}

@end

@implementation NSMutableArray (AIExtentions)
- (void)ai_shuffle{
    NSUInteger count = [self count];
    if (count <= 1) return;
    for (NSUInteger i = 0; i < count - 1; ++i) {
        NSInteger remainingCount = count - i;
        NSInteger exchangeIndex = i + arc4random_uniform((u_int32_t )remainingCount);
        [self exchangeObjectAtIndex:i withObjectAtIndex:exchangeIndex];
    }
}
@end

@implementation NSDate (AIExtentions)
+ (NSDate*)dateWithYear:(NSInteger)year month:(NSInteger)month day:(NSInteger)day{
    NSDateComponents *comps = [[NSDateComponents alloc] init];
    [comps setYear:year];
    [comps setMonth:month];
    [comps setDay:day];
//    [comps setHour:[self.timePickerView selectedRowInComponent:0] + [self.timePickerView selectedRowInComponent:2]*12];
//    [comps setMinute:[self.timePickerView selectedRowInComponent:1]*5];
    return [[NSCalendar currentCalendar] dateFromComponents:comps];
}

- (NSDate*)dateWithClearTime{
    return [NSDate dateWithYear:self.year month:self.month day:self.day];
}
@end
