//
//  UIView+Properties.m
//  AIFramework
//
//  Created by An Nguyen on 9/25/17.
//  Copyright © 2017 An Nguyen. All rights reserved.
//

#import "UIView+Properties.h"
#import "AIUtility.h"
@implementation UIView (AIProperties)


-(void)setAiX:(CGFloat)aiX{
    CGRect frame = self.frame;
    frame.origin.x = aiX;
    self.frame = frame;
}
- (CGFloat)aiX{
    return self.frame.origin.x;
}

- (void)setAiY:(CGFloat)aiY{
    
    CGRect frame = self.frame;
    frame.origin.y = aiY;
    self.frame = frame;
}
- (CGFloat)aiY{
    return self.frame.origin.y;
}

- (void)setAiWidth:(CGFloat)aiWidth{
    
    CGRect frame = self.frame;
    frame.size.width = aiWidth;
    self.frame = frame;
}

- (CGFloat)aiWidth{
    return self.frame.size.width;
}
- (void)setAiHeight:(CGFloat)aiHeight{
    
    CGRect frame = self.frame;
    frame.size.height = aiHeight;
    self.frame = frame;
}

- (CGFloat)aiHeight{
    return self.frame.size.height;
}


- (void)setAiRotation:(CGFloat)aiRotation{
    self.transform = CGAffineTransformMakeRotation([AIUtility aiDegreeToRadian:aiRotation]);//CGAffineTransformRotate(self.transform, [AIExtentions degreeToRadian:rotation]);
}

- (CGFloat)aiRotation{
    CGFloat radians = atan2f(self.transform.b, self.transform.a);
    CGFloat degrees = radians * (180 / M_PI);
    return degrees;
}

- (void)setAiDegree:(CGFloat)aiDegree{
    self.transform = CGAffineTransformMakeRotation([AIUtility aiDegreeToRadian:aiDegree]);
}

- (CGFloat)aiDegree{
    return -1;
}


@end
