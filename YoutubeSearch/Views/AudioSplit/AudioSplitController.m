//
//  AudioSplitController.m
//  YoutubeSearch
//
//  Created by An Nguyen on 1/29/18.
//  Copyright © 2018 An Nguyen. All rights reserved.
//

#import "AudioSplitController.h"
#import "AISliderBarValueVimod.h"
#import <AVFoundation/AVFoundation.h>
#import <AVKit/AVKit.h>
#import "AudioPlayerControl.h"
#import <ISMessages.h>
#import "PlaylistViewController.h"
#import "UIActionSheet+BlocksKit.h"
#import "AppSession.h"
#import <SVProgressHUD.h>
#import "NSObject+Block.h"


@interface AudioSplitController ()<AISliderDotVimodDelegate, AudioPlayerControlDelegate>
@property AISliderBarValueVimod *barValue;
@property AISliderDotVimod* firstDot;
@property AISliderDotVimod* secondDot;
@property AISliderDotVimod* playingDot;
@property (weak, nonatomic) IBOutlet UIButton *toggleButton;
@property (weak, nonatomic) IBOutlet UIView *sliderbarView;
@property (weak, nonatomic) IBOutlet UIView *valueBarView;

@property (weak, nonatomic) IBOutlet UIView *firstDotView;
@property (weak, nonatomic) IBOutlet UILabel *firstLabel;

@property (weak, nonatomic) IBOutlet UIView *secondDotView;
@property (weak, nonatomic) IBOutlet UILabel *secondLabel;

@property (weak, nonatomic) IBOutlet UILabel *durationLabel;

@property (weak, nonatomic) IBOutlet UIView *playingDotView;

@property (weak, nonatomic) IBOutlet UITextField *nameLabel;
@property (nonatomic) AudioPlayerControl *audioControl;
@property (weak, nonatomic) IBOutlet UIView *playerSectionView;
@property (weak, nonatomic) IBOutlet UILabel *lblsongtitle;
@end

@implementation AudioSplitController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self initNavigation];
    [self initAudio];
    self.nameLabel.text = [NSString stringWithFormat:@"%@ - split",self.data.localName];
    self.lblsongtitle.text = self.data.localName;
    [self initSliderDot];
    
    UISwipeGestureRecognizer *gestureRecognizer = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(swipeHandler:)];
    [gestureRecognizer setDirection:(UISwipeGestureRecognizerDirectionDown)];
    [self.view addGestureRecognizer:gestureRecognizer];
  

   
}

- (void)initNavigation{
    self.title = @"Cut Audio";
    [self.navigationController.navigationBar setTitleTextAttributes:
     @{NSForegroundColorAttributeName:[UIColor whiteColor]}];
    [[UINavigationBar appearance] setBarTintColor:[[UIColor alloc]initWithRed:10.0/255.0 green:81.0/255.0 blue:92.0/255.0 alpha:1.0]];
    UIBarButtonItem *button = [[UIBarButtonItem alloc]
                               initWithTitle:@"Close"
                               style:UIBarButtonItemStylePlain
                               target:self
                               action:@selector(ai_navigationAddDissmissTouched:)];
    [button setTintColor: [UIColor whiteColor]];
    self.navigationItem.leftBarButtonItem = button;
}

- (void)ai_navigationAddDissmissTouched:(UIBarButtonItem *)barItem {
    if (self.navigationController.childViewControllers.count>1) {
        [self.navigationController popViewControllerAnimated:YES];
        
    }else{
        [self dismissViewControllerAnimated:true completion:nil];
    }
}

-(void)swipeHandler:(UISwipeGestureRecognizer *)recognizer {
    if (self.navigationController.childViewControllers.count>1) {
        [self.navigationController popViewControllerAnimated:YES];
        
    }else{
        [self dismissViewControllerAnimated:true completion:nil];
    }
}


//- (void)viewDidAppear:(BOOL)animated{
//    [super viewDidAppear:animated];
//    [UIView animateWithDuration:0.2 animations:^{
//        [self initSliderDot];
//    }];
//}
- (void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    [self.audioControl stop];
}

- (IBAction)onToggleTouched:(UIButton *)sender {
    if (self.audioControl.isPlaying) {
        [self.audioControl pause];
        sender.selected = false;
    }else{
        [self.audioControl play];
        sender.selected = true;
    }
}

- (IBAction)onSaveTouched:(UIButton *)sender {
    [self.nameLabel endEditing:true];
    // OLD action sheet
  /*  UIActionSheet *actionSheet = [UIActionSheet bk_actionSheetWithTitle:@"Menu Action"];
   
    
    [actionSheet bk_addButtonWithTitle:@"Add To Playlist" handler:^{
        
        [self delayTrimAudioAndSaveToFavorite:false];
//        [AppSession sharedInstance].lastSelectVideo = data;
//        [AppSession sharedInstance].rootTabBarController.selectedIndex = 2;
    }];
    
    [actionSheet bk_addButtonWithTitle:@"Add To Favorites" handler:^{
//        [[AppSession sharedInstance] addFavorite:data];
        [self delayTrimAudioAndSaveToFavorite:true];
    }];
    
    [actionSheet bk_setCancelButtonWithTitle:@"Cancel" handler:^{
        
    }];
    

    [actionSheet showInView:self.view];*/
    // OLD action sheet
    
//    [self trimAudio];
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:nil
                                                                             message:nil
                                                                      preferredStyle:UIAlertControllerStyleActionSheet];
    
    UIAlertAction *SaveToPlaylist = [UIAlertAction
                                    actionWithTitle:@"Save To Playlist"
                                    style:UIAlertActionStyleDefault
                                    handler:^(UIAlertAction *action){
                                        NSLog(@"Save To Playlist");
               [self delayTrimAudioAndSaveToFavorite:false];
                                    }];
    [alertController addAction:SaveToPlaylist];
    
    
    UIAlertAction *SaveToFavorites = [UIAlertAction
                                     actionWithTitle:@"Save To Favorites"
                                     style:UIAlertActionStyleDefault
                                     handler:^(UIAlertAction *action) {
                                         NSLog(@"Save To Favorites");
        [self delayTrimAudioAndSaveToFavorite:true];
                                     }];
    [alertController addAction:SaveToFavorites];
    
    UIAlertAction *setImageASNotif = [UIAlertAction
                                      actionWithTitle:@"Cancel"
                                      style:UIAlertActionStyleDefault
                                      handler:^(UIAlertAction *action) {
                                          NSLog(@"Third Button");
                                          
                                      }];
    [alertController addAction:setImageASNotif];
    alertController.view.tintColor = [UIColor whiteColor];
    UIView *subView = alertController.view.subviews.firstObject;
   
    UIView *alertContentView = subView.subviews.firstObject;
    for (UIView *subSubView in alertContentView.subviews) {
        subSubView.backgroundColor = [UIColor colorWithRed:83/255.0f green:133/255.0f blue:140/255.0f alpha:1.0f];
    }
    alertContentView.layer.cornerRadius = 5;
    [self presentViewController:alertController animated:YES completion:nil];
   
}

- (void)delayTrimAudioAndSaveToFavorite:(BOOL)saveFavorite{
    [self performBlock:^{
        [self trimAudioAndSaveToFavorite:saveFavorite];
    } afterDelay:0.5];
}

- (BOOL)trimAudioAndSaveToFavorite:(BOOL)saveFavorite{
    [SVProgressHUD show];
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    NSString *filePath = [NSString stringWithFormat:@"%@/%@", documentsDirectory, @"audio.m4a"];
    NSLog(@"filePath %@", filePath);
    
    float vocalStartMarker  = self.barValue.minValue*self.audioControl.duration;
    float vocalEndMarker    = self.barValue.maxValue*self.audioControl.duration;
    
    NSURL *audioFileInput = self.audioControl.fileURL;
    NSURL *audioFileOutput = [NSURL fileURLWithPath:filePath];
    
    if (!audioFileInput || !audioFileOutput)
    {
        return NO;
    }
    
    [[NSFileManager defaultManager] removeItemAtURL:audioFileOutput error:NULL];
    AVAsset *asset = [AVAsset assetWithURL:audioFileInput];
    
    AVAssetExportSession *exportSession = [AVAssetExportSession exportSessionWithAsset:asset
                                                                            presetName:AVAssetExportPresetAppleM4A];
    
    if (exportSession == nil)
    {
        return NO;
    }
    
    CMTime startTime = CMTimeMake((int)(floor(vocalStartMarker * 100)), 100);
    CMTime stopTime = CMTimeMake((int)(ceil(vocalEndMarker * 100)), 100);
    CMTimeRange exportTimeRange = CMTimeRangeFromTimeToTime(startTime, stopTime);
    
    exportSession.outputURL = audioFileOutput;
    exportSession.outputFileType = AVFileTypeAppleM4A;
    exportSession.timeRange = exportTimeRange;
    
    [exportSession exportAsynchronouslyWithCompletionHandler:^
     {
         [SVProgressHUD dismiss];
         if (AVAssetExportSessionStatusCompleted == exportSession.status)
         {
             // It worked!
             dispatch_async(dispatch_get_main_queue(), ^{
                
             DeviceMediaModel* saved = [[DeviceMediaModel alloc] init];
             saved.iid = [DeviceMediaModel randomID];
             saved.localName = self.nameLabel.text;
             saved.duration = vocalEndMarker - vocalStartMarker;
             saved.localURL = audioFileOutput;
             saved.isFromDocument = true;
             if (saveFavorite) {
                 [saved renameDocumentToUniqueIfNeeded];
                 [[AppSession sharedInstance] addFavorite:saved];
             }else{
                 [AppSession sharedInstance].lastSelectVideo = saved;
                 dispatch_async(dispatch_get_main_queue(), ^{
                     PlaylistViewController* next = [[UIStoryboard storyboardWithName:@"Main" bundle:nil]
                                                     instantiateViewControllerWithIdentifier:@"PlaylistViewController"];
                     next.isNotFromRoot = true;
                     [self.audioControl pause];
                     [self.navigationController pushViewController:next animated:true];
                 });
                 
             }
                  });
         }
         else if (AVAssetExportSessionStatusFailed == exportSession.status)
         {
             [ISMessages showCardAlertWithTitle:nil
                                        message:@"Error!"
                                       duration:1.f
                                    hideOnSwipe:YES
                                      hideOnTap:YES
                                      alertType:ISAlertTypeSuccess
                                  alertPosition:ISAlertPositionTop
                                        didHide:^(BOOL finished) {
                                            NSLog(@"Alert did hide.");
                                        }];
             // It failed...
         }
     }];
    
    return YES;
}

- (void)initAudio{
    self.audioControl = [[AudioPlayerControl alloc] init];
    [self.audioControl initEnginerWithNodes:nil];
    self.audioControl.delegate = self;
//
//    NSString *filePath = [[NSBundle mainBundle] pathForResource:@"noo" ofType:@"mp3"];
//    NSURL* mp3Url = [NSURL fileURLWithPath:filePath];
    self.audioControl.fileURL = self.data.localURL;
}
- (void)dlgAudioPlayerControlPause{
    
    self.toggleButton.selected = false;
}
- (void)dlgAudioPlayerControlPlaying{
    self.toggleButton.selected = true;
}
- (void)dlgAudioPlayerControlPlayingPercent:(CGFloat)percent{
    CGFloat minValue = [self.barValue minValue];
    CGFloat maxValue = [self.barValue maxValue];
    CGFloat barValue = [self.barValue value];
    CGFloat realValue = (percent - minValue)/barValue;
    
    [self.playingDot setvalue:realValue];
    if (percent < minValue || percent > maxValue) {
        [self.audioControl seekPercent:minValue];
    }
}

- (void)initSliderDot{
    if (self.firstDot) {
        return;
    }
    [self.playerSectionView setNeedsLayout];
    [self.playerSectionView layoutIfNeeded];
    self.firstDot = [[AISliderDotVimod alloc]init];
    self.firstDot.delegate = self;
    self.firstDot.dotView = self.firstDotView;
    self.firstDot.barView = self.sliderbarView;
    [self.firstDot setvalue:0];
    
    self.secondDot = [[AISliderDotVimod alloc]init];
    self.secondDot.delegate = self;
    self.secondDot.dotView = self.secondDotView;
    self.secondDot.barView = self.sliderbarView;
    [self.secondDot setvalue:1];
    
    self.barValue = [[AISliderBarValueVimod alloc]init];
    self.barValue.barView = self.valueBarView;
    self.barValue.firstDot = self.firstDot;
    self.barValue.secondDot = self.secondDot;
    
    self.playingDot = [[AISliderDotVimod alloc]init];
    self.playingDot.delegate = self;
    self.playingDot.dotView = self.playingDotView;
    self.playingDot.barView = self.valueBarView;
    [self.playingDot setvalue:0];
    [self updateSlider];
    
}
- (CGPoint)dlgAISliderDotVimod:(AISliderDotVimod*)sender moveFixedBy:(CGPoint)delta{
    return CGPointMake([sender fixDeltaX:delta.x], 0);
    
}
- (void)dlgAISliderDotVimodChanged:(AISliderDotVimod*)sender{
    if (sender == self.playingDot) {
        CGFloat value = [sender value];
        CGFloat minValue = [self.barValue minValue];
        CGFloat barValue = [self.barValue value];
        CGFloat realValue = minValue + value*barValue;
        [self.audioControl seekPercent:realValue];
    }
    [self updateSlider];
}

- (void)dlgAISliderDotVimodEnded:(AISliderDotVimod*)sender{
    self.audioControl.isSeeking = false;
    [self.audioControl play];
}

- (void)dlgAISliderDotVimodBegan:(AISliderDotVimod*)sender{
    self.audioControl.isSeeking = true;
    [self.audioControl pause];
    
}

- (void)updateSlider{
    CGFloat duration = self.audioControl.duration;
    [self.barValue update];
    self.durationLabel.center = CGPointMake(self.valueBarView.center.x, self.durationLabel.center.y);
//    [self.playingDot update];
    CGFloat minTime = duration * [self.firstDot value];
    CGFloat maxTime = duration * [self.secondDot value];
    CGFloat splitDuration = ABS(maxTime - minTime) ;
//    CGFloat splitPlayingTime = [self.playingDot value] * splitDuration + minTime;
    self.firstLabel.text = [self durationString:minTime];
    self.secondLabel.text = [self durationString:maxTime];
    self.durationLabel.text = [self durationString:splitDuration];
}

- (NSString*)durationString:(CGFloat)duration{
    NSInteger total = (long)duration;
    NSInteger seconds = total%60;
    total = total/60;
    NSInteger minutes = total%60;
    NSInteger hours = total/60;
    if (hours>0) {
        return [NSString stringWithFormat:@"%ld:%02ld:%02ld", (long)hours, (long)minutes, (long)seconds];
        
    }
    return [NSString stringWithFormat:@"%02ld:%02ld",(long)minutes, (long)seconds];
}
@end
