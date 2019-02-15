//
//  UIViewAutoLayout.h
//  AIFramework
//
//  Created by An Nguyen on 9/25/17.
//  Copyright © 2017 An Nguyen. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIView (AIAutoLayout)
- (void)aiPinEdgesToSuperviewEdges;
- (NSLayoutConstraint*)aiPinTrailingToSuperview:(CGFloat)cst multi:(CGFloat)multi;
- (NSLayoutConstraint*)aiPinLeadingToSuperview:(CGFloat)cst multi:(CGFloat)multi;
- (NSLayoutConstraint*)aiPinTopToSuperview:(CGFloat)cst multi:(CGFloat)multi;
- (NSLayoutConstraint*)aiPinBottomToSuperview:(CGFloat)cst multi:(CGFloat)multi;
- (NSLayoutConstraint*)aiPinLeadingToTrailingView:(UIView*)view constraint:(CGFloat)cst multi:(CGFloat)multi;
- (NSLayoutConstraint*)aiPinTopToBottomView:(UIView*)view constraint:(CGFloat)cst multi:(CGFloat)multi;
- (NSLayoutConstraint*)aiPinWidthToWidthParentView:(UIView*)parentView constraint:(CGFloat)cst multi:(CGFloat)multi;
- (NSLayoutConstraint*)aiPinHeightToWidthParentView:(UIView*)parentView constraint:(CGFloat)cst multi:(CGFloat)multi;
- (NSLayoutConstraint*)aiPinWidthToWidthView:(UIView*)view constraint:(CGFloat)cst multi:(CGFloat)multi;
- (NSLayoutConstraint*)aiPinHeightToWidthView:(UIView*)view constraint:(CGFloat)cst multi:(CGFloat)multi;
- (NSLayoutConstraint*)aiPinWidthToConstrant:(CGFloat)cst;
- (NSLayoutConstraint*)aiPinHeightToConstrant:(CGFloat)cst;

- (NSLayoutConstraint*)aiPinTrailingToView:(UIView*)view constraint:(CGFloat)cst multi:(CGFloat)multi;
- (NSLayoutConstraint*)aiPinLeadingToView:(UIView*)view constraint:(CGFloat)cst multi:(CGFloat)multi;
- (NSLayoutConstraint*)aiPinTopToView:(UIView*)view constraint:(CGFloat)cst multi:(CGFloat)multi;
- (NSLayoutConstraint*)aiPinBottomToView:(UIView*)view constraint:(CGFloat)cst multi:(CGFloat)multi;
@end
