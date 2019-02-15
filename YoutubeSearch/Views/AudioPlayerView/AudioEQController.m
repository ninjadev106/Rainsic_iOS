//
//  AudioTestViewController.m
//  YoutubeSearch
//
//  Created by An Nguyen on 1/11/18.
//  Copyright © 2018 An Nguyen. All rights reserved.
//

#import "AudioEQController.h"
#import "AudioSplitController.h"
//#import "AudioPlayerControl.h"
#import "AppSession.h"
#import <SVProgressHUD.h>
#import <ISMessages.h>
#import "MarqueeLabel.h"
#import "PlaylistViewController.h"
#import <OpenAL/OpenAL.h>
#import "ControllerServices.h"
#import "UIViewController+AIPresented.h"
#import "VerticalSliderBar.h"
#import "VerticalEQBar.h"
#import "ReverbPopupController.h"
#import "AIAudioMixerManager.h"

@interface AudioEQController ()<VerticalSliderBarDelegate, VerticalEQBarDelegate, ReverbPopupControllerDelegate, AIAudioMixerManagerDelegate, AIAudioNodeDelegate>
@property (weak, nonatomic) IBOutlet UISlider *speedBar;
@property (weak, nonatomic) IBOutlet UISlider *pitchBar;
@property (weak, nonatomic) IBOutlet UISegmentedControl *eqSegmented;

@property (weak, nonatomic) IBOutlet UIView *seekValueView;
//@property (nonatomic) AudioPlayerControl *audioControl2;
@property (nonatomic) AIAudioMixerManager *audioControl;
@property (nonatomic) AIAudioNode *rainControl;
@property (nonatomic) AIAudioNode *mainControl;
@property (nonatomic) AVAudioUnitReverb* reverb;
@property (nonatomic) AIAudioNode *reverbControl;
@property (nonatomic) NSInteger reverbCode;
@property (weak, nonatomic) IBOutlet UIButton *reverbButton;
@property (weak, nonatomic) IBOutlet UISegmentedControl *seekSegmented;

@property (nonatomic) NSMutableArray<AVAudioUnitTimePitch*>* pitchList;
@property (nonatomic) NSMutableArray<AVAudioUnitEQ*>* eqList;
@property (weak, nonatomic) IBOutlet UIView *mainPlayerSection;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *buttonsTrailingCst;
@property (weak, nonatomic) IBOutlet UIView *headerBackground;
@property (weak, nonatomic) IBOutlet MarqueeLabel *songTitleLabel;
@property (nonatomic) NSInteger lastEQIndex;
//@property (nonatomic) NSURL * rainPath;
@property (weak, nonatomic) IBOutlet UIView *smallButtonsSection;
@property (weak, nonatomic) IBOutlet UIView *floatModeHolder;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *tileLeadingCst;
@property (weak, nonatomic) IBOutlet UIButton *miniEQButton;
@property (weak, nonatomic) IBOutlet UIButton *miniPitchButton;
@property (weak, nonatomic) IBOutlet UIButton *miniSpeedButton;



@property (weak, nonatomic) IBOutlet UIButton *rainButton;
@property (weak, nonatomic) IBOutlet UILabel *beforeTimeLabel;
@property (weak, nonatomic) IBOutlet UISlider *seekBar;
@property (weak, nonatomic) IBOutlet UILabel *afterTimeLabel;

@property (weak, nonatomic) IBOutlet UIButton *loopModeButton;
@property (weak, nonatomic) IBOutlet UIButton *prevTrackButton;

@property (weak, nonatomic) IBOutlet UIButton *toggleButton;
@property (weak, nonatomic) IBOutlet UIButton *toggle2Button;

@property (weak, nonatomic) IBOutlet UIButton *nextTrackButton;

@property (nonatomic) DeviceMediaModel* data;
@property (nonatomic) NSMutableArray<DeviceMediaModel*>* playlist;
@property (nonatomic) NSMutableArray<DeviceMediaModel*>* originalList;

@property (nonatomic) VerticalEQBar* miniEQBar;
@property (nonatomic) VerticalSliderBar* miniPitchSlider;
@property (nonatomic) VerticalSliderBar* miniSpeedSlider;
@property (nonatomic) BOOL isSeeking;


@end

@implementation AudioEQController

- (void)viewDidLoad {
    [super viewDidLoad];
    //    [self initNotification];
    [self initNavigation];
    [self initAudio];
    [self initSeekBar];
    //    [self initRemotePlayback];
    //    [self updatePlayingLockInfor];
    self.lastEQIndex = self.eqSegmented.selectedSegmentIndex;
    self.view.clipsToBounds = true;
    [self updatePlayerButton];
    
}

- (void)updatePlayerButton{
    switch ([AppSession sharedInstance].loopMode) {
        case 0:
            [self.loopModeButton setImage:[UIImage imageNamed:@"replay_btn"] forState:(UIControlStateNormal)];
            break;
        case 1:
            [self.loopModeButton setImage:[UIImage imageNamed:@"replay_one_btn"] forState:(UIControlStateNormal)];
            
            break;
            
        default:
            [self.loopModeButton setImage:[UIImage imageNamed:@"suffer_btn"] forState:(UIControlStateNormal)];
            break;
    }
    
    NSInteger index = [self.playlist indexOfObject:_data];
    BOOL enabePrev = index > 0;
    self.prevTrackButton.enabled = enabePrev;
    self.prevTrackButton.alpha = self.prevTrackButton.enabled?1:0.3;
    NSInteger max = self.playlist.count-1;
    BOOL enableNext = index < max;
    self.nextTrackButton.enabled = enableNext;
    self.nextTrackButton.alpha = self.nextTrackButton.enabled?1:0.3;
}

- (void)sufferData:(DeviceMediaModel*)first{
    NSUInteger count = [self.playlist count];
    for (NSUInteger i = 0; i < count; ++i) {
        NSUInteger nElements = count - i;
        NSUInteger n = (arc4random() % nElements) + i;
        [self.playlist exchangeObjectAtIndex:i withObjectAtIndex:n];
    }
    [self.playlist removeObject:first];
    [self.playlist insertObject:first atIndex:0];
    
}
- (void)playAudio:(DeviceMediaModel*)audio inList:(NSArray<DeviceMediaModel*>*)playlist{
    self.originalList = [NSMutableArray arrayWithArray:playlist];
    [self initPlayList];
    self.data = audio;
}

- (void)setReverbCode:(NSInteger)reverbCode{
    _reverbCode = reverbCode;
    
    if (_reverbCode == 0) {
        self.reverb.wetDryMix = 0;
        self.reverbControl.player.volume = 0;
    }else{
        self.reverb.wetDryMix = 100;
        self.reverbControl.player.volume = 1.0;
        [self.reverb loadFactoryPreset:_reverbCode-1];
    }
}

- (void)setData:(DeviceMediaModel *)data{
    _data = data;
    self.audioControl.trackName = _data.localName;
    self.audioControl.fileURL = _data.localURL;
    [self.audioControl play];
    NSMutableString * longName = [[NSMutableString alloc] initWithString:_data.localName];
    if (longName.length > 0) {
        while (longName.length < 70) {
            [longName appendFormat:@" %@",_data.localName];
        }
    }
    self.songTitleLabel.text = longName;
    [self hideMe:false];
    [self updatePlayerButton];
}

- (void)initNotification{
    dispatch_async(dispatch_get_main_queue(), ^{
        // Register for these notifications as early as possible in order to be called before -[MPAVController _applicationWillResignActive:] which calls `_pausePlaybackIfNecessary`.
        NSNotificationCenter *defaultCenter = [NSNotificationCenter defaultCenter];
        [defaultCenter addObserver:self selector:@selector(backgroundPlayback_applicationWillResignActive:) name:UIApplicationWillResignActiveNotification object:nil];
        [defaultCenter addObserver:self selector:@selector(backgroundPlayback_applicationDidBecomeActive:) name:UIApplicationDidBecomeActiveNotification object:nil];
    });
}
- (void) backgroundPlayback_applicationWillResignActive:(NSNotification *)notification{
        if (![[[AVAudioSession sharedInstance] category] isEqualToString:AVAudioSessionCategoryPlayback])
            NSLog(@"ERROR: The audio session category must be `AVAudioSessionCategoryPlayback` when background playback is enabled.");
}

- (void) backgroundPlayback_applicationDidBecomeActive:(NSNotification *)notification{
}

- (void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    [self.audioControl stop];
}



- (void)minimizeIfNeeded{
    if (self.view.alpha>0) {
        [self switchToFloatMode:true];
    }
}
- (void)fullScreenIfNeeded{
    [self switchToFloatMode:false];
}

#pragma mark - Mini Button
- (IBAction)onHideTouched:(UIButton *)sender {
    [self hideMe:true];
}
- (IBAction)onMiniEQTouched:(UIButton *)sender {
    if (self.miniEQBar && self.miniEQBar.superview) {
        [self.miniEQBar removeFromSuperview];
        return;
    }
    CGRect frame = CGRectMake(sender.frame.origin.x+3, self.view.frame.origin.y - 160, 46, 160);
    if (!self.miniEQBar) {
        self.miniEQBar = [[VerticalEQBar alloc]initWithFrame:frame];
        self.miniEQBar.delegate = self;
        self.miniEQBar.index = self.lastEQIndex;
    }
    [self.view.superview addSubview:self.miniEQBar];
}
- (void)dlgVerticalEQBarChangeIndex:(NSInteger)index{
    [self changeEQIndex:index];
}
- (IBAction)onMiniPitchTouched:(UIButton *)sender {
    if (self.miniPitchSlider && self.miniPitchSlider.superview) {
        [self.miniPitchSlider removeFromSuperview];
        return;
    }
    CGRect frame = CGRectMake(sender.frame.origin.x+3, self.view.frame.origin.y - 160, 46, 160);
    if (!self.miniPitchSlider) {
        self.miniPitchSlider = [[VerticalSliderBar alloc]initWithFrame:frame];
        self.miniPitchSlider.min = self.pitchBar.minimumValue;
        self.miniPitchSlider.max = self.pitchBar.maximumValue;
        self.miniPitchSlider.delegate = self;
    }
    [self.view.superview addSubview:self.miniPitchSlider];
    [self.miniPitchSlider layoutIfNeeded];
    self.miniPitchSlider.value = self.pitchBar.value;
}
- (IBAction)onMiniSpeedTouched:(UIButton *)sender {
    if (self.miniSpeedSlider && self.miniSpeedSlider.superview) {
        [self.miniSpeedSlider removeFromSuperview];
        return;
    }
    CGRect frame = CGRectMake(sender.frame.origin.x+3, self.view.frame.origin.y - 160, 46, 160);
    if (!self.miniSpeedSlider) {
        self.miniSpeedSlider = [[VerticalSliderBar alloc]initWithFrame:frame];
        self.miniSpeedSlider.min = self.speedBar.minimumValue;
        self.miniSpeedSlider.max = self.speedBar.maximumValue;
        self.miniSpeedSlider.delegate = self;
    }
    [self.view.superview addSubview:self.miniSpeedSlider];
    [self.miniSpeedSlider layoutIfNeeded];
    self.miniSpeedSlider.value = self.speedBar.value;
}
- (void)dlgVerticalSliderBarChanged:(VerticalSliderBar*)sender{
    if (sender == self.miniSpeedSlider) {
        self.speedBar.value = sender.value;
        [self setXSpeed:sender.value];
//        self.changePitchEffect.rate = sender.value;
//        self.audioControl.xSpeed = sender.value;
    }
    if (sender == self.miniPitchSlider) {
        self.pitchBar.value = sender.value;
        [self setPitch:sender.value];
//        self.changePitchEffect.pitch = sender.value;
    }
}

- (void)setPitch:(CGFloat)value{
    for (AVAudioUnitTimePitch* pitch in self.pitchList) {
        pitch.pitch = value;
    }
}
- (void)setXSpeed:(CGFloat)value{
    self.audioControl.rccXSpeed = value;
    for (AVAudioUnitTimePitch* pitch in self.pitchList) {
        pitch.rate = value;
    }
}
- (void)dlgVerticalSliderBarRefresh:(VerticalSliderBar*)sender{
    
    if (sender == self.miniSpeedSlider) {
        self.speedBar.value = 1.0f;
        [self setXSpeed:1.0f];
//        self.changePitchEffect.rate = 1.0f;
//        self.audioControl.xSpeed = 1.0f;
        self.miniSpeedSlider.value = 1.0f;
    }
    if (sender == self.miniPitchSlider) {
        self.pitchBar.value = 0.0f;
        [self setPitch:0.0f];
//        self.changePitchEffect.pitch = 0.0f;
        self.miniPitchSlider.value = 0.0f;
    }
}
- (IBAction)onSwitchFloatModeTouched:(UIButton *)sender {
//    if (self.mainPlayerSection.alpha == 0) {
//        return;
//    }
    [self switchToFloatMode:true];
}

- (IBAction)onSwitchFullModeTouched:(UIButton *)sender {
//    if (self.mainPlayerSection.alpha == 1) {
//        return;
//    }
    [self switchToFloatMode:false];
}
- (CGRect)frameOfFloatMode:(BOOL)floatMode{
    
    CGRect frame = [[UIScreen mainScreen] bounds];
    if (floatMode) {
        frame.origin.y = frame.size.height - 88 - 46;
        frame.size.height = 40 + 46;
    }else{
        frame.origin.y += 20;
        frame.size.height -= 68;
    }
    return frame;
}

- (void)switchToFloatMode:(BOOL)floatMode{
    CGRect frame = [self frameOfFloatMode:floatMode];
    self.buttonsTrailingCst.constant = floatMode?0:-80;
    self.tileLeadingCst.constant = floatMode?self.smallButtonsSection.frame.size.width:self.floatModeHolder.frame.size.width;
    [UIView animateWithDuration:0.2 animations:^{
        self.mainPlayerSection.alpha    = floatMode?0:1;
        self.floatModeHolder.alpha      = floatMode?0:1;
        self.headerBackground.alpha     = floatMode?1:0;
        self.smallButtonsSection.alpha  = floatMode?1:0;
        self.view.frame = frame;
        [self.view layoutIfNeeded];
    }];
    [self.delegate dlgAudioEQControllerSwitchFloatMode:floatMode];
    if (!floatMode) {
        [self hideMiniSlider];
    }
    
}
- (void)hideMiniSlider{
    [self.miniEQBar removeFromSuperview];
    [self.miniPitchSlider removeFromSuperview];
    [self.miniSpeedSlider removeFromSuperview];
}

#pragma mark - Audio Control

- (void)initSeekBar{
    [self.seekBar setThumbImage:[UIImage imageNamed:@""] forState:(UIControlStateNormal)];
    [self.seekBar addTarget:self action:@selector(onSliderValChanged:forEvent:) forControlEvents:UIControlEventValueChanged];
}

- (void)initAudio{
    self.pitchList = [NSMutableArray new];
    self.eqList = [NSMutableArray new];
    self.audioControl = [[AIAudioMixerManager alloc] init];
    self.audioControl.delegate = self;

    AVAudioUnitTimePitch *pitchEffect = [[AVAudioUnitTimePitch alloc]init];
    AVAudioUnitEQ* equalizer = [[AVAudioUnitEQ alloc] initWithNumberOfBands:10];
    [self.pitchList addObject:pitchEffect];
    [self.eqList addObject:equalizer];
    self.mainControl = [self.audioControl addPlayerWithUnits:@[pitchEffect, equalizer]];
    
    pitchEffect = [[AVAudioUnitTimePitch alloc]init];
    equalizer = [[AVAudioUnitEQ alloc] initWithNumberOfBands:10];
    [self.pitchList addObject:pitchEffect];
    [self.eqList addObject:equalizer];
    self.reverb = [[AVAudioUnitReverb alloc] init];
    [self.reverb loadFactoryPreset:(AVAudioUnitReverbPresetSmallRoom)];
    self.reverb.wetDryMix = 0;
    self.reverbControl = [self.audioControl addPlayerWithUnits:@[pitchEffect, equalizer, self.reverb]];
    
    [self setPitch:0];
    [self normalEQ];
    self.reverbCode = 0;
    
    
    NSURL *rainPath = [NSURL fileURLWithPath:[[NSBundle mainBundle] pathForResource:@"Rain" ofType:@"mp3"]];
    self.rainControl = [self.audioControl addSubPlayerURL:rainPath withUnits:nil];
    self.rainControl.player.volume = 0;
    self.rainControl.delegate = self;
    [self updateRainButtonState];
    [self.audioControl setFileURL:self.data.localURL];
    
}
- (void)dlgAIAudioMixerManagerState:(AIAudioState)state{
    self.toggleButton.selected = state == AIAudioStatePlaying;
    [self updateRainButtonState];
}
- (void)dlgAIAudioMixerManagerPlayingPercent:(CGFloat)percent{
    self.seekBar.value = percent;
    self.beforeTimeLabel.text = [DeviceMediaModel durationString:percent*self.audioControl.duration];
    self.afterTimeLabel.text = [DeviceMediaModel durationString:(1-percent)*self.audioControl.duration];
//    [MPNowPlayingInfoCenter defaultCenter].nowPlayingInfo =
//    @{MPMediaItemPropertyTitle:@"MPMediaItemPropertyTitle",
//      MPMediaItemPropertyAlbumTitle:@"MPMediaItemPropertyAlbumTitle",
//      MPMediaItemPropertyArtist:@"MPMediaItemPropertyArtist",
//      MPMediaItemPropertyPlaybackDuration:@(self.audioControl.duration),
//      MPNowPlayingInfoPropertyElapsedPlaybackTime:@(percent*self.audioControl.duration)
//      };
}
- (void)dlgAIAudioMixerManagerEndTrack{
    NSLog(@"dlgAudioPlayerControlEndTrack");
    [self playNextTrack:true];
}


- (void)skipForward{
    [self.audioControl forward:[AppSession sharedInstance].fastSeekValue];
}

- (void)skipBackward{
    [self.audioControl rewind:[AppSession sharedInstance].fastSeekValue];
}

- (void)dlgAIAudioMixerManagerRCCNext{
    [self skipForward];
}

- (void)dlgAIAudioMixerManagerRCCPrevious{
    [self skipBackward];
}

- (IBAction)onPlayRainTouched:(UIButton *)sender {
    if (self.rainControl.player.volume == 0) {
        self.rainControl.player.volume = 0.8;
    }else{
        self.rainControl.player.volume = 0;
    }
    [self updateRainButtonState];
}

- (void)updateRainButtonState{
    
    self.rainButton.alpha = self.rainControl.player.volume > 0 ? 1 : 0.2;
}

//- (void)dlgAudioPlayerControlBackPlaying:(BOOL)playing{
//    self.rainButton.alpha = playing?1:0.2;
//}

- (IBAction)onCutTouched:(UIButton *)sender {
    AudioSplitController* next = [[UIStoryboard storyboardWithName:@"Main" bundle:nil] instantiateViewControllerWithIdentifier:@"AudioSplitController"];
    next.data = self.data;
    [self.audioControl pause];
    UINavigationController *nav = [[UINavigationController alloc]initWithRootViewController:next];
    [[AppSession sharedInstance].rootTabBarController presentViewController:nav animated:true completion:^{
        
    }];
}

- (IBAction)onPrevTrackTouched:(UIButton *)sender {
    [self playNextTrack:false];
}

- (IBAction)onNextTrackTouched:(UIButton *)sender {
    [self playNextTrack:true];
}
- (IBAction)onLoopModeTouched:(UIButton *)sender {
    [AppSession sharedInstance].loopMode++;
    [self initPlayList];
    
}

- (void)initPlayList{
    self.playlist = [NSMutableArray arrayWithArray:self.originalList];
    if ([AppSession sharedInstance].loopMode == 2) {
        [self sufferData:self.data];
    }
    [self updatePlayerButton];
}

- (void)playNextTrack:(BOOL)isNext{
    NSInteger index = [self.playlist indexOfObject:self.data];
    if ([AppSession sharedInstance].loopMode != 1) {
        NSInteger step = isNext?1:-1;
        index += step;
    }
    if (index < 0 || index >= self.playlist.count) {
        return;
    }
    
    DeviceMediaModel* obj = [self.playlist objectAtIndex:index];
    self.data = obj;
}

- (IBAction)onFastRewindTouched:(UIButton *)sender {
    [self skipBackward];
}

- (IBAction)onFastNextTouched:(UIButton *)sender {
    [self skipForward];
}


- (void)hideMe:(BOOL)isHide{
    [UIView animateWithDuration:0.2 animations:^{
        self.view.alpha = isHide?0:1;
    }];
    if (isHide) {
        [self hideMiniSlider];
        [self.delegate dlgAudioEQControllerSwitchFloatMode:false];
        [self.audioControl stop];
    }else{
        [self.delegate dlgAudioEQControllerSwitchFloatMode:self.mainPlayerSection.alpha == 0];
    }
}

- (IBAction)onTooglePlayTouched:(UIButton *)sender {
    if (self.audioControl.state == AIAudioStatePlaying) {
        [self.audioControl pause];
        self.toggleButton.selected = false;
        self.toggle2Button.selected = false;
    }else{
        [self.audioControl play];
        self.toggleButton.selected = true;
        self.toggle2Button.selected = true;
    }
}
- (IBAction)onEQChangedTouched:(UIButton *)sender {
    [self changeEQIndex:sender.tag];
}
    
- (void)changeEQIndex:(NSInteger)index {
        //    NSLog(@"EQ changed %ld", sender.selectedSegmentIndex);
        if (index == self.lastEQIndex) {
            self.lastEQIndex = UISegmentedControlNoSegment;
        }else{
            self.lastEQIndex = index;
        }
        self.eqSegmented.selectedSegmentIndex = self.lastEQIndex;
        switch (self.lastEQIndex) {
            
            case 0:
            [self normalEQ];
            
            break;
            
            
            case 1:
            [self applyEQTreble];
            
            break;
            
            case 2:
            [self applyEQPowerful];
            
            break;
            
            case 3:
            [self applyEQPop];
            
            break;
            
            case 4:
            [self applyEQLive];
            
            break;
            
            case 5:
            [self applyEQClub];
            
            break;
            case 6:
            [self applyEQBass];
            
            break;
            
            default:
            [self normalEQ];
            break;
        }
    }

    
    
/*- (void)changeEQIndex:(NSInteger)index {
    //    NSLog(@"EQ changed %ld", sender.selectedSegmentIndex);
    if (index == self.lastEQIndex) {
        self.lastEQIndex = UISegmentedControlNoSegment;
    }else{
        self.lastEQIndex = index;
    }
    self.eqSegmented.selectedSegmentIndex = self.lastEQIndex;
    switch (self.lastEQIndex) {
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
        case 5:
            [self applyEQBass];
            
            break;
            
        default:
            [self normalEQ];
            break;
    }
}*/
- (void)normalEQ{
    NSArray*gains = @[@(0),@(0),@(0),@(0),@(0),@(0),@(0),@(0),@(0),@(0)];
    [self applyEQ:gains type:AVAudioUnitEQFilterTypeParametric];
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
    
    for (AVAudioUnitEQ* eq in self.eqList) {
        
        NSArray<AVAudioUnitEQFilterParameters *> *bands = eq.bands;
        NSArray*freqs = @[@(31),@(62),@(125),@(250),@(500),@(1000),@(2000),@(4000),@(8000),@(16000)];
        
        for (NSUInteger i = 0; i < bands.count; i++) {
            AVAudioUnitEQFilterParameters *band = bands[i];
            band.frequency  = [freqs[i] floatValue];
            band.gain       = [gains[i] floatValue];
            band.bypass     = false;
            band.filterType = type;
        }
    }
    
}
- (IBAction)onReverbTouched:(UIButton *)sender {
    ReverbPopupController* popup = [ReverbPopupController ai_createFromStoryboard:@"Main"];
    popup.delegate = self;
    popup.reverbCode = self.reverbCode;
    [popup show];
}

- (void)dlgReverbPopupControllerChanged:(ReverbPopupController*)sender{
    self.reverbCode = sender.reverbCode;
    [self.reverbButton setTitle:[NSString stringWithFormat:@"Reverb: %@",sender.reverbName] forState:(UIControlStateNormal)];
}
#pragma mark - Slider
- (IBAction)onSeekBarChanged:(UISlider *)sender {
    [self.audioControl seekPercent:sender.value];
}
- (IBAction)onSpeedChanged:(UISlider *)sender {
    [self setXSpeed:sender.value];
//    self.changePitchEffect.rate = sender.value;
//    self.audioControl.xSpeed = sender.value;
    self.miniSpeedSlider.value = sender.value;
}
- (IBAction)onPitchChanged:(UISlider *)sender {
    [self setPitch:sender.value];
//    self.changePitchEffect.pitch = sender.value;
    self.miniPitchSlider.value = sender.value;
}
- (IBAction)onSettingTouched:(UIButton *)sender {
    UIAlertController* alert = [UIAlertController alertControllerWithTitle:@"Setting" message:nil preferredStyle:(UIAlertControllerStyleActionSheet)];
    
    UIAlertAction* cancel = [UIAlertAction actionWithTitle:@"Cancel" style:(UIAlertActionStyleCancel) handler:^(UIAlertAction * _Nonnull action) {
        
    }];
    [alert addAction:cancel];
    
    
    UIAlertAction* share = [UIAlertAction actionWithTitle:@"Share" style:(UIAlertActionStyleDefault) handler:^(UIAlertAction * _Nonnull action) {
        [ControllerServices shareAudio:self.data];
        
    }];
    [alert addAction:share];
    
    NSString* seekString = [NSString stringWithFormat:@"Set FastFoward & Rewind Time: %lds",(long)[AppSession sharedInstance].fastSeekValue];
    UIAlertAction* seek = [UIAlertAction actionWithTitle:seekString style:(UIAlertActionStyleDefault) handler:^(UIAlertAction * _Nonnull action) {
        
        [self showSeekValueView:true];
        
    }];
    [alert addAction:seek];
    
    UIAlertAction* playlist = [UIAlertAction actionWithTitle:@"Add To Playlist" style:(UIAlertActionStyleDefault) handler:^(UIAlertAction * _Nonnull action) {
        [ControllerServices addToPlaylist:self.data];
        
    }];
    [alert addAction:playlist];
    
    UIAlertAction* favorite = [UIAlertAction actionWithTitle:@"Add To Favorites" style:(UIAlertActionStyleDefault) handler:^(UIAlertAction * _Nonnull action) {
        [ControllerServices addToFavorite:self.data];
    }];
    [alert addAction:favorite];
    [UIViewController ai_presentViewController:alert animated:true completion:nil];
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
            [self.audioControl seekPercent:slider.value];
            break;
        default:
            break;
    }
}

- (IBAction)onDismissSeekValueTouched:(UIButton *)sender {
    [self showSeekValueView:false];
}

- (void)showSeekValueView:(BOOL)isShow{
    self.seekSegmented.selectedSegmentIndex = ([AppSession sharedInstance].fastSeekValue/5-1);
    [UIView animateWithDuration:0.2 animations:^{
        self.seekValueView.alpha = isShow?1:0;
    }];
}

- (IBAction)onSavedSeekValueTouched:(UIButton *)sender {
    [AppSession sharedInstance].fastSeekValue = (self.seekSegmented.selectedSegmentIndex + 1)*5;
    [[AppSession sharedInstance] save];
    [self showSeekValueView:false];
}

- (IBAction)onSeekValueChanged:(UISegmentedControl *)sender {
    
}

- (void)initNavigation{
    
    UIBarButtonItem *button = [[UIBarButtonItem alloc]
                               initWithTitle:@"Close"
                               style:UIBarButtonItemStylePlain
                               target:self
                               action:@selector(ai_navigationAddDissmissTouched:)];
    
    self.navigationItem.leftBarButtonItem = button;
}
- (void)ai_navigationAddDissmissTouched:(UIBarButtonItem *)barItem {
    if (self.navigationController.childViewControllers.count>1) {
        [self.navigationController popViewControllerAnimated:YES];
        
    }else{
        [self dismissViewControllerAnimated:true completion:nil];
    }
}
@end
