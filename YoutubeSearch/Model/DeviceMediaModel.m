//
//  DeviceMediaModel.m
//  YoutubeSearch
//
//  Created by An Nguyen on 12/27/17.
//  Copyright © 2017 An Nguyen. All rights reserved.
//

#import "DeviceMediaModel.h"
@interface DeviceMediaModel()
//@property (nonatomic) MPMediaItem* item;
@end

@implementation DeviceMediaModel

- (NSString *)name{
    return self.localName;
}
- (void)getLink:(IMediaItemLinkCallback)callback{
    callback(self.localURL, nil, nil);
}

- (NSURL *)localURL{
    if (self.documentFileName) {
        return [self documentFilePath: self.documentFileName];
    }
    if (self.isFromBundle) {
        NSString *filePath = [[NSBundle mainBundle] pathForResource:self.bundleName ofType:self.bundleExt];
        return [NSURL fileURLWithPath:filePath];
    }
    return _localURL;
}

- (NSString *)durationReadable{
    return [DeviceMediaModel durationString:self.duration];
}

- (NSURL*)documentFilePath:(NSString*)fileName{
    
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    NSString *filePath = [documentsDirectory stringByAppendingPathComponent:fileName];
    NSURL *urlPath = [NSURL fileURLWithPath:filePath];
    return urlPath;
}

- (BOOL)renameDocumentToUniqueIfNeeded{
    if (!self.isFromDocument || ![self.localURL.absoluteString containsString:@"Documents/audio.m4a"]) {
        return false;
    }
    NSError * error = NULL;
    NSFileManager * fm = [[NSFileManager alloc] init];
    self.documentFileName = [NSString stringWithFormat:@"%@.m4a", [DeviceMediaModel randomID]];
    NSURL *urlPath = [self documentFilePath: self.documentFileName];
    BOOL result = [fm moveItemAtURL:_localURL toURL:urlPath error:&error];
    if (result) {
        self.localURL = urlPath;
    }
    return result;
}

+ (DeviceMediaModel*)createWithMediaItem:(MPMediaItem*)item{
    DeviceMediaModel* obj = [[DeviceMediaModel alloc]init];
    obj.duration = item.playbackDuration;
    obj.localURL = [item valueForProperty:MPMediaItemPropertyAssetURL];
    obj.localName = [item valueForProperty:MPMediaItemPropertyTitle];
    return obj;
}

+ (DeviceMediaModel*)createWithALAsset:(ALAsset*)item{
    
    DeviceMediaModel* obj = [[DeviceMediaModel alloc]init];
    obj.localURL = [[item defaultRepresentation] url];
    obj.localName = @"Noname";
    obj.iid = obj.localURL.absoluteString;
    return obj;
}
+ (NSString *)randomID{
    return [[NSProcessInfo processInfo] globallyUniqueString];
}

+ (NSString*)durationString:(CGFloat)duration{
    
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
