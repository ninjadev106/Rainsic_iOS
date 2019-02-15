//
//  ControllerServices.h
//  YoutubeSearch
//
//  Created by An Nguyen on 1/30/18.
//  Copyright © 2018 An Nguyen. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "DeviceMediaModel.h"
#import "PlaylistModel.h"

@interface ControllerServices : NSObject
+ (NSMutableArray<DeviceMediaModel *>*)getLocalListSong;
+ (NSMutableArray<DeviceMediaModel *>*)searchLocalSong:(NSString*)search;
//+ (void)playAudio:(DeviceMediaModel*)obj;
+ (void)playAudio:(DeviceMediaModel*)audio inList:(NSArray<DeviceMediaModel*>*)playlist;
+ (void)shareAudio:(DeviceMediaModel*)obj;
+ (void)addToFavorite:(DeviceMediaModel*)obj;
+ (void)addToPlaylist:(DeviceMediaModel*)obj;
+ (void)renameFavorite:(DeviceMediaModel*)obj;
+ (void)deleteAudio:(DeviceMediaModel*)obj fromPlaylist:(PlaylistModel*)playlist;
+ (void)deleteIndex:(NSInteger)index fromPlaylist:(PlaylistModel*)playlist;
@end
