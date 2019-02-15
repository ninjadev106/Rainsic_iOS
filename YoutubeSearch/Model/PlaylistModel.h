//
//  PlaylistModel.h
//  YoutubeSearch
//
//  Created by An Nguyen on 1/29/18.
//  Copyright © 2018 An Nguyen. All rights reserved.
//

#import "BaseAppModel.h"
#import "DeviceMediaModel.h"

@interface PlaylistModel : BaseAppModel

@property (nonatomic) NSInteger idx;
@property (nonatomic) NSString *name;
@property (nonatomic) NSMutableArray<DeviceMediaModel*>* datas;
- (BOOL)addObject:(DeviceMediaModel*)obj;
- (NSMutableArray<DeviceMediaModel *>*)searchSong:(NSString*)search;
@end
