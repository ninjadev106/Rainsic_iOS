//
//  NSTimerWeak.m
//  Home Caravan
//
//  Created by An Nguyen on 6/13/17.
//  Copyright © 2017 Home Caravavan. All rights reserved.
//

#import "NSTimerWeak.h"

@interface NSTimerWeak(){
    NSTimerWeakCallback _callback;
//    NSTimer *_timer;
    __weak NSObject* target;
    SEL selector;
}
@property (weak) NSObject *handler;
@property (weak) NSTimer *timer;
@property NSTimeInterval duration;

@end



@implementation NSTimerWeak

- (instancetype)initWithWeakHanlder:(__weak NSObject*)handler duration:(NSTimeInterval)duration callback:(NSTimerWeakCallback)callback
{
    self = [super init];
    if (self) {
        _duration = duration;
        _callback = callback;
        _handler = handler;
    }
    return self;
}

- (void)callBackHandle{
    if (_callback && _handler) {
        _callback();
    }else{
        [self stopTimer];
    }
}
- (void)stopTimer{
    
    NSLog(@"stopTimer");
    [self pauseTimer];
    _callback = nil;
    _handler = nil;
    
}
- (void)pauseTimer{
    [_timer invalidate];
    _timer = nil;
}
- (void)startInstant:(BOOL)isInstant{
    __weak NSTimerWeak *weakSelf = self;
    if (_timer) {
        [_timer invalidate];
    }
    _timer = [NSTimer scheduledTimerWithTimeInterval:self.duration target:weakSelf selector:@selector(callBackHandle) userInfo:nil repeats:true];
    if (isInstant) {
        [self callBackHandle];
    }
}

- (void)dealloc{
    NSLog(@"Timer dealloc");
}
@end
