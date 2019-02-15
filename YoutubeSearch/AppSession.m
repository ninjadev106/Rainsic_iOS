//
//  AppSession.m
//  YoutubeSearch
//
//  Created by An Nguyen on 10/31/17.
//  Copyright © 2017 An Nguyen. All rights reserved.
//

#import "AppSession.h"
#import <ISMessages.h>
#import "ControllerServices.h"

@implementation AppSession
+ (instancetype)loadSession{
    Class SessionClass = [self class];
    AppSession *session = [NSKeyedUnarchiver unarchiveObjectWithFile:[self fileName]];
    if (!session) {
        session = [[SessionClass alloc]init];
    }
    return session;
}
+ (void)saveSession:(id)session{;
    [NSKeyedArchiver archiveRootObject:session toFile:[self fileName]];
}
+ (NSString*)fileName{
    NSString *filePath = [self ai_filePath:[NSString stringWithFormat:@"session_%@.txt", NSStringFromClass([self class])]];
    NSLog(@"Session Path %@", filePath);
    return filePath;
}

- (void)setLoopMode:(NSInteger)loopMode{
    _loopMode = loopMode%3;
}

- (void)save{
    [self.class saveSession:self];
}

- (NSMutableArray<DeviceMediaModel *>*)searchSong:(NSString*)search{
    
    NSMutableArray<DeviceMediaModel *>* local = [ControllerServices searchLocalSong:search];
    NSMutableArray<DeviceMediaModel *>* result = [NSMutableArray arrayWithArray:local];
    
    [result addObjectsFromArray:[self.favorite searchSong:search]];
    for (PlaylistModel* obj in self.playlists) {
        [result addObjectsFromArray:[obj searchSong:search]];
    }
    return result;
}

+ (void)remove{
    NSLog(@"Remove Session");
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSError *error;
    [fileManager removeItemAtPath:[self fileName] error:&error];
    NSLog(@"End Remove");
}

+ (NSString*)ai_filePath:(NSString*)fileName{
    
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    return [documentsDirectory stringByAppendingPathComponent:fileName];
}

static AppSession* __AppSession;
+ (AppSession*)sharedInstance{
    if(!__AppSession){
        __AppSession = [AppSession loadSession];
    };
    return __AppSession;
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        if (self.fastSeekValue == 0) {
            self.fastSeekValue = 15;
        }
        if (!self.favorite) {
            self.favorite = [[PlaylistModel alloc]init];
            self.favorite.idx = 1;
            self.favorite.name = @"Favorite";
        }
        if (!self.playlists) {
            self.playlists = [NSMutableArray new];
        }
        if (self.indexCounter == 0) {
            self.indexCounter = 5;
        }
    }
    return self;
}

- (void)addPlayList:(PlaylistModel*)playlist{
    self.indexCounter++;
    playlist.idx = self.indexCounter;
    [self.playlists addObject:playlist];
    [self save];
}
- (void)addFavorite:(DeviceMediaModel*)video{
    [self.favorite addObject:video];
    [ISMessages showCardAlertWithTitle:nil
                               message:@"Added to Favorites"
                              duration:1.f
                           hideOnSwipe:YES
                             hideOnTap:YES
                             alertType:ISAlertTypeSuccess
                         alertPosition:ISAlertPositionTop
                               didHide:^(BOOL finished) {
                                   NSLog(@"Alert did hide.");
                               }];
    [self save];
}

- (void)deletePlaylist:(PlaylistModel*)playlist{
    [self.playlists removeObject:playlist];
    [self save];
}

#pragma mark - YYModel
+ (NSDictionary*)modelContainerPropertyGenericClass{
    NSDictionary *seftDict =  @{@"playlists" : [PlaylistModel class]};
    return seftDict;
}

+ (NSArray *)modelPropertyBlacklist {
    return @[@"lastSelectVideo", @"rootTabBarController"];
}
@end
