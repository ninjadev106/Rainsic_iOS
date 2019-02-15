//
//  AIAudioMixerManager.h
//  YoutubeSearch
//
//  Created by An Nguyen on 3/23/18.
//  Copyright © 2018 An Nguyen. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MediaPlayer/MediaPlayer.h>
#import <AVFoundation/AVFoundation.h>
#import <AVKit/AVKit.h>


typedef enum : NSUInteger {
    AIAudioStateStop,
    AIAudioStatePause,
    AIAudioStatePlaying,
} AIAudioState;


@class AIAudioNode;

@protocol AIAudioNodeDelegate <NSObject>
@optional
- (void)dlgAIAudioNode:(AIAudioNode*)sender state:(AIAudioState)state;
@end

@interface AIAudioNode : NSObject
@property (nonatomic, weak) id<AIAudioNodeDelegate> delegate;
@property (nonatomic) AVAudioFile* file;
@property (nonatomic) AVAudioPCMBuffer* buffer;
@property (nonatomic) AVAudioPlayerNode* player;
@property (nonatomic) NSArray<AVAudioNode*>* nodes;

@property (nonatomic) AVAudioFramePosition sampleDuration;
@property (nonatomic) CGFloat sampleRate;
@property (nonatomic) CGFloat duration;

- (BOOL)setURL:(NSURL*)url;
- (void)prepareSubBuffer;
- (void)stop;
- (void)play;
- (void)pause;

+ (AIAudioNode*)createFromURL:(NSURL*)url;


@end

@protocol AIAudioMixerManagerDelegate <NSObject>
@optional

- (void)dlgAIAudioMixerManagerState:(AIAudioState)state;
- (void)dlgAIAudioMixerManagerEndTrack;
- (void)dlgAIAudioMixerManagerPlayingTime:(CGFloat)second;
- (void)dlgAIAudioMixerManagerPlayingPercent:(CGFloat)percent;
- (void)dlgAIAudioMixerManagerRCCNext;
- (void)dlgAIAudioMixerManagerRCCPrevious;
- (void)dlgAIAudioMixerManagerRCCPlay;
- (void)dlgAIAudioMixerManagerRCCPause;

@end

@interface AIAudioMixerManager : NSObject
@property (nonatomic, weak) id<AIAudioMixerManagerDelegate> delegate;
@property (nonatomic) NSString* trackName;
@property (nonatomic) NSURL* fileURL;

@property (nonatomic, readonly) CGFloat duration;
@property (nonatomic, readonly) CGFloat position;
@property (nonatomic, readonly) AIAudioState state;
//@property (nonatomic) BOOL isSeeking;
@property (nonatomic) CGFloat rccXSpeed;
- (AIAudioNode*)addPlayerWithUnits:(NSArray<AVAudioNode*>*)units;
- (AIAudioNode*)addSubPlayerURL:(NSURL*)url withUnits:(NSArray<AVAudioNode*>*)units;
- (void)seek:(CGFloat)seconds;
- (void)seekPercent:(CGFloat)percent;
- (void)stop;
- (void)play;
- (void)pause;
- (void)forward:(CGFloat)value;
- (void)rewind:(CGFloat)value;
@end
