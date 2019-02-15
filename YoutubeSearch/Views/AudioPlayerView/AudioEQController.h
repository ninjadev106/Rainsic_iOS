//
//  AudioTestViewController.h
//  YoutubeSearch
//
//  Created by An Nguyen on 1/11/18.
//  Copyright © 2018 An Nguyen. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DeviceMediaModel.h"

@protocol AudioEQControllerDelegate <NSObject>
- (void)dlgAudioEQControllerSwitchFloatMode:(BOOL)floatMode;
@end

@interface AudioEQController : UIViewController
@property (nonatomic, weak) id<AudioEQControllerDelegate> delegate;
- (void)playAudio:(DeviceMediaModel*)audio inList:(NSArray<DeviceMediaModel*>*)playlist;
- (CGRect)frameOfFloatMode:(BOOL)floatMode;
- (void)minimizeIfNeeded;
- (void)fullScreenIfNeeded;
@end
