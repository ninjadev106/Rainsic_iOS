//
//  AIAudioMixerManager.m
//  YoutubeSearch
//
//  Created by An Nguyen on 3/23/18.
//  Copyright © 2018 An Nguyen. All rights reserved.
//

#import "AIAudioMixerManager.h"
#import "AIWeakTimer.h"

@interface AIAudioNode()

@property (nonatomic) BOOL subBuffer;
@end

@implementation AIAudioNode

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.player = [[AVAudioPlayerNode alloc]init];
    }
    return self;
}

- (BOOL)setURL:(NSURL*)url{
    
    if (!url) {
        return false;
    }
    NSError* error;
    AVAudioFile* audioFile = [[AVAudioFile alloc] initForReading:url error:&error];
    if (error) {
        return false;
    }
    
    self.file = audioFile;
    self.sampleDuration = audioFile.length;
    AVAudioFormat *songFormat = audioFile.processingFormat;
    self.sampleRate = songFormat.sampleRate;
    self.duration = self.sampleDuration/self.sampleRate;
    return true;
    
}

- (void)prepareSubBuffer{
    self.subBuffer = true;
    NSError* error;
    AVAudioPCMBuffer* buffer = [[AVAudioPCMBuffer alloc] initWithPCMFormat:[self.file processingFormat] frameCapacity:((AVAudioFrameCount ) self.file.length)];
    [self.file readIntoBuffer:buffer error:&error];
    self.buffer = buffer;
}

- (void)stop{
    [self.player stop];
    [self callbackPlayState:AIAudioStateStop];
    
}
- (void)play{
    if (self.subBuffer) {
        [self.player scheduleBuffer:self.buffer atTime:nil options:AVAudioPlayerNodeBufferLoops completionHandler:nil];
    }
    [self.player play];
    [self callbackPlayState:AIAudioStatePlaying];
    
}
- (void)pause{
    [self.player pause];
    [self callbackPlayState:AIAudioStatePause];
}

- (void)callbackPlayState:(AIAudioState)state{
    if ([self.delegate respondsToSelector:@selector(dlgAIAudioNode:state:)]) {
        [self.delegate dlgAIAudioNode:self state:state];
    }
}

+ (AIAudioNode*)createFromURL:(NSURL*)url{
    AIAudioNode* obj = [[AIAudioNode alloc]init];
    [obj setURL:url];
    return obj;
}
@end

@interface AIAudioMixerManager()
@property (nonatomic) AVAudioEngine *audioEngine;
@property (nonatomic) NSMutableArray<AIAudioNode*>* mainPlayers;
@property (nonatomic) NSMutableArray<AIAudioNode*>* subPlayers;
@property (nonatomic, readonly) AVAudioMixerNode* mixer;
@property (nonatomic, readonly) AVAudioPlayerNode* firstPlayer;
@property (nonatomic) AVAudioFormat *stereoFormat;
@property (nonatomic) AIAudioNode* mainNode;
@property (nonatomic) NSTimer *timer;

@property (nonatomic) CGFloat startTime;
@property (nonatomic) CGFloat lastTime;
@property (nonatomic) BOOL fileLoaded;
@property (nonatomic, readonly) BOOL nodeIsPlaying;

@property (weak, nonatomic) MPRemoteCommandCenter* commandCenter;
@property (weak, nonatomic) AVAudioSession *audioSession;
@end

@implementation AIAudioMixerManager

@synthesize state = _state;
- (instancetype)init
{
    self = [super init];
    if (self) {
        self.rccXSpeed = 1;
        [self initEnginer];
    }
    return self;
}

#pragma mark - GetSet
- (CGFloat)duration{
    return self.mainNode.duration;
}

- (AIAudioState)state{
    return _state;
}

- (NSString *)trackName{
    if (!_trackName) {
        return @"No name";
    }
    return _trackName;
}

- (CGFloat)position{
    CGFloat position = 0;
    AVAudioTime *nodeTime = self.firstPlayer.lastRenderTime;
    AVAudioTime *playerTime = [self.firstPlayer playerTimeForNodeTime:nodeTime];
    if (!nodeTime || !playerTime) {
        return 0;
    }
    position = self.startTime + (double)playerTime.sampleTime/playerTime.sampleRate;
    return position;
}

- (AVAudioPlayerNode*)firstPlayer{
    return self.mainPlayers.firstObject.player;
}

- (BOOL)nodeIsPlaying{
    for (AIAudioNode* node in self.mainPlayers) {
        if (node.player.isPlaying) {
            return true;
        }
    }
    return false;
}
- (AVAudioMixerNode *)mixer{
    return [self.audioEngine mainMixerNode];
}

- (void)setFileURL:(NSURL *)fileURL{
    self.fileLoaded = false;
    self.mainNode = [AIAudioNode createFromURL:fileURL];
    [self callbackNewTrack];
    [self initRemoteCommandCenter];
}

- (void)initEnginer{
    self.audioEngine = [[AVAudioEngine alloc] init];
    self.timer = [AIWeakTimer scheduledTimerWithTimeInterval:0.1 target:self selector:@selector(timerTracker)];
//    self.stereoFormat = [[AVAudioFormat alloc] initStandardFormatWithSampleRate:44100 channels:2];
}

- (void)timerTracker{
    if (self.nodeIsPlaying) {
        CGFloat position = self.position;
        if (position < 0){
//            [self seek:0];
        }else if(position > self.duration) {
            [self stop];
            [self callbackEndTrack];
        }else{
            [self callbackPlayState:AIAudioStatePlaying];
        }
        self.lastTime = position;
        [self callbackPosition];
    }else{
        if (self.state == AIAudioStatePlaying) {
            CGFloat position = self.position;
            [self callbackPosition];
            if (position < 0 || position > self.duration) {
                if (position < 0) {
                    self.lastTime = 0;
                }else{
                    self.lastTime = self.duration;
                    [self callbackEndTrack];
                }
                [self callbackPlayState:AIAudioStateStop];
            }else{
                [self callbackPlayState:AIAudioStatePause];
            }
        }
    }
}

- (AIAudioNode*)addPlayerWithUnits:(NSArray<AVAudioNode*>*)units{
    if (!self.mainPlayers) {
        self.mainPlayers = [NSMutableArray new];
    }
    
    AIAudioNode* audioNode = [[AIAudioNode alloc] init];
    audioNode.nodes = units;
    [self connectAudioNode:audioNode sub:false];
    
    [self.mainPlayers addObject:audioNode];
//    audioNode.player.volume = 0.1;
    return audioNode;
}

- (AIAudioNode*)addSubPlayerURL:(NSURL*)url withUnits:(NSArray<AVAudioNode*>*)units{
    if (!self.subPlayers) {
        self.subPlayers = [NSMutableArray new];
    }
    
    AIAudioNode* audioNode = [AIAudioNode createFromURL:url];
    audioNode.nodes = units;
    [self connectAudioNode:audioNode sub:true];
    [audioNode prepareSubBuffer];
    [self.subPlayers addObject:audioNode];
//    audioNode.player.volume = 0.1;
    return audioNode;
    
}
- (void)connectAudioNode:(AIAudioNode*)audioNode sub:(BOOL)sub{
    [self.audioEngine attachNode:audioNode.player];
    
    AVAudioNode* lastNode = audioNode.player;
    for (AVAudioNode* node in audioNode.nodes) {
        [self.audioEngine attachNode:node];
        [self.audioEngine connect:lastNode to:node format:self.stereoFormat];
        lastNode = node;
    }
//    if (sub) {
//        [self.audioEngine connect:lastNode to:self.mixer fromBus:0 toBus:1 format:self.stereoFormat];
//    }else{
        [self.audioEngine connect:lastNode to:self.mixer format:self.stereoFormat];
//    }
}

- (BOOL)startEnginerIfNeeded{
    
    NSError* error;
    if (!self.audioEngine.isRunning) {
        [self.audioEngine prepare];
        [self.audioEngine startAndReturnError:&error];
    }
    return error != nil;
}

- (void)pauseEnginerIfNeeded{
    if (self.audioEngine.isRunning) {
        [self.audioEngine pause];
    }
}

- (void)stopEnginerIfNeeded{
    if (self.audioEngine.isRunning) {
        [self.audioEngine stop];
    }
}

#pragma mark - Public API

- (void)seek:(CGFloat)seconds{
    NSLog(@"Seek to %f", seconds);
    if (seconds < 0) {
        seconds = 0;
    }
    if (seconds > self.duration) {
        seconds = self.duration;
    }
    self.startTime = seconds;
    
    unsigned long int startSample = (long int)floor(self.startTime*self.mainNode.sampleRate);
    long long int remainSample = self.mainNode.sampleDuration-startSample;
    
    [self stop];
    if (remainSample <= 0) {
        [self callbackEndTrack];
        return;
    }
    [self startEnginerIfNeeded];
    
    for (AIAudioNode* node in self.mainPlayers) {
        [node.player scheduleSegment:self.mainNode.file startingFrame:startSample frameCount:(AVAudioFrameCount)remainSample atTime:nil completionHandler:^{
        }];
    }
    self.fileLoaded = true;
    
    [self forcePlay];
}

- (void)seekPercent:(CGFloat)percent{
    [self seek:percent*self.duration];
}

- (void)stop{
    for (AIAudioNode* node in self.mainPlayers) {
        [node stop];
    }
    for (AIAudioNode* node in self.subPlayers) {
        [node stop];
    }
    [self stopEnginerIfNeeded];
    [self callbackPlayState:AIAudioStateStop];
}

- (void)play{
    NSLog(@"position %f, duration %f", self.position, self.duration);
    if (!self.fileLoaded) {
        [self seek:0];
        return;
    }
    if (self.lastTime >= self.duration) {
        [self stop];
        [self seek:0];
        return;
    }
    [self forcePlay];
}

- (void)forcePlay{
    
    [self startEnginerIfNeeded];
    for (AIAudioNode* node in self.mainPlayers) {
        [node play];
    }
    for (AIAudioNode* node in self.subPlayers) {
        [node play];
    }
    [self callbackPlayState:AIAudioStatePlaying];
}

- (void)pause{
    for (AIAudioNode* node in self.mainPlayers) {
        [node pause];
    }
    for (AIAudioNode* node in self.subPlayers) {
        [node pause];
    }
    [self pauseEnginerIfNeeded];
    [self callbackPlayState:AIAudioStatePause];
}

- (void)forward:(CGFloat)value{
    [self seek:self.position + value];
}
- (void)rewind:(CGFloat)value{
    [self seek:self.position - value];
}
#pragma mark - Callback Helper

- (void)callbackPosition{
    CGFloat position = self.position;
    if (position < 0) position = 0;
    if (position > self.duration) position = self.duration;
    CGFloat percent = position/self.mainNode.duration;
    [self callbackPlayingTime:position];
    [self callbackPlayingPercent:percent];
}

- (void)callbackPlayingTime:(CGFloat)time{
    if ([self.delegate respondsToSelector:@selector(dlgAIAudioMixerManagerPlayingTime:)]) {
        [self.delegate dlgAIAudioMixerManagerPlayingTime:time];
    }
}

- (void)callbackPlayingPercent:(CGFloat)percent{
    if ([self.delegate respondsToSelector:@selector(dlgAIAudioMixerManagerPlayingPercent:)]) {
        [self.delegate dlgAIAudioMixerManagerPlayingPercent:percent];
    }
}

- (void)callbackPlayState:(AIAudioState)state{
    _state = state;
    [self updateRemoteCommandCenter];
    if ([self.delegate respondsToSelector:@selector(dlgAIAudioMixerManagerState:)]) {
        [self.delegate dlgAIAudioMixerManagerState:self.state];
    }
}

- (void)callbackEndTrack{
    [self callbackPlayingTime:self.duration];
    [self callbackPlayingPercent:1];
    self.lastTime = self.duration;
    if ([self.delegate respondsToSelector:@selector(dlgAIAudioMixerManagerEndTrack)]) {
        [self.delegate dlgAIAudioMixerManagerEndTrack];
    }
}

- (void)callbackNewTrack{
    [self callbackPlayingTime:0];
    [self callbackPlayingPercent:0];
    self.lastTime = 0;
}

#pragma mark - RemoteCommandCenter

- (void)initRemoteCommandCenter{
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
        if ([self.delegate respondsToSelector:@selector(dlgAIAudioMixerManagerRCCNext)]) {
            [self.delegate dlgAIAudioMixerManagerRCCNext];
        }
        return MPRemoteCommandHandlerStatusSuccess;
    }];
    
    self.commandCenter.previousTrackCommand.enabled = true;
    [self.commandCenter.previousTrackCommand addTargetWithHandler:^MPRemoteCommandHandlerStatus(MPRemoteCommandEvent * _Nonnull event) {
        
        NSLog(@"previousTrackCommand");
        if ([self.delegate respondsToSelector:@selector(dlgAIAudioMixerManagerRCCPrevious)]) {
            [self.delegate dlgAIAudioMixerManagerRCCPrevious];
        }
        return MPRemoteCommandHandlerStatusSuccess;
    }];
    
    self.commandCenter.playCommand.enabled = true;
    [self.commandCenter.playCommand addTargetWithHandler:^MPRemoteCommandHandlerStatus(MPRemoteCommandEvent * _Nonnull event) {
        NSLog(@"playCommand");
        if ([self.delegate respondsToSelector:@selector(dlgAIAudioMixerManagerRCCPlay)]) {
            [self.delegate dlgAIAudioMixerManagerRCCPlay];
        }
        [self play];
        return MPRemoteCommandHandlerStatusSuccess;
    }];
    
    self.commandCenter.pauseCommand.enabled = true;
    [self.commandCenter.pauseCommand addTargetWithHandler:^MPRemoteCommandHandlerStatus(MPRemoteCommandEvent * _Nonnull event) {
        NSLog(@"pauseCommand");
        if ([self.delegate respondsToSelector:@selector(dlgAIAudioMixerManagerRCCPause)]) {
            [self.delegate dlgAIAudioMixerManagerRCCPause];
        }
        [self pause];
        return MPRemoteCommandHandlerStatusSuccess;
    }];
    [self updateRemoteCommandCenter];
    
    self.commandCenter.changePlaybackPositionCommand.enabled = true;
    [self.commandCenter.changePlaybackPositionCommand addTarget:self action:@selector(onChangePlaybackPositionCommand:)];
    
    [self updateRemoteCommandCenter];
}

- (MPRemoteCommandHandlerStatus) onChangePlaybackPositionCommand:(MPChangePlaybackPositionCommandEvent *) event {
    [self seek:event.positionTime];
    [self updateRemoteCommandCenter];
    return MPRemoteCommandHandlerStatusSuccess;
}

- (void)updateRemoteCommandCenter{
    //    CGFloat currentPosition = [self getCurrentPosition];
    //    NSLog(@"MPNowPlayingInfoPropertyElapsedPlaybackTime %f",lastTimeKnowed);
    [MPNowPlayingInfoCenter defaultCenter].nowPlayingInfo =
    @{MPMediaItemPropertyTitle:@"Music Player",
      MPMediaItemPropertyAlbumTitle:self.trackName,
      MPMediaItemPropertyPlaybackDuration:@(self.duration / self.rccXSpeed),
      MPNowPlayingInfoPropertyElapsedPlaybackTime:@(self.lastTime / self.rccXSpeed)
      };
}
@end
