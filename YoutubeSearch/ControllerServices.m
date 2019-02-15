//
//  ControllerServices.m
//  YoutubeSearch
//
//  Created by An Nguyen on 1/30/18.
//  Copyright © 2018 An Nguyen. All rights reserved.
//

#import "ControllerServices.h"
#import "UIViewController+AIPresented.h"
#import "AudioEQController.h"
#import "AppSession.h"
#import <ISMessages.h>
#import <AVKit/AVKit.h>
#import <SVProgressHUD.h>
#import "AppDefine.h"

@interface ControllerServices()
@end

@implementation ControllerServices

static NSMutableArray<DeviceMediaModel *>* __deviceSources;
+ (NSMutableArray<DeviceMediaModel *>*)getLocalListSong{
    if (__deviceSources) {
        return __deviceSources;
    }
    __deviceSources = [NSMutableArray new];
    MPMediaQuery *mediaQuery = [MPMediaQuery songsQuery];
    NSArray<MPMediaItem *>* songs = [mediaQuery items];
    for (MPMediaItem* item in songs) {
        DeviceMediaModel* obj = [DeviceMediaModel createWithMediaItem:item];
        [__deviceSources addObject:obj];
        
    }
    
    /*DeviceMediaModel* obj = [[DeviceMediaModel alloc]init];
    obj.iid = [DeviceMediaModel randomID];
    obj.localName = @"Rainsic";
    obj.isFromBundle = true;
    obj.bundleName = @"noo";
    obj.bundleExt = @"mp3";
    obj.duration = 120;
    [__deviceSources addObject:obj];
    DeviceMediaModel* obj1 = [[DeviceMediaModel alloc]init];
    obj1.iid = [DeviceMediaModel randomID];
    obj1.localName = @"We're Different";
    obj1.isFromBundle = true;
    obj1.bundleName = @"we're different";
    obj1.bundleExt = @"mp3";
    obj1.duration = 126;
    [__deviceSources addObject:obj1];*/
    
    return __deviceSources;
}

+ (NSMutableArray<DeviceMediaModel *>*)searchLocalSong:(NSString*)search{
    NSMutableArray<DeviceMediaModel *>* local = [self getLocalListSong];
    NSMutableArray<DeviceMediaModel *>* result = [NSMutableArray new];
    for (DeviceMediaModel* obj in local) {
        NSString* nameTerm = [obj.localName lowercaseString];
        if ([nameTerm containsString:search] || [search containsString:nameTerm]) {
            [result addObject:obj];
        }
    }
    return result;
}
/*
- (void)buildAssetsLibrary{
    self.assetsLibrary = [[ALAssetsLibrary alloc] init];
    ALAssetsLibrary *notificationSender = nil;
    
    self.videoURLArray = [[NSMutableArray alloc] init];
    
    NSString *minimumSystemVersion = @"4.1";
    NSString *systemVersion = [[UIDevice currentDevice] systemVersion];
    if ([systemVersion compare:minimumSystemVersion options:NSNumericSearch] != NSOrderedAscending)
        notificationSender = self.assetsLibrary;
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(assetsLibraryDidChange:) name:ALAssetsLibraryChangedNotification object:notificationSender];
    [self updateAssetsLibrary];
}

- (void)assetsLibraryDidChange:(NSNotification*)changeNotification{
    [self updateAssetsLibrary];
}

- (void)updateAssetsLibrary{
    self.assetItems = [NSMutableArray arrayWithCapacity:0];
    ALAssetsLibrary *assetLibrary = self.assetsLibrary;
    
    [assetLibrary enumerateGroupsWithTypes:ALAssetsGroupAll usingBlock:^(ALAssetsGroup *group, BOOL *stop)
     {
         if (group)
         {
             [group setAssetsFilter:[ALAssetsFilter allVideos]];
             [group enumerateAssetsUsingBlock:^(ALAsset *asset, NSUInteger index, BOOL *stop){
                 if (asset){
                     DeviceMediaModel* obj = [DeviceMediaModel createWithALAsset:asset];
                     [self.datasources addObject: obj];
                     //                      self.dic = [[NSMutableDictionary alloc] init];
                     //                      ALAssetRepresentation *defaultRepresentation = [asset defaultRepresentation];
                     //                      NSString *uti = [defaultRepresentation UTI];
                     //                      self.videoURL = [[asset valueForProperty:ALAssetPropertyURLs] valueForKey:uti];
                     //
                     //                      self.mpVideoPlayer = [[MPMoviePlayerController alloc] initWithContentURL:self.videoURL];
                     //
                     //                      NSString *title = [NSString stringWithFormat:@"%@ %lu", NSLocalizedString(@"Video", nil), [self.assetItems count]+1];
                     //
                     //                      [self performSelector:@selector(imageFromVideoURL)];
                     //                      [self.dic setValue:title forKey:@"VideoTitle"];//kName
                     //                      [self.dic setValue:self.videoURL forKey:@"VideoUrl"];//kURL
                     //
                     ////                      AssetBrowserItem *item = [[AssetBrowserItem alloc] initWithURL:videoURL title:title];
                     ////                      [assetItems addObject:item];
                     //                      [self.videoURLArray addObject:self.dic];
                     //
                     //                      NSLog(@"Video has info:%@",self.videoURLArray);
                 }
                 NSLog(@"Values of dictonary==>%@", self.dic);
                 
                 //NSLog(@"assetItems:%@",assetItems);
                 NSLog(@"Videos Are:%@",self.videoURLArray);
             } ];
             
             [self.tableView reloadData];
         }
         // group == nil signals we are done iterating.
         else
         {
             dispatch_async(dispatch_get_main_queue(), ^{
                 //[self updateBrowserItemsAndSignalDelegate:assetItems];
                 //                loadImgView.hidden = NO;
                 //                [spinner stopAnimating];
                 //                [loadImgView removeFromSuperview];
                 //selectVideoBtn .userInteractionEnabled = YES;
             });
         }
     }
                              failureBlock:^(NSError *error)
     {
         NSLog(@"error enumerating AssetLibrary groups %@\n", error);
     }];
}

*/

+ (void)addToFavorite:(DeviceMediaModel*)obj{
    [[AppSession sharedInstance] addFavorite:obj];
    [[NSNotificationCenter defaultCenter]
     postNotificationName:ChangeDataNotification
     object:nil];
}
+ (void)addToPlaylist:(DeviceMediaModel*)obj{
    [AppSession sharedInstance].lastSelectVideo = obj;
    dispatch_async(dispatch_get_main_queue(), ^{
        [[AppSession sharedInstance].rootTabBarController.audioController minimizeIfNeeded];
        [AppSession sharedInstance].rootTabBarController.selectedIndex = 2;
    });
}
+ (void) renameFavorite:(DeviceMediaModel *)obj{
    
}

+ (void)deleteAudio:(DeviceMediaModel*)obj fromPlaylist:(PlaylistModel*)playlist{
    if (!playlist) {
        NSInteger index = [[AppSession sharedInstance].favorite.datas indexOfObject:obj];
        [[AppSession sharedInstance].favorite.datas removeObjectAtIndex:index];
    }else{
        NSInteger index = [playlist.datas indexOfObject:obj];
        [playlist.datas removeObjectAtIndex:index];
    }
    [[NSNotificationCenter defaultCenter]
     postNotificationName:ChangeDataNotification
     object:nil];
    [[AppSession sharedInstance] save];
}
//+ (void)deleteAudio:(DeviceMediaModel*)obj fromPlaylist:(PlaylistModel*)playlist{
//    if (!playlist) {
//ddfsd
//        [[AppSession sharedInstance].favorite.datas removeObject:obj];
//    }else{
//        [playlist.datas removeObject:obj];
//    }
//    [[NSNotificationCenter defaultCenter]
//     postNotificationName:ChangeDataNotification
//     object:nil];
//}
+ (void)deleteIndex:(NSInteger)index fromPlaylist:(PlaylistModel*)playlist{
    
    if (!playlist) {
        [[AppSession sharedInstance].favorite.datas removeObjectAtIndex:index];
    }else{
        [playlist.datas removeObjectAtIndex:index];
    }
    [[NSNotificationCenter defaultCenter]
     postNotificationName:ChangeDataNotification
     object:nil];
}
+ (void)playAudio:(DeviceMediaModel*)obj{
    [self playAudio:obj inList:@[obj]];
}

+ (void)playAudio:(DeviceMediaModel*)audio inList:(NSArray<DeviceMediaModel*>*)playlist{
//    [[AppSession sharedInstance].rootTabBarController.mixerManager prepareWithURL:audio.localURL];
//    [[AppSession sharedInstance].rootTabBarController.mixerManager seek:10];
    
    [[AppSession sharedInstance].rootTabBarController.audioController playAudio:audio inList:playlist];
    [[AppSession sharedInstance].rootTabBarController.audioController fullScreenIfNeeded];
}

+ (void)shareAudio:(DeviceMediaModel*)obj{
    
    NSString* urlString = obj.localURL.absoluteString;
    if ([urlString containsString:@"ipod-library://item"]) {
        [self shareFromIPodLibrary:obj];
        return;
    }
    NSArray *activityItems = @[obj.localURL];
    
    UIActivityViewController *activityVC = [[UIActivityViewController alloc] initWithActivityItems:activityItems applicationActivities:nil];
    [UIViewController ai_presentViewController:activityVC animated:true completion:nil];
}

+ (BOOL)shareFromIPodLibrary:(DeviceMediaModel*)obj{
    
    [SVProgressHUD show];
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    NSString *filePath = [NSString stringWithFormat:@"%@/%@", documentsDirectory, @"share_audio.m4a"];
    NSLog(@"filePath %@", filePath);
    
    float vocalStartMarker  = 0;
    float vocalEndMarker    = obj.duration;
    
    NSURL *audioFileInput = obj.localURL;
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
             
             dispatch_async(dispatch_get_main_queue(), ^{
                 // It worked!
                 DeviceMediaModel* saved = [[DeviceMediaModel alloc] init];
                 saved.iid = [DeviceMediaModel randomID];
                 saved.localName = @"share_audio";
                 saved.duration = vocalEndMarker - vocalStartMarker;
                 saved.localURL = audioFileOutput;
                 saved.isFromDocument = true;
                 [self shareAudio:saved];
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
    
    return true;
}
@end
