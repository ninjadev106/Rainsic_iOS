//
//  NSTimerWeak.h
//  Home Caravan
//
//  Created by An Nguyen on 6/13/17.
//  Copyright © 2017 Home Caravavan. All rights reserved.
//

#import <Foundation/Foundation.h>
typedef void(^NSTimerWeakCallback) ();

@interface NSTimerWeak : NSObject
- (instancetype)initWithWeakHanlder:(__weak NSObject*)handler duration:(NSTimeInterval)duration callback:(NSTimerWeakCallback)callback;
- (void)stopTimer;
- (void)pauseTimer;
- (void)startInstant:(BOOL)isInstant;
@end
