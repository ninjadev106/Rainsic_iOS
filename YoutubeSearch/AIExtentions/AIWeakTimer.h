//
//  AIWeakTimer.h
//  YoutubeSearch
//
//  Created by An Nguyen on 1/11/18.
//  Copyright © 2018 An Nguyen. All rights reserved.
//

#import <Foundation/Foundation.h>
@interface AIWeakTimerTarget: NSObject

@end

@interface AIWeakTimer: NSObject
+ (NSTimer *)scheduledTimerWithTimeInterval:(NSTimeInterval)timeInterval target:(id)target selector:(SEL)selector;
@end
