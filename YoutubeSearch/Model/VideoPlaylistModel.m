//
//  VideoPlaylistModel.m
//  YoutubeSearch
//
//  Created by An Nguyen on 10/31/17.
//  Copyright © 2017 An Nguyen. All rights reserved.
//

#import "VideoPlaylistModel.h"

@implementation VideoPlaylistModel
- (instancetype)init
{
    self = [super init];
    if (self) {
        self.name  = @"Playlist";
        self.datas = [NSMutableArray new];
    }
    return self;
}
- (BOOL)addObject:(DeviceMediaModel*)obj{
    for (DeviceMediaModel *it in self.datas) {
        if ([it.iid isEqualToString:obj.iid]) {
            return false;
        }
    }
    [self.datas insertObject:obj atIndex:0];
    return true;
}
@end
