//
//  AppSession.h
//  YoutubeSearch
//
//  Created by An Nguyen on 10/31/17.
//  Copyright © 2017 An Nguyen. All rights reserved.
//

#import "BaseAppModel.h"
#import "PlaylistModel.h"
#import "RootTabBarController.h"
#define GoogleAPIKey @"AIzaSyAoJQe1YFP6ycLrlf0a-UMtW2NvPNSC8R8"

@interface AppSession : BaseAppModel
@property (nonatomic) NSInteger indexCounter;
@property (nonatomic) PlaylistModel *favorite;
@property (nonatomic) NSMutableArray<PlaylistModel*> *playlists;
@property (nonatomic) DeviceMediaModel* lastSelectVideo;
@property (nonatomic, weak) RootTabBarController *rootTabBarController;

@property (nonatomic) NSInteger fastSeekValue;
@property (nonatomic) NSInteger loopMode;


- (void)addPlayList:(PlaylistModel*)playlist;
- (void)addFavorite:(DeviceMediaModel*)video;
- (void)deletePlaylist:(PlaylistModel*)playlist;
- (void)save;
- (NSMutableArray<DeviceMediaModel *>*)searchSong:(NSString*)search;
+ (instancetype)loadSession;
+ (void)saveSession:(AppSession*)session;
+ (void)remove;
+ (AppSession*)sharedInstance;
@end
