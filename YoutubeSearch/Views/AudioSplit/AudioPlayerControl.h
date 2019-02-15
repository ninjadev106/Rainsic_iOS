//
//  AudioPlayerControl.h
//  YoutubeSearch
//
//  Created by An Nguyen on 1/29/18.
//  Copyright © 2018 An Nguyen. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>
#import <AVKit/AVKit.h>

@protocol AudioPlayerControlDelegate <NSObject>
@optional
- (void)dlgAudioPlayerControlSkipForward;
- (void)dlgAudioPlayerControlEndTrack;
- (void)dlgAudioPlayerControlSkipBackward;
- (void)dlgAudioPlayerControlPause;
- (void)dlgAudioPlayerControlPlaying;
- (void)dlgAudioPlayerControlPlayingTime:(CGFloat)second;
- (void)dlgAudioPlayerControlPlayingPercent:(CGFloat)percent;
- (void)dlgAudioPlayerControlBackPlaying:(BOOL)playing;
@end

@interface AudioPlayerControl : NSObject
@property (nonatomic, weak) id<AudioPlayerControlDelegate> delegate;
@property (nonatomic) NSURL* fileURL;
@property (nonatomic) NSString* trackName;
@property (nonatomic, readonly) CGFloat duration;
@property (nonatomic, readonly) CGFloat isPlaying;
@property BOOL isSeeking;
@property (nonatomic) CGFloat xSpeed;

- (void)initBackAudioURL:(NSURL*)fileURL;
- (void)playBackAudio:(BOOL)play;
- (void)toggleBackAudio;
- (void)initEnginerWithNodes:(NSArray<AVAudioNode*>*)nodes;
- (void)updatePlayingLockInfor;
- (void)seek:(CGFloat)time;
- (void)seekBy:(CGFloat)time;
- (void)seekPercent:(CGFloat)percent;
- (void)play;
- (void)pause;
- (void)stop;
@end
