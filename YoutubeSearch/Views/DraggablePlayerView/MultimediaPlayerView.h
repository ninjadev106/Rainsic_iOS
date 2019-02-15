//
//  MultimediaPlayerView.h
//  Playground
//
//  Created by An Nguyen on 12/24/17.
//  Copyright © 2017 An Nguyen. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AINibView.h"
#import "IMediaItem.h"

@interface MultimediaPlayerView : AINibView

@property (nonatomic) NSArray<id<IMediaItem>>* datasources;

- (void)showFull:(BOOL)isFull;
- (void)remove;
- (void)play:(id<IMediaItem>)item;
- (void)playAsFirstIfSuffered:(id<IMediaItem>)item;

+ (MultimediaPlayerView*)sharedInstance;
@end
