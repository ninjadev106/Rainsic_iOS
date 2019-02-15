//
//  VideoPlaylistModel.h
//  YoutubeSearch
//
//  Created by An Nguyen on 10/31/17.
//  Copyright © 2017 An Nguyen. All rights reserved.
//

#import "BaseAppModel.h"
#import "DeviceMediaModel.h"

@interface VideoPlaylistModel : BaseAppModel
@property (nonatomic) NSInteger idx;
@property (nonatomic) NSString *name;
@property (nonatomic) NSMutableArray<DeviceMediaModel*>* datas;
- (BOOL)addObject:(DeviceMediaModel*)obj;
@end
