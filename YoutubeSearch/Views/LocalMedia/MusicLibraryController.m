//
//  MusicLibraryController.m
//  YoutubeSearch
//
//  Created by An Nguyen on 12/27/17.
//  Copyright © 2017 An Nguyen. All rights reserved.
//

#import "MusicLibraryController.h"
#import <MediaPlayer/MediaPlayer.h>
#import <AssetsLibrary/AssetsLibrary.h>
#import <AVFoundation/AVFoundation.h>
#import "MultimediaPlayerView.h"
#import "DeviceMediaModel.h"
#import <AVKit/AVKit.h>
#import "AudioTableViewCell.h"
#import "UIAlertView+BlocksKit.h"
#import "UIActionSheet+BlocksKit.h"
#import "NSObject+Block.h"
#import <ISMessages.h>
#import "AppSession.h"
#import "ControllerServices.h"
#import "AppDefine.h"
#import "RootTabBarController.h"
#import "AudioSplitController.h"
#import <AppLovinSDK/AppLovinSDK.h>

@interface MusicLibraryController ()<UITableViewDelegate, UITableViewDataSource, AudioTableViewCellDelegate>{
    
    AVAudioFramePosition lengthSongSamples;
    float sampleRateSong;
    float lengthSongSeconds;
    float startInSongSeconds;
}
@property (weak, nonatomic) IBOutlet UITableView *tableView;

@property (nonatomic) NSMutableArray<DeviceMediaModel *>* datasources;

//
//@property AVAudioEngine *audioEngine;
//@property AVAudioPlayerNode* audioPlayerNode;
//@property AVAudioFile *audioFile;
//@property AVAudioUnitTimePitch *changePitchEffect;
//@property AVAudioUnitEQ *equalizer;
//@property AVAudioEnvironmentNode *mixer;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *bottomCst;
@property BOOL isSeeking;
@end

@implementation MusicLibraryController

- (void)viewDidLoad {
    [super viewDidLoad];
  
//    UITabBarController * tab = [[RootTabBarController alloc]init];
//    tab.tabBarItem.selectedImage =  [[UIImage imageNamed:@"favorite"]
//                                       imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
//
//    tab.tabBarItem.image  = [[UIImage imageNamed:@"favorite"]
//                             imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
    
    [self initTableView];
//    [self getLocalListSong];
    //[self checkPermissionForMusic];
    self.datasources = [ControllerServices getLocalListSong];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(playerAppearNotificationListener:)
                                                 name:PlayerAppearNotification
                                               object:nil];
    
    ALEventService* eventService = [ALSdk shared].eventService;
    
    [eventService trackEvent: kALEventTypeUserViewedContent
                  parameters: @{
                                kALEventParameterContentIdentifierKey : @"Viewed Main Page(Music library)"
                                }
     ];
    
}

- (void)checkPermissionForMusic {
    if (MPMediaLibrary.authorizationStatus != MPMediaLibraryAuthorizationStatusAuthorized) {
        [MPMediaLibrary requestAuthorization:^(MPMediaLibraryAuthorizationStatus status){
            switch (status) {
                    case MPMediaLibraryAuthorizationStatusNotDetermined: {
                        // not determined
                        break;
                    }
                    case MPMediaLibraryAuthorizationStatusRestricted: {
                        // restricted
                        break;
                    }
                    case MPMediaLibraryAuthorizationStatusDenied: {
                        // denied
                        break;
                    }
                    case MPMediaLibraryAuthorizationStatusAuthorized: {
                        self.datasources = [ControllerServices getLocalListSong];
                        break;
                    }
                default: {
                    break;
                }
            }
        }];
    } else {
        self.datasources = [ControllerServices getLocalListSong];
    }
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [AppSession sharedInstance].rootTabBarController.childTab = self;
    [[AppSession sharedInstance].rootTabBarController.audioController minimizeIfNeeded];
}

- (void)playerAppearNotificationListener:(NSNotification *) notification
{
    if ([[notification name] isEqualToString:PlayerAppearNotification]){
        BOOL isNeedSpace = [notification.object boolValue];
        self.bottomCst.constant = isNeedSpace?120:0;
    }
}

#pragma mark - TableView
- (void)initTableView{
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.tableView.backgroundView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"bg"]];

}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return self.datasources.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    AudioTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell" forIndexPath:indexPath];
    cell.data = [self.datasources objectAtIndex:indexPath.row];
    cell.delegate = self;
    return cell;
}

- (void)dlgAudioTableViewCellPlay:(DeviceMediaModel*)data{
    [ControllerServices playAudio:data inList:self.datasources];
}

- (void)dlgAudioTableViewCellAdd:(DeviceMediaModel*)data{
    // Old Action Sheet
  /*  UIActionSheet *actionSheet = [UIActionSheet bk_actionSheetWithTitle:@"Menu Action"];
    
    [actionSheet bk_addButtonWithTitle:@"Add To Playlist" handler:^{
        [AppSession sharedInstance].lastSelectVideo = data;
        [AppSession sharedInstance].rootTabBarController.selectedIndex = 2;
    }];
    
    [actionSheet bk_addButtonWithTitle:@"Add To Favorites" handler:^{
        [[AppSession sharedInstance] addFavorite:data];
    }];
    
    [actionSheet bk_setCancelButtonWithTitle:@"Cancel" handler:^{
        
    }];
    [actionSheet showInView:self.view];*/
    // Old Action Sheet
    
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:nil
                                                                             message:nil
                                                                      preferredStyle:UIAlertControllerStyleActionSheet];
    
    UIAlertAction *addToPlaylist = [UIAlertAction
                                    actionWithTitle:@"Add To Playlist"
                                    style:UIAlertActionStyleDefault
                                    handler:^(UIAlertAction *action){
                                        NSLog(@"Add To Playlist");
                            [AppSession sharedInstance].lastSelectVideo = data;
                            [AppSession sharedInstance].rootTabBarController.selectedIndex = 2;
                                        
                                    }];
    [addToPlaylist setValue:[[UIImage imageNamed:@"ic_playlist_white"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal] forKey:@"image"];
    [alertController addAction:addToPlaylist];
    
    
    UIAlertAction *AddToFavorites = [UIAlertAction
                             actionWithTitle:@"Add To Favorites"
                             style:UIAlertActionStyleDefault
                             handler:^(UIAlertAction *action) {
                                 NSLog(@"Add To Favorites");
                             [[AppSession sharedInstance] addFavorite:data];
                             }];
    [AddToFavorites setValue:[[UIImage imageNamed:@"ic_favorite_white"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal] forKey:@"image"];
    [alertController addAction:AddToFavorites];
    
    UIAlertAction *cutAudio = [UIAlertAction
                                    actionWithTitle:@"Cut Audio"
                                    style:UIAlertActionStyleDefault
                                    handler:^(UIAlertAction *action){
                                        NSLog(@"Cut Audio");
                                        [self onCutAudio:data];
                                    }];
    [cutAudio setValue:[[UIImage imageNamed:@"ic_scissor"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal] forKey:@"image"];
    [alertController addAction:cutAudio];
    
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

- (void)onCutAudio:(DeviceMediaModel*)data {
    AudioSplitController* next = [[UIStoryboard storyboardWithName:@"Main" bundle:nil] instantiateViewControllerWithIdentifier:@"AudioSplitController"];
    next.data = data;
    //[self.audioControl pause];
    UINavigationController *nav = [[UINavigationController alloc]initWithRootViewController:next];
    [[AppSession sharedInstance].rootTabBarController presentViewController:nav animated:true completion:nil];
}
//- (void)searchString:(NSString *)search{
//    self.datasources = [NSMutableArray new];
//    for (DeviceMediaModel *obj in self.allSources) {
//        NSString* nameTerm = [obj.localName lowercaseString];
//        if ([nameTerm containsString:search] || [search containsString:nameTerm]) {
//            [self.datasources addObject:obj];
//        }
//    }
//    [self.tableView reloadData];
//}
//
//- (void)cancelSearch{
//    self.datasources = [NSMutableArray arrayWithArray:self.allSources];
//    [self.tableView reloadData];
//}

/*
 
 - (UIImage *)imageFromVideoURL{
 
 UIImage *image = nil;
 AVAsset *asset = [[AVURLAsset alloc] initWithURL:self.videoURL options:nil];;
 AVAssetImageGenerator *imageGenerator = [[AVAssetImageGenerator alloc] initWithAsset:asset];
 imageGenerator.appliesPreferredTrackTransform = YES;
 
 // calc midpoint time of video
 Float64 durationSeconds = CMTimeGetSeconds([asset duration]);
 CMTime midpoint = CMTimeMakeWithSeconds(durationSeconds/2.0, 600);
 
 // get the image from
 NSError *error = nil;
 CMTime actualTime;
 CGImageRef halfWayImage = [imageGenerator copyCGImageAtTime:midpoint actualTime:&actualTime error:&error];
 
 if (halfWayImage != NULL)
 {
 // cgimage to uiimage
 image = [[UIImage alloc] initWithCGImage:halfWayImage];
 [self.dic setValue:image forKey:@"ImageThumbnail"];//kImage
 NSLog(@"Values of dictonary==>%@", self.dic);
 NSLog(@"Videos Are:%@",self.videoURLArray);
 CGImageRelease(halfWayImage);
 }
 return image;
 }
 
- (void)playSampleAudio:(DeviceMediaModel*)obj{
    [self playAudioUrl:obj.localURL];
}
- (void)playAudioUrl:(NSURL*)url{
//    NSString *filePath = [[NSBundle mainBundle] pathForResource:@"noo" ofType:@"mp3"];
    NSError *err;
    NSURL* mp3Url = url;//[NSURL fileURLWithPath:filePath];
    self.audioEngine = [[AVAudioEngine alloc] init];
    self.audioFile = [[AVAudioFile alloc] initForReading:mp3Url error:&err];
    NSLog(@"Audio Leng %lld", self.audioFile.length);
    NSLog(@"Audio sampleRate %f", self.audioFile.fileFormat.sampleRate);
    NSLog(@"Audio duration %f", self.audioFile.length/(double)self.audioFile.fileFormat.sampleRate);
    
    AVAudioSession*session = [AVAudioSession sharedInstance];
    [session setCategory:AVAudioSessionCategoryPlayAndRecord error:nil];
    [session overrideOutputAudioPort:AVAudioSessionPortOverrideSpeaker error:nil];
    
    self.audioPlayerNode = [[AVAudioPlayerNode alloc]init];
    //    [self.audioPlayerNode addObserver:self forKeyPath:@"playing" options:NSKeyValueObservingOptionNew | NSKeyValueObservingOptionOld context:nil];
    [self.audioEngine attachNode:self.audioPlayerNode];
    
    self.changePitchEffect = [[AVAudioUnitTimePitch alloc]init];
    self.changePitchEffect.pitch = 500;
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
    [self.audioPlayerNode play];
}
- (void)applyEQPop{
    NSArray*gains = @[@(0),@(3),@(6),@(5),@(3.3),@(-0.5),@(-0.7),@(-2.6),@(-4),@(-3.8)];
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
 */
@end
