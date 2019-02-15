//
//  PlaylistModel.m
//  YoutubeSearch
//
//  Created by An Nguyen on 1/29/18.
//  Copyright © 2018 An Nguyen. All rights reserved.
//

#import "PlaylistModel.h"

@implementation PlaylistModel

- (instancetype)init
{
    self = [super init];
    if (self) {
        if (!self.datas) {
            self.datas = [NSMutableArray new];
        }
    }
    return self;
}

- (BOOL)addObject:(DeviceMediaModel*)obj{
    [self.datas addObject:obj];
    return true;
}
- (NSMutableArray<DeviceMediaModel *>*)searchSong:(NSString*)search{
    NSMutableArray<DeviceMediaModel *>* result = [NSMutableArray new];
    for (DeviceMediaModel* obj in self.datas) {
        NSString* nameTerm = [obj.localName lowercaseString];
        if ([nameTerm containsString:search] || [search containsString:nameTerm]) {
            [result addObject:obj];
        }
    }
    return result;
}
@end
