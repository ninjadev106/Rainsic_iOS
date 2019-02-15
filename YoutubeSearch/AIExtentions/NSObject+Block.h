//
//  NSObject+Block.h
//  Home Caravan
//
//  Created by Dung Nguyen on 4/6/15.
//  Copyright (c) 2015 Inlumina Team. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface NSObject (Block)

- (void)performBlock:(void (^)())block afterDelay:(NSTimeInterval)delay;
- (void)performInBackgroundBlock:(void (^)())block;

@end
