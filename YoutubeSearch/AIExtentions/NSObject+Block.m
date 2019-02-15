//
//  NSObject+Block.m
//  Home Caravan
//
//  Created by Dung Nguyen on 4/6/15.
//  Copyright (c) 2015 Inlumina Team. All rights reserved.
//

#import "NSObject+Block.h"

@implementation NSObject (Block)

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
