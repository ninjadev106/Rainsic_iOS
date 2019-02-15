//
//  AudioPlayerController.m
//  YoutubeSearch
//
//  Created by An Nguyen on 3/28/18.
//  Copyright © 2018 An Nguyen. All rights reserved.
//

#import "AudioPlayerController.h"
#import "MarqueeLabel.h"
#import "AIAudioMixerManager.h"
#import "VerticalSliderBar.h"
#import "VerticalEQBar.h"
#import "AppSession.h"
#import <SVProgressHUD.h>
#import <ISMessages.h>
#import "AudioSplitController.h"
#import "ReverbOptionsView.h"
#import "SettingPopup.h"
#import "ControllerServices.h"
#import "RootTabBarController.h"
#import "UIView+Toast.h"

@interface AudioPlayerController ()<AIAudioMixerManagerDelegate, AIAudioNodeDelegate, VerticalSliderBarDelegate, VerticalEQBarDelegate, ReverbOptionsViewDelegate>

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *eqSectionTop;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *bgImgTop;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *titleSectionTopCst;


@property (weak, nonatomic) IBOutlet UISlider *speedSliderNew;
@property (weak, nonatomic) IBOutlet UISlider *pitchSliderNew;

@property (weak, nonatomic) IBOutlet UIView *topCommandSection;
@property (weak, nonatomic) IBOutlet UIButton *rainButton;
@property (weak, nonatomic) IBOutlet UIButton *stromButton;
@property (weak, nonatomic) IBOutlet UIView *eqSection;
@property (nonatomic) VerticalEQBar *eqOptionView;

@property (weak, nonatomic) IBOutlet UIView *reverbSection;
@property (nonatomic) ReverbOptionsView *reverbOptionView;

@property (weak, nonatomic) IBOutlet UIView *speedSection;
@property (nonatomic) VerticalSliderBar* speedSlider;

@property (weak, nonatomic) IBOutlet UIView *pitchSection;
@property (nonatomic) VerticalSliderBar* pitchSlider;

@property (weak, nonatomic) IBOutlet UIView *titleSection;
@property (weak, nonatomic) IBOutlet UIButton *cutButton;
@property (weak, nonatomic) IBOutlet UIButton *closeButton;

@property (weak, nonatomic) IBOutlet MarqueeLabel *titleLabel;

@property (weak, nonatomic) IBOutlet UIView *timeSection;
@property (weak, nonatomic) IBOutlet UILabel *beforeTimeLabel;
@property (weak, nonatomic) IBOutlet UISlider *seekBar;
@property (weak, nonatomic) IBOutlet UILabel *afterTimeLabel;

@property (weak, nonatomic) IBOutlet UIView *commandSection;
@property (weak, nonatomic) IBOutlet UIButton *loopButton;
@property (weak, nonatomic) IBOutlet UIButton *prevTrackButton;
@property (weak, nonatomic) IBOutlet UIButton *rewindButton;
@property (weak, nonatomic) IBOutlet UIButton *playButton;
@property (weak, nonatomic) IBOutlet UIButton *forwardButton;
@property (weak, nonatomic) IBOutlet UIButton *nextTrackButton;
@property (weak, nonatomic) IBOutlet UIButton *settingButton;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *crossBtnTraling;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *commendSectionTop;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *commendLinehight;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *timesectionTop;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *titleLeadingSpace;

@property (nonatomic) AIAudioMixerManager *audioControl;
@property (nonatomic) AIAudioNode *rainControl;
@property (nonatomic) AIAudioNode *stormControl;
@property (nonatomic) AIAudioNode *mainControl;
@property (nonatomic) AVAudioUnitReverb* reverb;
@property (nonatomic) AIAudioNode *reverbControl;
@property (nonatomic) NSInteger reverbCode;

@property (nonatomic) NSMutableArray<AVAudioUnitTimePitch*>* pitchList;
@property (nonatomic) NSMutableArray<AVAudioUnitEQ*>* eqList;
@property (nonatomic) NSInteger lastEQIndex;

@property (nonatomic) DeviceMediaModel* data;
@property (nonatomic) NSMutableArray<DeviceMediaModel*>* playlist;
@property (nonatomic) NSMutableArray<DeviceMediaModel*>* originalList;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *titleViewTralling;
@property (weak, nonatomic) IBOutlet UIImageView *settingBtnIcon;
@property (weak, nonatomic) IBOutlet UIButton *btnPlayOverly;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *titleSectionHight;


@property (nonatomic) BOOL isSeeking;
@property (nonatomic) BOOL isFirst;

@end
@implementation AudioPlayerController


- (void)viewDidLoad {
    [super viewDidLoad];
    
    if([[UIDevice currentDevice]userInterfaceIdiom]==UIUserInterfaceIdiomPhone) {
        switch ((int)[[UIScreen mainScreen] nativeBounds].size.height) {
                case 1136:
                self.eqSectionTop.constant = 15;
                self.titleSectionTopCst.constant = 400;
                NSLog(@"iPhone 5 or 5S or 5C");
                break;
                
                case 1334:
                self.eqSectionTop.constant = 30;
              //  self.bgImgTop.constant = 410+30;
                self.titleSectionTopCst.constant = 409+30;
                NSLog(@"iPhone 6/6S/7/8");
                break;
                
                case 2208:
                self.eqSectionTop.constant = 50;
             //   self.bgImgTop.constant = 410+50;
                self.titleSectionTopCst.constant = 409+50;
                NSLog(@"iPhone 6+/6S+/7+/8+");
                break;
                
                case 2436:
                NSLog(@"iPhone X");
                self.eqSectionTop.constant = 30;
             //   self.bgImgTop.constant = 410+30;
                self.titleSectionTopCst.constant = 409+30;
                break;
            default:
                self.eqSectionTop.constant = 30;
              //  self.bgImgTop.constant = 410+30;
                self.titleSectionTopCst.constant = 409+30;
                NSLog(@"unknown");
        }
    }
    
    self.speedSection.hidden = YES;
    self.pitchSection.hidden = YES;
    self.isFirst = true;
    [self initMixerManager];
    [self initSeekBar];
    [self initCustomUI];
    self.lastEQIndex = self.eqOptionView.index;
    self.view.clipsToBounds = true;
    [self updatePlayerButton];
    self.eqOptionView.delegate = self;
    self.reverbOptionView.delegate = self;
    [_seekBar setThumbImage:[UIImage imageNamed:@"thumb20px.png"] forState:UIControlStateNormal];
    [_seekBar setThumbImage:[UIImage imageNamed:@"thumb20px.png"] forState:UIControlStateHighlighted];
    
    [_speedSliderNew setThumbImage:[UIImage imageNamed:@"seekbar_handle2"] forState:UIControlStateNormal];
    [_speedSliderNew setThumbImage:[UIImage imageNamed:@"seekbar_handle2"] forState:UIControlStateHighlighted];
    
    [_pitchSliderNew setThumbImage:[UIImage imageNamed:@"seekbar_handle2"] forState:UIControlStateNormal];
    [_pitchSliderNew setThumbImage:[UIImage imageNamed:@"seekbar_handle2"] forState:UIControlStateHighlighted];
    
    UISwipeGestureRecognizer *gestureRecognizer = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(swipeHandler:)];
    [gestureRecognizer setDirection:(UISwipeGestureRecognizerDirectionDown)];
    [self.view addGestureRecognizer:gestureRecognizer];

}

- (void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    [self.audioControl stop];
}

- (IBAction)onMiniModeTouched:(UIButton *)sender {
    [self switchToFloatMode:true];
}

-(void)swipeHandler:(UISwipeGestureRecognizer *)recognizer {
      [self switchToFloatMode:true];
}

- (IBAction)onRainTouched:(UIButton *)sender {
    if (self.rainControl.player.volume == 0) {
        self.rainControl.player.volume = 4.4;
        UIImage *btnImage = [UIImage imageNamed:@"2nd Rain_green"];
        [_rainButton setImage:btnImage forState:UIControlStateNormal];
    }else{
        self.rainControl.player.volume = 0;
        UIImage *btnImage = [UIImage imageNamed:@"1st Rain_red"];
        [_rainButton setImage:btnImage forState:UIControlStateNormal];
    }
    [self updateRainButtonState];
}


- (IBAction)onStromeTouched:(UIButton *)sender {
    if (self.stormControl.player.volume == 0) {
        self.stormControl.player.volume = 3.7;
        UIImage *btnImage = [UIImage imageNamed:@"2nd Storm_green"];
        [_stromButton setImage:btnImage forState:UIControlStateNormal];
    }else{
        self.stormControl.player.volume = 0;
        UIImage *btnImage = [UIImage imageNamed:@"1st Storm_red"];
        [_stromButton setImage:btnImage forState:UIControlStateNormal];
    }
    [self updateRainButtonState];
}


- (IBAction)onCutTouched:(UIButton *)sender {
    AudioSplitController* next = [[UIStoryboard storyboardWithName:@"Main" bundle:nil] instantiateViewControllerWithIdentifier:@"AudioSplitController"];
    next.data = self.data;
    [self.audioControl pause];
    UINavigationController *nav = [[UINavigationController alloc]initWithRootViewController:next];
    [[AppSession sharedInstance].rootTabBarController presentViewController:nav animated:true completion:^{
        
    }];
}
- (IBAction)onCloseTouched:(UIButton *)sender {
    [self hideMe:true];
}

- (IBAction)onFullModeTouched:(UIButton *)sender {
    [self switchToFloatMode:false];
}
- (IBAction)onSeekChanged:(UISlider *)sender {
    
}
- (IBAction)onLoopTouched:(UIButton *)sender {
    [AppSession sharedInstance].loopMode++;
    [self initPlayList];
    self.isFirst = false;
}

- (IBAction)onPrevTrackTouched:(UIButton *)sender {
    [self playNextTrack:false];
}

- (IBAction)onRewindTouched:(UIButton *)sender {
    [self rewind];
}

- (IBAction)onPlayTouched:(UIButton *)sender {
    if (self.audioControl.state == AIAudioStatePlaying) {
        [self.audioControl pause];
        self.playButton.selected = false;
//        self.toggle2Button.selected = false;
    }else{
        [self.audioControl play];
        self.playButton.selected = true;
//        self.toggle2Button.selected = true;
    }
}
//Play Icon Pause Icon
- (IBAction)onForwardTouched:(UIButton *)sender {
    [self forward];
}

- (IBAction)onNextTrackTouched:(UIButton *)sender {
    [self playNextTrack:true];
    
}

- (IBAction)onSettingTouched:(UIButton *)sender {
    // Old action sheet
  /*  UIAlertController* alert = [UIAlertController alertControllerWithTitle:@"Setting" message:nil preferredStyle:(UIAlertControllerStyleActionSheet)];
    
    UIAlertAction* cancel = [UIAlertAction actionWithTitle:@"Cancel" style:(UIAlertActionStyleCancel) handler:^(UIAlertAction * _Nonnull action) {
        
    }];
    [alert addAction:cancel];
    
    
    UIAlertAction* share = [UIAlertAction actionWithTitle:@"Share" style:(UIAlertActionStyleDefault) handler:^(UIAlertAction * _Nonnull action) {
        [ControllerServices shareAudio:self.data];
        
    }];
    [alert addAction:share];
    
    NSString* seekString = [NSString stringWithFormat:@"Set FastFoward & Rewind Time: %lds",(long)[AppSession sharedInstance].fastSeekValue];
    UIAlertAction* seek = [UIAlertAction actionWithTitle:seekString style:(UIAlertActionStyleDefault) handler:^(UIAlertAction * _Nonnull action) {
        
        
        SettingPopup* popup = [SettingPopup ai_createFromStoryboard:@"Main"];
        [popup show];
        
    }];
 //   [alert addAction:seek];
    
    UIAlertAction* playlist = [UIAlertAction actionWithTitle:@"Add To Playlist" style:(UIAlertActionStyleDefault) handler:^(UIAlertAction * _Nonnull action) {
        [ControllerServices addToPlaylist:self.data];
        
    }];
    [alert addAction:playlist];
    
    UIAlertAction* favorite = [UIAlertAction actionWithTitle:@"Add To Favorites" style:(UIAlertActionStyleDefault) handler:^(UIAlertAction * _Nonnull action) {
        [ControllerServices addToFavorite:self.data];
    }];
    [alert addAction:favorite];
    [UIViewController ai_presentViewController:alert animated:true completion:nil];*/
    // old action sheet
    
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:nil
                                                                             message:nil
                                                                      preferredStyle:UIAlertControllerStyleActionSheet];
    
    UIAlertAction *Share = [UIAlertAction
                                    actionWithTitle:@"Share"
                                    style:UIAlertActionStyleDefault
                                    handler:^(UIAlertAction *action){
                                        NSLog(@"Share");
                                          [ControllerServices shareAudio:self.data];
                                       
                                    }];
    [alertController addAction:Share];
    
    
    UIAlertAction *AddToPlaylist = [UIAlertAction
                                     actionWithTitle:@"Add To Playlist"
                                     style:UIAlertActionStyleDefault
                                     handler:^(UIAlertAction *action) {
                                         NSLog(@"Add To Playlist");
                                       [ControllerServices addToPlaylist:self.data];
                                     }];
    [alertController addAction:AddToPlaylist];
    
    
    UIAlertAction *AddToFavorites = [UIAlertAction
                                    actionWithTitle:@"Add To Favorites"
                                    style:UIAlertActionStyleDefault
                                    handler:^(UIAlertAction *action) {
                                        NSLog(@"Add To Favorites");
                                      [ControllerServices addToFavorite:self.data];
                                    }];
    [alertController addAction:AddToFavorites];
    
    
    UIAlertAction *Cancel = [UIAlertAction
                             actionWithTitle:@"Cancel"
                             style:UIAlertActionStyleDefault
                             handler:^(UIAlertAction *action) {
                                 NSLog(@"Cancel");
                                 
                             }];
    [alertController addAction:Cancel];
    
    
    alertController.view.tintColor = [UIColor whiteColor];
    UIView *subView = alertController.view.subviews.firstObject;
    
    UIView *alertContentView = subView.subviews.firstObject;
    for (UIView *subSubView in alertContentView.subviews) {
        subSubView.backgroundColor = [UIColor colorWithRed:83/255.0f green:133/255.0f blue:140/255.0f alpha:1.0f];
    }
    alertContentView.layer.cornerRadius = 5;
    [self presentViewController:alertController animated:YES completion:nil];
    
    
}


#pragma mark - Custom UI

- (void)updateRainButtonState{
 //   self.rainButton.alpha = self.rainControl.player.volume > 0 ? 1 : 0.2;
    if (self.rainControl.player.volume > 0){
      //Rain 2nd after clicking 1st default
        NSLog(@"true");
    }
    else{
         NSLog(@"false");
    }
    
}
- (void)updatePlayerButton{
 /*   switch ([AppSession sharedInstance].loopMode) {
        case 0:
            [self.loopButton setImage:[UIImage imageNamed:@"replay_btn"] forState:(UIControlStateNormal)];
            break;
        case 1:
            [self.loopButton setImage:[UIImage imageNamed:@"replay_one_btn"] forState:(UIControlStateNormal)];
            
            break;
            
        default:
            [self.loopButton setImage:[UIImage imageNamed:@"suffer_btn"] forState:(UIControlStateNormal)];
            break;
    }*/
    
    switch ([AppSession sharedInstance].loopMode) {
        case 0:
            [self.loopButton setImage:[UIImage imageNamed:@"Replay Loop"] forState:(UIControlStateNormal)];
            if (!self.isFirst) {
                [self.view makeToast:@"Repeat Loop: ON" duration:1.7 position:CSToastPositionCenter title:nil image:nil style:nil completion:nil];
            }
            break;
            
        case 1:
            [self.loopButton setImage:[UIImage imageNamed:@"PlayNext Loop"] forState:(UIControlStateNormal)];
            [self.view makeToast:@"Next Loop: ON" duration:1.7 position:CSToastPositionCenter title:nil image:nil style:nil completion:nil];
            break;
            
        default:
            [self.loopButton setImage:[UIImage imageNamed:@"Shuffle Loop"] forState:(UIControlStateNormal)];
            [self.view makeToast:@"Shuffle Loop: ON" duration:1.7 position:CSToastPositionCenter title:nil image:nil style:nil completion:nil];
            break;
    }
    
    NSInteger index = [self.playlist indexOfObject:_data];
    BOOL enabePrev = index > 0;
   // self.prevTrackButton.enabled = enabePrev;
   // self.prevTrackButton.alpha = self.prevTrackButton.enabled?1:0.3;
    NSInteger max = self.playlist.count-1;
    BOOL enableNext = index < max;
    //self.nextTrackButton.enabled = enableNext;
    //self.nextTrackButton.alpha = self.nextTrackButton.enabled?1:0.3;
    
    if ([AppSession sharedInstance].loopMode == 0) {
        self.prevTrackButton.enabled = YES;
        self.prevTrackButton.alpha = self.prevTrackButton.enabled?1:0.3;

        self.nextTrackButton.enabled = YES;
        self.nextTrackButton.alpha = self.nextTrackButton.enabled?1:0.3;
    }
}
- (void)initSeekBar{
    [self.seekBar setThumbImage:[UIImage imageNamed:@"thumb20px.png"] forState:(UIControlStateNormal)];
    [self.seekBar addTarget:self action:@selector(onSliderValChanged:forEvent:) forControlEvents:UIControlEventValueChanged];
}

- (void)initCustomUI{
    self.eqOptionView = [[VerticalEQBar alloc]init];
    [self addView:self.eqOptionView toView:self.eqSection];
    
    self.reverbOptionView = [[ReverbOptionsView alloc]init];
    [self addView:self.reverbOptionView toView:self.reverbSection];
    
    self.speedSlider = [[VerticalSliderBar alloc]init];
    [self addView:self.speedSlider toView:self.speedSection];
    [self.speedSlider layoutIfNeeded];
    self.speedSlider.min = 0.5;
    self.speedSlider.delegate = self;
    self.speedSlider.max = 1.5;
    self.speedSlider.value = 1;
    
    self.pitchSlider = [[VerticalSliderBar alloc]init];
    [self addView:self.pitchSlider toView:self.pitchSection];
    [self.pitchSlider layoutIfNeeded];
    self.pitchSlider.min = -500;
    self.pitchSlider.delegate = self;
    self.pitchSlider.max = 500;
    self.pitchSlider.value = 0;
}

- (void)addView:(UIView*)view toView:(UIView*)superView{
    [superView addSubview:view];
    view.frame = superView.bounds;
    view.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    
}

#pragma mark - Slider


- (void)onSliderValChanged:(UISlider*)slider forEvent:(UIEvent*)event {
    UITouch *touchEvent = [[event allTouches] anyObject];
    switch (touchEvent.phase) {
        case UITouchPhaseBegan:
            self.isSeeking = true;
            break;
        case UITouchPhaseMoved:
            break;
        case UITouchPhaseEnded:
            self.isSeeking = false;
            [self.audioControl seekPercent:slider.value];
            break;
        default:
            break;
    }
}

- (void)dlgVerticalSliderBarChanged:(VerticalSliderBar*)sender{
    if (sender == self.speedSlider) {
//        self.speedBar.value = sender.value;
        [self setXSpeed:sender.value];
        //        self.changePitchEffect.rate = sender.value;
        //        self.audioControl.xSpeed = sender.value;
    }
    if (sender == self.pitchSlider) {
//        self.pitchBar.value = sender.value;
        [self setPitch:sender.value];
        //        self.changePitchEffect.pitch = sender.value;
    }
}

- (void)dlgVerticalSliderBarRefresh:(VerticalSliderBar*)sender{
    
    if (sender == self.speedSlider) {
        self.speedSlider.value = 1.0f;
        [self setXSpeed:1.0f];
        //        self.changePitchEffect.rate = 1.0f;
        //        self.audioControl.xSpeed = 1.0f;
//        self.speedSlider.value = 1.0f;
    }
    if (sender == self.pitchSlider) {
        self.pitchSlider.value = 0.0f;
        [self setPitch:0.0f];
        //        self.changePitchEffect.pitch = 0.0f;
//        self.miniPitchSlider.value = 0.0f;
    }
}

#pragma mark - Audio

- (void)playAudio:(DeviceMediaModel*)audio inList:(NSArray<DeviceMediaModel*>*)playlist{
    self.originalList = [NSMutableArray arrayWithArray:playlist];
    [self initPlayList];
    self.data = audio;
}

- (void)initPlayList{
    self.playlist = [NSMutableArray arrayWithArray:self.originalList];
    if ([AppSession sharedInstance].loopMode == 2) {
        [self sufferData:self.data];
    }
    [self updatePlayerButton];
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
- (void)initMixerManager{
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
    
    
    NSURL *rainPath = [NSURL fileURLWithPath:[[NSBundle mainBundle] pathForResource:@"rain" ofType:@"mp3"]];
    self.rainControl = [self.audioControl addSubPlayerURL:rainPath withUnits:nil];
    self.rainControl.player.volume = 0;
    self.rainControl.delegate = self;
    
    NSURL *stormPath = [NSURL fileURLWithPath:[[NSBundle mainBundle] pathForResource:@"rs" ofType:@"mp3"]];
    self.stormControl = [self.audioControl addSubPlayerURL:stormPath withUnits:nil];
    self.stormControl.player.volume = 0;
    self.stormControl.delegate = self;
    
    [self updateRainButtonState];
    [self.audioControl setFileURL:self.data.localURL];
}


- (void)forward{
   
    //[self.audioControl forward:[AppSession sharedInstance].fastSeekValue];
    [self.audioControl forward:15];
    
}

- (void)rewind{
   // [self.audioControl rewind:[AppSession sharedInstance].fastSeekValue];
    [self.audioControl rewind:15];
}


- (void)setReverbCode:(NSInteger)reverbCode{
    _reverbCode = reverbCode;
    
    if (_reverbCode == 0) {
        self.reverb.wetDryMix = 0;
        self.reverbControl.player.volume = 0;
    }else{
        self.reverb.wetDryMix = 100;
        self.reverbControl.player.volume = 1.4;
        [self.reverb loadFactoryPreset:_reverbCode-1];
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
- (void)setData:(DeviceMediaModel *)data{
    _data = data;
    self.audioControl.trackName = _data.localName;
    self.audioControl.fileURL = _data.localURL;
    [self.audioControl play];
    NSMutableString * longName = [[NSMutableString alloc] initWithString:_data.localName];
    
    if (longName.length > 0) {
        if (longName.length <= 18) {
         self.titleLabel.textAlignment = NSTextAlignmentCenter;
        }
        else{
        while (longName.length < 70) {
            [longName appendFormat:@" %@",_data.localName];
        }
        }
    }
    
    self.titleLabel.text = longName;
    [self hideMe:false];
    [self updatePlayerButton];
}


- (void)playNextTrack:(BOOL)isNext{
    NSInteger index = [self.playlist indexOfObject:self.data];
    if ([AppSession sharedInstance].loopMode != 1) {
        NSInteger step = isNext?1:-1;
        index += step;
    }
    if (index < 0 || index >= self.playlist.count) {
        if ([AppSession sharedInstance].loopMode == 0) {
            if (isNext == NO) {
                index = self.playlist.count-1;
            } else {
                index = 0;
            }
        }else {
            return;
        }
        
    }
    
    DeviceMediaModel* obj = [self.playlist objectAtIndex:index];
    self.data = obj;
}

#pragma mark - Mixer Delegate

- (void)dlgAIAudioMixerManagerState:(AIAudioState)state{
    self.playButton.selected = state == AIAudioStatePlaying;
  //  self.btnPlayOverly.selected = state == AIAudioStatePlaying;
   // [self.btnPlayOverly setImage:[UIImage imageNamed:@"Pause_Overlay"] forState:(UIControlStateNormal)];
   // [self.btnPlayOverly setImage:[UIImage imageNamed:@"Play_Overlay"] forState:(UIControlStateNormal)];
    [self updateRainButtonState];
}

- (void)dlgAIAudioMixerManagerPlayingPercent:(CGFloat)percent{
    if (self.isSeeking) {
        return;
    }
    self.seekBar.value = percent;
    self.beforeTimeLabel.text = [DeviceMediaModel durationString:percent*self.audioControl.duration];
    self.afterTimeLabel.text = [DeviceMediaModel durationString:(1-percent)*self.audioControl.duration];
}

- (void)dlgAIAudioMixerManagerEndTrack{
    NSLog(@"dlgAudioPlayerControlEndTrack");
    [self playNextTrack:true];
}


#pragma mark - RCC

- (void)dlgAIAudioMixerManagerRCCNext{
    [self forward];
}

- (void)dlgAIAudioMixerManagerRCCPrevious{
    [self rewind];
}

#pragma mark - ReverbOptionView

- (void)dlgReverbOptionsViewChangeIndex:(NSInteger)index {
    [self setReverbCode:index];
}


#pragma mark - EQ

- (void)dlgVerticalEQBarChangeIndex:(NSInteger)index{
    [self changeEQIndex:index];
}

- (void)changeEQIndex:(NSInteger)index {
    //    NSLog(@"EQ changed %ld", sender.selectedSegmentIndex);
    if (index == self.lastEQIndex) {
        self.lastEQIndex = UISegmentedControlNoSegment;
    }else{
        self.lastEQIndex = index;
    }
    self.eqOptionView.index = self.lastEQIndex;
//    self.eqSegmented.selectedSegmentIndex = self.lastEQIndex;
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
}
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
//    NSArray*gains = @[@(7.5),@(5.5),@(5),@(4),@(0),@(-5.5),@(-6),@(-8.5),@(-8.5),@(-8.5)];
    //Bass(1.3)
    NSArray*gains = @[@(7.8),@(6.1),@(6.7),@(4),@(-0.2),@(-5.6),@(-6.1),@(-8.5),@(-8.5),@(-8.8)];
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

#pragma mark - Frame

- (void)minimizeIfNeeded{
    if (self.view.alpha>0) {
        [self switchToFloatMode:true];
    }
}

- (void)fullScreenIfNeeded{
    [self switchToFloatMode:false];
}

- (CGRect)frameOfFloatMode:(BOOL)floatMode{
    CGRect frame = [[UIScreen mainScreen] bounds];
    CGFloat bottomBarHeight = 48;
    CGFloat navHeight = 20;
    if (floatMode) {
       // CGFloat floatHeight = 40 + 40 + 40 + 30;
        CGFloat floatHeight = 40 + 40 + 40 + 30;
        frame.origin.y = frame.size.height - bottomBarHeight - 70;
        frame.size.height = 60;
        self.titleLeadingSpace.constant = -32;
        self.titleViewTralling.constant = 40;
        self.tabBarController.tabBar.hidden = NO;
        self.settingButton.hidden = YES;
        self.loopButton.hidden = YES;
        self.settingBtnIcon.hidden = YES;
        self.closeButton.hidden = NO;
        self.btnPlayOverly.hidden = NO;
        self.titleSectionHight.constant = 60;
        
        if (self.audioControl.state == AIAudioStatePlaying) {
            NSLog(@"audioControl.state true");
          [self.btnPlayOverly setImage:[UIImage imageNamed:@"Pause_Overlay"] forState:(UIControlStateNormal)];
        }else{
            NSLog(@"audioControl.state false");
         [self.btnPlayOverly setImage:[UIImage imageNamed:@"Play_Overlay"] forState:(UIControlStateNormal)];
        }
        
      //  self.view.backgroundColor = UIColor.lightGrayColor;
    }else{
        self.titleSectionHight.constant = 30;
        self.titleLeadingSpace.constant = 0;
        self.titleViewTralling.constant = 0;
        frame.origin.y += navHeight;
        // comment for tab bar hide
      //  frame.size.height -= (bottomBarHeight + navHeight);
        self.tabBarController.tabBar.hidden = YES;
        self.settingButton.hidden = NO;
        self.settingBtnIcon.hidden = NO;
        self.closeButton.hidden = YES;
        self.loopButton.hidden = NO;
        self.btnPlayOverly.hidden = YES;
    }
    return frame;
}

- (void)switchToFloatMode:(BOOL)floatMode{
    CGRect frame = [self frameOfFloatMode:floatMode];
    if([[UIDevice currentDevice]userInterfaceIdiom]==UIUserInterfaceIdiomPhone) {
        switch ((int)[[UIScreen mainScreen] nativeBounds].size.height) {
                case 1136:
                NSLog(@"iPhone 5 or 5S or 5C");
                self.titleSectionTopCst.constant = floatMode ? 0 : self.eqSection.frame.origin.y + self.eqSection.frame.size.height + 150;
                break;
                
                case 1334:
                NSLog(@"iPhone 6/6S/7/8");
                self.titleSectionTopCst.constant = floatMode ? 0 : self.eqSection.frame.origin.y + self.eqSection.frame.size.height + 132 + 50 + 30;
                self.commendSectionTop.constant = 10;
                self.timesectionTop.constant = 10;
                break;
                
                case 2208:
                NSLog(@"iPhone 6+/6S+/7+/8+");
                self.titleSectionTopCst.constant = floatMode ? 0 : self.eqSection.frame.origin.y + self.eqSection.frame.size.height + 132 + 50 + 50;
                self.commendSectionTop.constant = 20;
                self.timesectionTop.constant = 20;
                break;
                case 2436:
                NSLog(@"iPhone X");
                self.titleSectionTopCst.constant = floatMode ? 0 : self.eqSection.frame.origin.y + self.eqSection.frame.size.height + 132 + 50 + 30;
                self.commendSectionTop.constant = 10;
                self.timesectionTop.constant = 10;
                break;
                
            default:
                NSLog(@"unknown");
                self.titleSectionTopCst.constant = floatMode ? 0 : self.eqSection.frame.origin.y + self.eqSection.frame.size.height + 132 + 50 + 30;
                self.commendSectionTop.constant = 10;
                self.timesectionTop.constant = 10;
        }
    }
  /*  if([[UIDevice currentDevice]userInterfaceIdiom]==UIUserInterfaceIdiomPhone)
     {
     if ([[UIScreen mainScreen] bounds].size.height == 568.0f)
     {
     self.titleSectionTopCst.constant = floatMode ? 0 : self.eqSection.frame.origin.y + self.eqSection.frame.size.height + 132 + 50;
     }
     else
     {
     self.titleSectionTopCst.constant = floatMode ? 0 : self.eqSection.frame.origin.y + self.eqSection.frame.size.height + 132 + 50 + 30;
         self.commendSectionTop.constant = 10;
         self.timesectionTop.constant = 10;
     }
     }*/
  //  self.titleSectionTopCst.constant = floatMode ? 0 : self.eqSection.frame.origin.y + self.eqSection.frame.size.height + 132 + 50;
    [UIView animateWithDuration:0.2 animations:^{
        self.eqSection.alpha        = floatMode?0:1;
        self.cutButton.alpha        = floatMode?0:1;
      //  self.closeButton.alpha      = floatMode?1:0;
        //self.closeButton.alpha      = floatMode?0:1;
        self.reverbSection.alpha    = floatMode?0:1;
        self.pitchSection.alpha     = floatMode?0:1;
        self.speedSection.alpha     = floatMode?0:1;
        self.topCommandSection.alpha    = floatMode?0:1;
        self.timeSection.alpha =   floatMode?0:1;
        self.commandSection.alpha =   floatMode?0:1;
        self.view.frame = frame;
        [self.view layoutIfNeeded];
    }];
    [self.delegate dlgAudioPlayerControllerSwitchFloatMode:floatMode];
    if (!floatMode) {
        [self hideMiniSlider];
    }
    
}

- (void)hideMiniSlider{
//    [self.miniEQBar removeFromSuperview];
//    [self.miniPitchSlider removeFromSuperview];
//    [self.miniSpeedSlider removeFromSuperview];
}


- (void)hideMe:(BOOL)isHide{
    [UIView animateWithDuration:0.2 animations:^{
        self.view.alpha = isHide?0:1;
    }];
    if (isHide) {
        [self hideMiniSlider];
        [self.delegate dlgAudioPlayerControllerSwitchFloatMode:false];
        [self.audioControl stop];
    }else{
//        [self.delegate dlgAudioPlayerControllerSwitchFloatMode:self.mainPlayerSection.alpha == 0];
    }
}
- (IBAction)btnPlayOverly:(UIButton *)sender {
    if (self.audioControl.state == AIAudioStatePlaying) {
        [self.audioControl pause];
        [self.btnPlayOverly setImage:[UIImage imageNamed:@"Play_Overlay"] forState:(UIControlStateNormal)];
        // self.btnPlayOverly.selected = false;
    }else{
        [self.audioControl play];
        [self.btnPlayOverly setImage:[UIImage imageNamed:@"Pause_Overlay"] forState:(UIControlStateNormal)];
        // self.btnPlayOverly.selected = true;
    }
}

- (IBAction)speedslider:(UISlider *)sender {
     [self setXSpeed:sender.value];
}
- (IBAction)pitchSlider:(UISlider *)sender {
    NSLog(@"slidervalue %f",sender.value);
   // [self setPitch:sender.value];
    for (AVAudioUnitTimePitch* pitch in self.pitchList) {
        pitch.pitch = sender.value;
    }
}
- (IBAction)refershSpeed:(UIButton *)sender {
    self.speedSliderNew.value = 1.0f;
    [self setXSpeed:1.0f];
}
- (IBAction)refreshPitch:(UIButton *)sender {
    self.pitchSliderNew.value = 0.0f;
    [self setPitch:0.0f];
}

@end
