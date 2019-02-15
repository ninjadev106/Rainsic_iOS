//
//  UIViewAutoLayout.m
//  AIFramework
//
//  Created by An Nguyen on 9/25/17.
//  Copyright © 2017 An Nguyen. All rights reserved.
//

#import "UIView+AutoLayout.h"

@implementation UIView (AIAutoLayout)
- (void)aiPinEdgesToSuperviewEdges{
    if (self.superview==nil) {
        NSLog(@"No superview available");
        return;
    }
    [self aiPinTrailingToSuperview:0.f multi:1.f];
    [self aiPinLeadingToSuperview:0.f multi:1.f];
    [self aiPinTopToSuperview:0.f multi:1.f];
    [self aiPinBottomToSuperview:0.f multi:1.f];
}

- (NSLayoutConstraint*)aiPinTrailingToSuperview:(CGFloat)cst multi:(CGFloat)multi{
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
- (NSLayoutConstraint*)aiPinLeadingToSuperview:(CGFloat)cst multi:(CGFloat)multi{
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
- (NSLayoutConstraint*)aiPinTopToSuperview:(CGFloat)cst multi:(CGFloat)multi{
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
- (NSLayoutConstraint*)aiPinBottomToSuperview:(CGFloat)cst multi:(CGFloat)multi{
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

- (NSLayoutConstraint*)aiPinLeadingToTrailingView:(UIView*)view constraint:(CGFloat)cst multi:(CGFloat)multi{
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

- (NSLayoutConstraint*)aiPinTopToBottomView:(UIView*)view constraint:(CGFloat)cst multi:(CGFloat)multi{
    
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

- (NSLayoutConstraint*)aiPinWidthToWidthParentView:(UIView*)parentView constraint:(CGFloat)cst multi:(CGFloat)multi{
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
- (NSLayoutConstraint*)aiPinHeightToWidthParentView:(UIView*)parentView constraint:(CGFloat)cst multi:(CGFloat)multi{
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
- (NSLayoutConstraint*)aiPinWidthToWidthView:(UIView*)view constraint:(CGFloat)cst multi:(CGFloat)multi{
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

- (NSLayoutConstraint*)aiPinHeightToWidthView:(UIView*)view constraint:(CGFloat)cst multi:(CGFloat)multi{
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
- (NSLayoutConstraint*)aiPinWidthToConstrant:(CGFloat)cst{
    
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

- (NSLayoutConstraint*)aiPinHeightToConstrant:(CGFloat)cst{
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

- (NSLayoutConstraint*)aiPinTrailingToView:(UIView*)view constraint:(CGFloat)cst multi:(CGFloat)multi{
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
- (NSLayoutConstraint*)aiPinLeadingToView:(UIView*)view constraint:(CGFloat)cst multi:(CGFloat)multi{
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
- (NSLayoutConstraint*)aiPinTopToView:(UIView*)view constraint:(CGFloat)cst multi:(CGFloat)multi{
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
- (NSLayoutConstraint*)aiPinBottomToView:(UIView*)view constraint:(CGFloat)cst multi:(CGFloat)multi{
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
@end
