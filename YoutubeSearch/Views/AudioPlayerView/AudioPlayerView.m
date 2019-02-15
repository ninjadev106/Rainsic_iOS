//
//  AudioPlayerView.m
//  YoutubeSearch
//
//  Created by An Nguyen on 1/10/18.
//  Copyright © 2018 An Nguyen. All rights reserved.
//

#import "AudioPlayerView.h"
#import <AVKit/AVKit.h>
#import "AIWeakTimer.h"

@interface AudioPlayerView(){
    
    AVAudioFramePosition lengthSongSamples;
    float sampleRateSong;
    float lengthSongSeconds;
    float startInSongSeconds;
}
@property (weak, nonatomic) IBOutlet UISlider *seekBar;
@property (weak, nonatomic) IBOutlet UISlider *speedBar;
@property (weak, nonatomic) IBOutlet UISlider *pitchBar;

@property (nonatomic) NSTimer *timer;


//@property AVAudioPlayer* audioPlayer;
@property AVAudioEngine *audioEngine;
@property AVAudioPlayerNode* audioPlayerNode;
@property AVAudioFile *audioFile;
@property AVAudioUnitTimePitch *changePitchEffect;
@property AVAudioUnitEQ *equalizer;
@property AVAudioEnvironmentNode *mixer;
@property BOOL isSeeking;

@end

@implementation AudioPlayerView

- (void)initCustom{
    [super initCustom];
    [self initAudio];
    [self initSeekBar];
    
}

- (void)initAudio{
    [self playTest];
}

- (void)playTest{
    [self initFileEngine];
    [self initAudioNode];
}

- (void)initSeekBar{
    [self.seekBar setThumbImage:[UIImage imageNamed:@""] forState:(UIControlStateNormal)];
    [self.seekBar addTarget:self action:@selector(onSliderValChanged:forEvent:) forControlEvents:UIControlEventValueChanged];
}

- (void)initFileEngine{
    
    NSString *filePath = [[NSBundle mainBundle] pathForResource:@"noo" ofType:@"mp3"];
    NSError *err;
    NSURL* mp3Url = [NSURL fileURLWithPath:filePath];
    self.audioEngine = [[AVAudioEngine alloc] init];
    self.audioFile = [[AVAudioFile alloc] initForReading:mp3Url error:&err];
    NSLog(@"Audio Leng %lld", self.audioFile.length);
    NSLog(@"Audio sampleRate %f", self.audioFile.fileFormat.sampleRate);
    NSLog(@"Audio duration %f", self.audioFile.length/(double)self.audioFile.fileFormat.sampleRate);
    
    AVAudioSession*session = [AVAudioSession sharedInstance];
    [session setCategory:AVAudioSessionCategoryPlayAndRecord error:nil];
    [session overrideOutputAudioPort:AVAudioSessionPortOverrideSpeaker error:nil];
}

- (void)playAudio{
    if (!self.timer) {
        self.timer = [AIWeakTimer scheduledTimerWithTimeInterval:0.1 target:self selector:@selector(timerHandler)];
    }
    [self.audioPlayerNode play];
    NSLog(@"playAudio");
}
- (void)timerHandler{
    if (!self.isSeeking && self.audioPlayerNode.isPlaying) {
        CGFloat seekValue = [self getCurretnPosition]/lengthSongSeconds;
        self.seekBar.value = seekValue;
    }
}
- (void)pauseAudio{
    [self.audioPlayerNode pause];
    NSLog(@"pauseAudio");
}
- (void)stopAudio{
    [self.timer invalidate];
    [self.audioPlayerNode stop];
    NSLog(@"stopAudio");
}

- (void)initAudioNode{
    self.audioPlayerNode = [[AVAudioPlayerNode alloc]init];
//    [self.audioPlayerNode addObserver:self forKeyPath:@"playing" options:NSKeyValueObservingOptionNew | NSKeyValueObservingOptionOld context:nil];
    [self.audioEngine attachNode:self.audioPlayerNode];
    
    self.changePitchEffect = [[AVAudioUnitTimePitch alloc]init];
    self.changePitchEffect.pitch = 0;
    [self.audioEngine attachNode:self.changePitchEffect];
    
    
    self.equalizer = [[AVAudioUnitEQ alloc] initWithNumberOfBands:10];
    [self.audioEngine attachNode:self.equalizer];
    [self applyEQPop];
    
    [self.audioEngine connect:self.audioPlayerNode to:self.equalizer format:nil];
    [self.audioEngine connect:self.equalizer to:self.changePitchEffect format:nil];
    [self.audioEngine connect:self.changePitchEffect to:self.audioEngine.outputNode format:nil];
    
    [self.audioPlayerNode scheduleFile:self.audioFile atTime:nil completionHandler:nil];
    [self.audioEngine startAndReturnError:nil];
    
    lengthSongSamples = self.audioFile.length;
    AVAudioFormat *songFormat = self.audioFile.processingFormat;
    sampleRateSong = songFormat.sampleRate;
    lengthSongSeconds = lengthSongSamples/sampleRateSong;
}

- (void)applyEQTreble{
    NSArray*gains = @[@(-9.5),@(-10),@(-10.5),@(-6),@(0),@(6.5),@(10.2),@(10.5),@(10.5),@(11)];
    [self applyEQ:gains type:AVAudioUnitEQFilterTypeParametric];
}
- (void)applyEQPowerful{
    NSArray*gains = @[@(11),@(10),@(6.5),@(-1.8),@(0.5),@(0),@(6.8),@(8.5),@(10),@(11)];
    [self applyEQ:gains type:AVAudioUnitEQFilterTypeParametric];
}
- (void)applyEQPop{
    NSArray*gains = @[@(0),@(3),@(6),@(5),@(3.3),@(-0.5),@(-0.7),@(-2.6),@(-4),@(-3.8)];
    [self applyEQ:gains type:AVAudioUnitEQFilterTypeParametric];
}
- (void)applyEQLive{
    NSArray*gains = @[@(-5.5),@(-1.8),@(4.5),@(5),@(7),@(4.5),@(2),@(-0.5),@(0),@(0)];
    [self applyEQ:gains type:AVAudioUnitEQFilterTypeParametric];
}
- (void)applyEQClub{
    NSArray*gains = @[@(0),@(0),@(5),@(8.3),@(8),@(7.2),@(5.6),@(-2),@(0),@(0)];
    [self applyEQ:gains type:AVAudioUnitEQFilterTypeParametric];
}
- (void)applyEQBass{
    NSArray*gains = @[@(7.5),@(5.5),@(5),@(4),@(0),@(-5.5),@(-6),@(-8.5),@(-8.5),@(-8.5)];
    [self applyEQ:gains type:AVAudioUnitEQFilterTypeParametric];
}

- (void)applyEQ:(NSArray*)gains type:(AVAudioUnitEQFilterType)type{
    NSArray<AVAudioUnitEQFilterParameters *> *bands = self.equalizer.bands;
    NSArray*freqs = @[@(31),@(62),@(125),@(250),@(500),@(1000),@(2000),@(4000),@(8000),@(16000)];
    
    for (NSUInteger i = 0; i < bands.count; i++) {
        AVAudioUnitEQFilterParameters *band = bands[i];
        band.frequency  = [freqs[i] floatValue];
        band.gain       = [gains[i] floatValue];
        band.bypass     = false;
        band.filterType = type;
    }
    
}

- (void)seekSecond:(CGFloat)time{
    NSLog(@"Seek to %f", time);
    startInSongSeconds = time;
    unsigned long int startSample = (long int)floor(startInSongSeconds*sampleRateSong);
    unsigned long int lengthSamples = lengthSongSamples-startSample;
    [self.audioPlayerNode stop];
    if (lengthSamples > 0) {
        [self.audioPlayerNode scheduleSegment:self.audioFile startingFrame:startSample frameCount:(AVAudioFrameCount)lengthSamples atTime:nil completionHandler:^{
        }];
        [self playAudio];
    }
}

- (CGFloat)getCurretnPosition{
    float elapsedSeconds = 0;
    if (self.audioPlayerNode.isPlaying) {
        AVAudioTime *nodeTime = self.audioPlayerNode.lastRenderTime;
        AVAudioTime *playerTime = [self.audioPlayerNode playerTimeForNodeTime:nodeTime];
        elapsedSeconds = startInSongSeconds + (double)playerTime.sampleTime/playerTime.sampleRate;
    }
    return elapsedSeconds;
}

- (IBAction)onTooglePlayTouched:(UIButton *)sender {
    if (self.audioPlayerNode.isPlaying) {
        [self pauseAudio];
        sender.selected = false;
    }else{
        self.changePitchEffect.pitch = 0;
        self.changePitchEffect.rate = 1;
        [self playAudio];
        sender.selected = true;
    }
}
- (IBAction)onEQChanged:(UISegmentedControl *)sender {
//    NSLog(@"EQ changed %ld", sender.selectedSegmentIndex);
    switch (sender.selectedSegmentIndex) {
        case 0:
            [self applyEQTreble];
            
            break;
            
        case 1:
            [self applyEQPowerful];
            
            break;
            
        case 2:
            [self applyEQPop];
            
            break;
            
        case 3:
            [self applyEQLive];
            
            break;
            
        case 4:
            [self applyEQClub];
            
            break;
            
        default:
            [self applyEQBass];
            break;
    }
}

- (IBAction)onLowPitch:(UIButton *)sender {
    self.changePitchEffect.pitch = -500;
    
}
- (IBAction)onHightPitch:(UIButton *)sender {
    self.changePitchEffect.pitch = 500;
}
- (IBAction)onSlow:(UIButton *)sender {
    self.changePitchEffect.rate = 0.5;
}
- (IBAction)onFast:(UIButton *)sender {
    self.changePitchEffect.rate = 2.0;
}
- (void)onSliderValChanged:(UISlider*)slider forEvent:(UIEvent*)event {
    UITouch *touchEvent = [[event allTouches] anyObject];
    switch (touchEvent.phase) {
        case UITouchPhaseBegan:
            self.isSeeking = true;
//            NSLog(@"UITouchPhaseBegan");
            break;
        case UITouchPhaseMoved:
//            NSLog(@"UITouchPhaseMoved");
            break;
        case UITouchPhaseEnded:
            NSLog(@"UITouchPhaseEnded");
            self.isSeeking = false;
            [self seekSecond:lengthSongSeconds*slider.value];
            break;
        default:
            break;
    }
}

- (IBAction)onSeekBarChanged:(UISlider *)sender {
    [self seekSecond:lengthSongSeconds*sender.value];
}
- (IBAction)onSpeedChanged:(UISlider *)sender {
    self.changePitchEffect.rate = sender.value;
}
- (IBAction)onPitchChanged:(UISlider *)sender {
    self.changePitchEffect.pitch = sender.value;
}
- (void)dealloc{
    NSLog(@"AudioPlayerView dealloc");
}
@end
