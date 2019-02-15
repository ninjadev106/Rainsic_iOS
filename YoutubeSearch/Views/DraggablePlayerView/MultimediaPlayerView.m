//
//  MultimediaPlayerView.m
//  Playground
//
//  Created by An Nguyen on 12/24/17.
//  Copyright © 2017 An Nguyen. All rights reserved.
//

#import "MultimediaPlayerView.h"
#import "AIUtility.h"
#import "AIGestureHandler.h"
#import <AVKit/AVKit.h>
#import "UIImageView+WebCache.h"
#import <ISMessages.h>
#import "MPMoviePlayerController+BackgroundPlayback.h"

#define MultimediaPlayerViewExtendedHeight 20
#define MultimediaPlayerViewMinHeight 150
#define MultimediaPlayerViewSufferModeKey @"MultimediaPlayerViewSufferModeKey"

@interface MultimediaPlayerView ()
@property (nonatomic) AIGestureHandler *gestureHandler;
@property (weak, nonatomic) IBOutlet UIView *videoSection;
@property (nonatomic) BOOL isMinium;
@property (nonatomic) CGFloat additionX;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *indicator;
//@property (nonatomic, strong) XCDYouTubeVideoPlayerViewController *videoPlayerViewController;
@property (nonatomic) AVPlayer *player;
@property (nonatomic) AVAudioPlayer *audioPlayer;
@property (nonatomic) AVAudioEngine *audioEngine;
@property (nonatomic) AVPlayerViewController *playerController;
@property (nonatomic) UIImageView *thumbView;
@property (nonatomic) id<IMediaItem> playingItem;
@property (weak, nonatomic) IBOutlet UIButton *playButton;
@property (nonatomic) BOOL isSufferable;
@property (weak, nonatomic) IBOutlet UIButton *sufferButton;
@property (weak, nonatomic) IBOutlet UIButton *prevButton;
@property (weak, nonatomic) IBOutlet UIButton *nextButton;

@property (nonatomic) NSMutableArray<id<IMediaItem>>* playDatasources;
@end

@implementation MultimediaPlayerView


static MultimediaPlayerView* __MultimediaPlayerView;
+ (MultimediaPlayerView*)sharedInstance{
    if(!__MultimediaPlayerView){
        __MultimediaPlayerView = [[MultimediaPlayerView alloc]init];
    };
    return __MultimediaPlayerView;
}

- (BOOL)isSufferable{
    BOOL bVal = [[NSUserDefaults standardUserDefaults] boolForKey:MultimediaPlayerViewSufferModeKey];
    self.sufferButton.alpha = bVal?1:0.3;
    return bVal;
}

- (void)setIsSufferable:(BOOL)isSufferable{
    BOOL bVal = isSufferable;
    self.sufferButton.alpha = bVal?1:0.3;
    [[NSUserDefaults standardUserDefaults] setBool:bVal forKey:MultimediaPlayerViewSufferModeKey];
    self.datasources = self.datasources;
}

- (void)setDatasources:(NSArray<id<IMediaItem>> *)datasources{
    _datasources = datasources;
    _playDatasources = [NSMutableArray arrayWithArray:_datasources];
    if (self.isSufferable) {
        NSUInteger count = [_playDatasources count];
        for (NSUInteger i = 0; i < count; ++i) {
            // Select a random element between i and end of array to swap with.
            NSUInteger nElements = count - i;
            NSUInteger n = (arc4random() % nElements) + i;
            [_playDatasources exchangeObjectAtIndex:i withObjectAtIndex:n];
        }
    }
}
- (IBAction)onSufferTouched:(UIButton *)sender {
    self.isSufferable = !self.isSufferable;
}

- (IBAction)onPrevTouched:(UIButton *)sender {
    [self playPrev];
}
- (IBAction)onPlayTouched:(UIButton *)sender {
    if (self.player.rate) {
        [self.player pause];
    }else{
        [self.player play];
    }
}
- (IBAction)onNextTouched:(UIButton *)sender {
    [self playNext];
}

- (void)playNext{
    NSInteger index = [self playingItemIndex];
    if (index < 0 || index + 1 == self.playDatasources.count) {
        return;
    }
    [self play:[self.playDatasources objectAtIndex:index+1]];
}

- (void)playPrev{
    NSInteger index = [self playingItemIndex];
    if (index < 1) {
        return;
    }
    [self play:[self.playDatasources objectAtIndex:index-1]];
}
- (NSInteger)playingItemIndex{
    
    for (NSInteger i = 0; i < self.playDatasources.count; i++) {
        if ([self.playDatasources objectAtIndex:i] == self.playingItem) {
            return i;
        }
    }
    return -1;
}
- (void)initCustom{
    [self initPlayer];
    [self initGesture];
    [self initNotification];
    [self.indicator startAnimating];
}

- (void)initPlayer{
    self.audioEngine = [[AVAudioEngine alloc] init];
    self.audioPlayer = [[AVAudioPlayer alloc] init];
    self.player = [[AVPlayer alloc]init];
    self.playerController = [[AVPlayerViewController alloc] init];
    self.playerController.player = self.player;
    self.playerController.view.frame = self.videoSection.bounds;
    self.playerController.view.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    [self.videoSection addSubview:self.playerController.view];
    self.thumbView = [[UIImageView alloc] init];
    self.thumbView.clipsToBounds = true;
//    [self.playerController.contentOverlayView addSubview:self.thumbView];
    self.thumbView.contentMode = UIViewContentModeScaleAspectFill;
}
- (void)initNotification{
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onFinishVideo) name:AVPlayerItemDidPlayToEndTimeNotification object:nil];
}

- (void)onFinishVideo{
    
    [self playNext];
}

- (void)playAsFirstIfSuffered:(id<IMediaItem>)item{
    [self.playDatasources removeObject:item];
    [self.playDatasources insertObject:item atIndex:0];
    [self play:item];
}
- (void)play:(id<IMediaItem>)item{
    self.thumbView.frame = self.videoSection.bounds;
    self.thumbView.hidden = false;
    self.indicator.hidden = false;
    [self.player pause];
    
    [item getLink:^(NSURL *url, NSURL *thumb, NSError *error) {
        if (error) {
            
            [ISMessages showCardAlertWithTitle:nil
                                       message:error.localizedDescription
                                      duration:1.f
                                   hideOnSwipe:YES
                                     hideOnTap:YES
                                     alertType:ISAlertTypeSuccess
                                 alertPosition:ISAlertPositionTop
                                       didHide:^(BOOL finished) {
                                           NSLog(@"Alert did hide.");
                                       }];
            return;
        }
        
        [self.thumbView sd_setImageWithURL:thumb placeholderImage:nil completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
            if (image) {
                self.thumbView.image = image;
            }else{
                self.thumbView.image = [UIImage imageNamed:@"youtube_thumb.jpg"];
            }
            [UIView animateWithDuration:0.2 animations:^{
                self.thumbView.alpha = 1;
            }];
        }];
        NSURL* mp3Url = [NSURL URLWithString:@"https://www.soundhelix.com/examples/mp3/SoundHelix-Song-1.mp3"];
        /*
        AVPlayerItem* avItem = [[AVPlayerItem alloc] initWithURL:url];
        AVMutableAudioMix
//        avItem.audioTimePitchAlgorithm =
//        AVPlayerItem* avItem = [[AVPlayerItem alloc] initWithURL:mp3Url];
        if(self.player.currentItem){
            [self.player.currentItem removeObserver:self forKeyPath:@"status"];
            [self.player removeObserver:self forKeyPath:@"rate"];
        }
        self.playingItem = item;
        
        NSInteger currentIndex = [self playingItemIndex];
        self.prevButton.enabled = currentIndex > 0;
        self.nextButton.enabled = currentIndex < self.playDatasources.count - 1;
        [self.player replaceCurrentItemWithPlayerItem:avItem];
        [self.player.currentItem addObserver:self forKeyPath:@"status" options:NSKeyValueObservingOptionNew context:nil];
        [self.player addObserver:self forKeyPath:@"rate" options:NSKeyValueObservingOptionNew context:nil];
        [self.player play];
         */
//        NSError *err;
//        AVAudioPlayer* avplayer = [[AVAudioPlayer alloc]initWithContentsOfURL:mp3Url error:&err];
//        [avplayer play];
//        AVAudioUnitTimePitch *changePitchEffect = [[AVAudioUnitTimePitch alloc] init];
//        changePitchEffect.pitch = -1000;
//        [self.audioEngine attachNode:changePitchEffect];
//        AVAudioPlayerNode
//        self.audioEngine connec
//        self.player.rate = 1.5;
    }];
    
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
    if ([keyPath isEqualToString:@"status"]) {
        NSLog(@"observeValueForKeyPath %ld",self.player.status);
        if (self.player.status == AVPlayerStatusReadyToPlay) {
            //DISABLE THE UIACTIVITY INDICATOR HERE
            self.indicator.hidden = true;
            self.thumbView.hidden = true;
        } else if (self.player.status == AVPlayerStatusFailed) {
            // something went wrong. player.error should contain some information
        }
    }
    if ([keyPath isEqualToString:@"rate"]) {
        if (self.player.rate) {
            self.playButton.selected = true;
        }else{
            self.playButton.selected = false;
        }
        
        
    }
}


- (void)initGesture{
    UIPanGestureRecognizer *panGes = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(panGestureHandler:)];
    [self addGestureRecognizer:panGes];
    self.gestureHandler = [[AIGestureHandler alloc]init];
    self.gestureHandler.gesture = panGes;
}

- (void)panGestureHandler:(UIPanGestureRecognizer*)sender{
    CGPoint delta = self.gestureHandler.delta;
    
    CGRect nFrame = [self frameAtY:self.frame.origin.y + delta.y];
    if (self.isMinium) {
//        if (deltaX>0) {
        self.additionX+=delta.x;
            nFrame.origin.x += self.additionX;
            self.frame = nFrame;
//        }
    }
    self.frame = nFrame;
    if (sender.state == UIGestureRecognizerStateEnded) {
        if (self.frame.origin.x < 0) {
            [self remove];
        }else{
            if(self.gestureHandler.lastBehaviourDelta.y > 0){
                [self showFull:false];
            }else{
                [self showFull:true];
            }
        }
        self.additionX = 0;
    }
}
- (CGRect)frameAtY:(CGFloat)y{
    self.thumbView.frame = self.videoSection.bounds;
    if (y<=0) {
        return self.superview.bounds;
    }
    CGFloat parentWidth = self.superview.bounds.size.width;
    CGFloat parentHeight = self.superview.bounds.size.height - MultimediaPlayerViewExtendedHeight;
    if (parentHeight- y < MultimediaPlayerViewMinHeight) {
        return [self frameAtY:parentHeight - MultimediaPlayerViewMinHeight];
    }
    
    CGRect frame = self.frame;
    frame.origin.y = y;
    
    CGFloat maxHeight = parentHeight - MultimediaPlayerViewMinHeight;
    CGFloat scalePercent = y/maxHeight;
    CGFloat freeWidth = parentWidth - MultimediaPlayerViewMinHeight*(16.0f/9.0f);
    frame.size.width = MultimediaPlayerViewMinHeight*(16.0f/9.0f) + freeWidth*(1.0f-scalePercent);
    frame.origin.x = parentWidth - frame.size.width;
    
    
    return frame;
}
- (void)showFull:(BOOL)isFull{
    [AIUtility aiDismissKeyboard];
    if (!self.superview) {
        [[UIApplication sharedApplication].keyWindow.rootViewController.view addSubview:self];
        self.frame = [UIApplication sharedApplication].keyWindow.rootViewController.view.bounds;
        self.alpha = 0;
    }
    if (self.alpha == 0) {
        CGRect nFrame = self.superview.bounds;
        nFrame.origin.y = nFrame.size.height;
        nFrame.origin.x = -nFrame.size.width;
        nFrame.size.height *= 0.5;
        nFrame.size.width *= 0.5;
        self.frame = nFrame;
    }
    [UIView animateWithDuration:0.3 animations:^{
        self.frame = [self frameAtY:isFull?0:100000];
        [self layoutIfNeeded];
        self.alpha = 1;
    } completion:^(BOOL finished) {
        self.thumbView.alpha = 1;
        self.thumbView.frame = self.videoSection.bounds;
        self.frame = self.frame;
    }];
    self.isMinium = ! isFull;
    
}
- (void)remove{
    [UIView animateWithDuration:0.3 animations:^{
        CGRect nFrame = self.frame;
        nFrame.origin.x = -nFrame.size.width;
        self.frame = nFrame;
        self.alpha = 0;
        
    } completion:^(BOOL finished) {
        [self.player pause];
    }];
}
- (BOOL)isFull{
    return self.frame.origin.y == 0;
}
@end
