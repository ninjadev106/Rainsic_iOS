//
//  AudioPlayerControl.m
//  YoutubeSearch
//
//  Created by An Nguyen on 1/29/18.
//  Copyright © 2018 An Nguyen. All rights reserved.
//

#import "AudioPlayerControl.h"
#import "AIWeakTimer.h"
#import <MediaPlayer/MediaPlayer.h>
#import "AppSession.h"

@interface AudioPlayerControl(){
    
    AVAudioFramePosition lengthSongSamples;
    float sampleRateSong;
    float lengthSongSeconds;
    float startInSongSeconds;
    float lastTimeKnowed;
    AVAudioFormat *stereoFormat;
}

@property AVAudioEngine *audioEngine;
@property AVAudioPlayerNode* audioPlayerNode;
@property AVAudioFile *audioFile;
@property AVAudioPlayerNode* backPlayerNode;
@property AVAudioFile *backFile;
@property (nonatomic,strong) AVAudioPCMBuffer *backBuffer;
@property (nonatomic) NSURL* backURL;
@property (nonatomic) NSTimer *timer;
@property (weak, nonatomic) MPRemoteCommandCenter* commandCenter;
@property (weak, nonatomic) AVAudioSession *audioSession;
@property (nonatomic) BOOL enablePlayback;
@property (nonatomic) NSMutableArray<AVAudioPlayerNode*>* mainPlayers;
@property (nonatomic) NSMutableArray<AVAudioPlayerNode*>* subPlayers;
@end

@implementation AudioPlayerControl
@synthesize xSpeed = _xSpeed;
- (CGFloat)xSpeed{
    if (_xSpeed <= 0) {
        return 1;
    }
    return _xSpeed;
}

- (void)setXSpeed:(CGFloat)xSpeed{
    _xSpeed = xSpeed;
    [self updatePlayingLockInfor];
}

- (NSString *)trackName{
    if (!_trackName) {
        return @"No name";
    }
    return _trackName;
}

- (CGFloat)duration{
    return lengthSongSeconds;
}

- (CGFloat)isPlaying{
    return self.audioPlayerNode.isPlaying;
}

- (void)initBackAudioURL:(NSURL*)fileURL{
    
    if (!fileURL) {
        return;
    }
    NSError* error;
    _backURL = fileURL;
    self.backFile = [[AVAudioFile alloc] initForReading:_backURL error:&error];
    
    self.backBuffer = [[AVAudioPCMBuffer alloc] initWithPCMFormat:[ self.backFile processingFormat] frameCapacity:((AVAudioFrameCount ) self.backFile.length)];
    [ self.backFile readIntoBuffer:self.backBuffer error:&error];
    
    self.backPlayerNode = [[AVAudioPlayerNode alloc]init];
    [self.audioEngine attachNode:self.backPlayerNode];
    AVAudioMixerNode *mainMixer = [self.audioEngine mainMixerNode];
    [self.audioEngine connect:self.backPlayerNode to:mainMixer fromBus:0 toBus:1 format:stereoFormat];
}


- (void)playBackAudio:(BOOL)play{
    self.enablePlayback = play;
    NSLog(@"Playback %@",play?@"True":@"False");
    if ([self.delegate respondsToSelector:@selector(dlgAudioPlayerControlBackPlaying:)]) {
        [self.delegate dlgAudioPlayerControlBackPlaying:self.enablePlayback];
    }
    if (!self.backBuffer) {
        return;
    }
    if (!self.audioEngine.isRunning) {
        return;
    }
    if (self.enablePlayback) {
        [self.backPlayerNode scheduleBuffer:self.backBuffer atTime:nil options:AVAudioPlayerNodeBufferLoops completionHandler:nil];
        [self.backPlayerNode play];
        self.backPlayerNode.volume = 0.8;
    }else{
        
        [self.backPlayerNode pause];
    }
}

- (void)toggleBackAudio{
    [self playBackAudio:!self.enablePlayback];
    
}

- (void)initEnginerWithNodes:(NSArray<AVAudioNode*>*)nodes{
    stereoFormat = [[AVAudioFormat alloc] initStandardFormatWithSampleRate:44100 channels:2];
    self.audioEngine = [[AVAudioEngine alloc] init];
    self.audioPlayerNode = [[AVAudioPlayerNode alloc]init];
    [self.audioEngine attachNode:self.audioPlayerNode];
    
    
    AVAudioNode* lastNode = self.audioPlayerNode;
    for (AVAudioNode* node in nodes) {
        [self.audioEngine attachNode:node];
        [self.audioEngine connect:lastNode to:node format:stereoFormat];
        lastNode = node;
    }
    AVAudioMixerNode *mainMixer = [self.audioEngine mainMixerNode];
    
    [self.audioEngine connect:lastNode to:mainMixer fromBus:0 toBus:0 format:stereoFormat];
//    [self.audioEngine connect:lastNode to:self.audioEngine.outputNode format:stereoFormat];
}

- (void)initRemotePlayback{
    [[UIApplication sharedApplication] beginReceivingRemoteControlEvents];
    self.audioSession = [AVAudioSession sharedInstance];
    NSError *error;
    
    // set the session category
    bool success = [self.audioSession setCategory:AVAudioSessionCategoryPlayback error:&error];
    if (!success) NSLog(@"Error setting AVAudioSession category after media services reset %@\n", [error localizedDescription]);
    
    // set the session active
    success = [self.audioSession setActive:YES error:&error];
    if (!success) NSLog(@"Error activating AVAudioSession after media services reset %@\n", [error localizedDescription]);
    
    //    [sessionInstance setDelegate:self];
    
    self.commandCenter = [MPRemoteCommandCenter sharedCommandCenter];
    
    self.commandCenter.nextTrackCommand.enabled = true;
    [self.commandCenter.nextTrackCommand addTargetWithHandler:^MPRemoteCommandHandlerStatus(MPRemoteCommandEvent * _Nonnull event) {
        
        NSLog(@"nextTrackCommand");
        if ([self.delegate respondsToSelector:@selector(dlgAudioPlayerControlSkipForward)]) {
            [self.delegate dlgAudioPlayerControlSkipForward];
        }
        return MPRemoteCommandHandlerStatusSuccess;
    }];
    
    self.commandCenter.previousTrackCommand.enabled = true;
    [self.commandCenter.previousTrackCommand addTargetWithHandler:^MPRemoteCommandHandlerStatus(MPRemoteCommandEvent * _Nonnull event) {
        
        NSLog(@"previousTrackCommand");
        if ([self.delegate respondsToSelector:@selector(dlgAudioPlayerControlSkipBackward)]) {
            [self.delegate dlgAudioPlayerControlSkipBackward];
        }
        return MPRemoteCommandHandlerStatusSuccess;
    }];
    
    self.commandCenter.playCommand.enabled = true;
    [self.commandCenter.playCommand addTargetWithHandler:^MPRemoteCommandHandlerStatus(MPRemoteCommandEvent * _Nonnull event) {
        NSLog(@"playCommand");
        [self play];
        return MPRemoteCommandHandlerStatusSuccess;
    }];
    
    self.commandCenter.pauseCommand.enabled = true;
    [self.commandCenter.pauseCommand addTargetWithHandler:^MPRemoteCommandHandlerStatus(MPRemoteCommandEvent * _Nonnull event) {
        NSLog(@"pauseCommand");
        [self pause];
        return MPRemoteCommandHandlerStatusSuccess;
    }];
    [self updatePlayingLockInfor];
}

- (void)updatePlayingLockInfor{
//    CGFloat currentPosition = [self getCurrentPosition];
//    NSLog(@"MPNowPlayingInfoPropertyElapsedPlaybackTime %f",lastTimeKnowed);
    [MPNowPlayingInfoCenter defaultCenter].nowPlayingInfo =
    @{MPMediaItemPropertyTitle:@"Music Player",
      MPMediaItemPropertyAlbumTitle:self.trackName,
      MPMediaItemPropertyPlaybackDuration:@(self.duration / self.xSpeed),
      MPNowPlayingInfoPropertyElapsedPlaybackTime:@(lastTimeKnowed / self.xSpeed)
      };
}


- (void)setFileURL:(NSURL *)fileURL{
    if (!fileURL) {
        return;
    }
    [self.audioPlayerNode stop];
    [self.backPlayerNode stop];
    [self.audioEngine stop];
    NSError* error;
    _fileURL = fileURL;
    self.audioFile = [[AVAudioFile alloc] initForReading:_fileURL error:&error];
    
    [self.audioPlayerNode scheduleFile:self.audioFile atTime:nil completionHandler:nil];
//    self.audioPlayerNode.volume = 0.3;
    [self.audioEngine startAndReturnError:nil];
    
    lengthSongSamples = self.audioFile.length;
    AVAudioFormat *songFormat = self.audioFile.processingFormat;
    sampleRateSong = songFormat.sampleRate;
    lengthSongSeconds = lengthSongSamples/sampleRateSong;
//    [self play];
    if (self.enablePlayback) {
        [self playBackAudio:true];
    }
    [self seek:0];
    [self initRemotePlayback];
}

- (void)play{
    [self updatePlayingLockInfor];
    if (!self.timer) {
        self.timer = [AIWeakTimer scheduledTimerWithTimeInterval:0.1 target:self selector:@selector(timerHandler)];
    }
    //    NSLog(@"Enginer is %@", self.audioEngine.isRunning?@"running":@"stopped");
    if (!self.audioEngine.isRunning) {
        [self.audioEngine startAndReturnError:nil];
        if (lastTimeKnowed >= lengthSongSeconds) {
            lastTimeKnowed = 0;
        }
        [self seek:lastTimeKnowed];
    }
    //    if (!self.audioPlayerNode.isPlaying) {
    [self.audioPlayerNode play];
    //        [self seek:[self getCurrentPosition]];
    //    }
    [self playBackAudio:self.enablePlayback];
    NSLog(@"play");
    if ([self.delegate respondsToSelector:@selector(dlgAudioPlayerControlPlaying)]) {
        [self.delegate dlgAudioPlayerControlPlaying];
    }
}
- (void)timerHandler{
    if (!self.isSeeking && self.audioPlayerNode.isPlaying) {
        CGFloat position = [self getCurrentPosition];
        if (position == lastTimeKnowed) {
            return;
        }
        lastTimeKnowed = position;
        CGFloat percent = position/lengthSongSeconds;
        if (percent > 1) {
            [self stop];
            if ([self.delegate respondsToSelector:@selector(dlgAudioPlayerControlEndTrack)]) {
                [self.delegate dlgAudioPlayerControlEndTrack];
            }
        }
        if (percent < 0) {
            return;
        }
        [self callDelegatePlayingTime:position];
        [self callDelegatePlayingPercent:percent];
//        self.seekBar.value = seekValue;
    }
    if (!self.audioPlayerNode.isPlaying || !self.audioEngine.isRunning) {
        [self pause];
    }
}

- (void)callDelegatePlayingTime:(float)time{
    if ([self.delegate respondsToSelector:@selector(dlgAudioPlayerControlPlayingTime:)]) {
        [self.delegate dlgAudioPlayerControlPlayingTime:time];
    }
}
- (void)callDelegatePlayingPercent:(float)percent{
    if ([self.delegate respondsToSelector:@selector(dlgAudioPlayerControlPlayingPercent:)]) {
        [self.delegate dlgAudioPlayerControlPlayingPercent:percent];
    }
}

- (void)pause{
    [self.audioEngine pause];
    [self.audioPlayerNode pause];
    if ([self.delegate respondsToSelector:@selector(dlgAudioPlayerControlPause)]) {
        [self.delegate dlgAudioPlayerControlPause];
    }
//    NSLog(@"pause");
}
- (void)stop{
    lastTimeKnowed = 0;
    [self updatePlayingLockInfor];
    
    [self.timer invalidate];
    self.timer = nil;
    [self.audioPlayerNode stop];
    [self playBackAudio:false];
    [self.audioEngine stop];
    if ([self.delegate respondsToSelector:@selector(dlgAudioPlayerControlPause)]) {
        [self.delegate dlgAudioPlayerControlPause];
    }
//    NSLog(@"stop");
}
- (CGFloat)getCurrentPosition{
    float elapsedSeconds = 0;
    if (self.audioPlayerNode.isPlaying) {
        AVAudioTime *nodeTime = self.audioPlayerNode.lastRenderTime;
        AVAudioTime *playerTime = [self.audioPlayerNode playerTimeForNodeTime:nodeTime];
        elapsedSeconds = startInSongSeconds + (double)playerTime.sampleTime/playerTime.sampleRate;
    }
    return elapsedSeconds;
}
- (void)seek:(CGFloat)time{
    NSLog(@"Seek to %f", time);
    if (time < 0) {
        return;
    }
    startInSongSeconds = time;
    unsigned long int startSample = (long int)floor(startInSongSeconds*sampleRateSong);
    unsigned long int lengthSamples = lengthSongSamples-startSample;
    [self.audioPlayerNode stop];
    if (lengthSamples > 0) {
        [self.audioPlayerNode scheduleSegment:self.audioFile startingFrame:startSample frameCount:(AVAudioFrameCount)lengthSamples atTime:nil completionHandler:^{
        }];
        [self play];
    }
    lastTimeKnowed = time;
    [self updatePlayingLockInfor];
}

- (void)seekBy:(CGFloat)time{
    NSLog(@"seekBy %f", time);
    CGFloat position  = [self getCurrentPosition];
    if (position == 0) {
        position = lastTimeKnowed;
    }
    CGFloat fixedTime = position+time;
    if (fixedTime < 0) {
        fixedTime = 0;
    }
    if (fixedTime > lengthSongSeconds) {
        [self seekPercent:1.0];
        [self callDelegatePlayingPercent:1.0];
        return;
    }
    [self seek:fixedTime];
}
- (void)seekPercent:(CGFloat)percent{
    CGFloat time = percent * lengthSongSeconds;
    [self seek:time];
}
@end
