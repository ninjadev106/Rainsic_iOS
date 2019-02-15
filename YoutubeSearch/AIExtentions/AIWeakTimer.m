//
//  AIWeakTimer.m
//  YoutubeSearch
//
//  Created by An Nguyen on 1/11/18.
//  Copyright © 2018 An Nguyen. All rights reserved.
//

#import "AIWeakTimer.h"

@interface AIWeakTimerTarget ()
@property (weak)   NSObject* target;
@property (assign) SEL selector;
@property (weak)   NSTimer* timer;
@end

@implementation AIWeakTimerTarget

- (void)fire{
    if (self.target){
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
        [self.target performSelector:self.selector withObject:nil];
#pragma clang diagnostic pop
    }else{
        [self.timer invalidate];
    }
}

@end

@implementation AIWeakTimer
+ (NSTimer *) scheduledTimerWithTimeInterval:(NSTimeInterval)timeInterval target:(id)target selector:(SEL)selector{
    AIWeakTimerTarget* timerTarget = [[AIWeakTimerTarget alloc] init];
    timerTarget.target = target;
    timerTarget.selector = selector;
    timerTarget.timer = [NSTimer scheduledTimerWithTimeInterval:timeInterval target:timerTarget selector:@selector(fire) userInfo:nil repeats:true];
    return timerTarget.timer;
}

@end


