//
//  AudioPlayerController.h
//  YoutubeSearch
//
//  Created by An Nguyen on 3/28/18.
//  Copyright © 2018 An Nguyen. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DeviceMediaModel.h"


@protocol AudioPlayerControllerDelegate <NSObject>
- (void)dlgAudioPlayerControllerSwitchFloatMode:(BOOL)floatMode;
@end

@interface AudioPlayerController : UIViewController
@property (nonatomic, weak) id<AudioPlayerControllerDelegate> delegate;
- (CGRect)frameOfFloatMode:(BOOL)floatMode;
- (void)minimizeIfNeeded;
- (void)fullScreenIfNeeded;

- (void)playAudio:(DeviceMediaModel*)audio inList:(NSArray<DeviceMediaModel*>*)playlist;

@end
