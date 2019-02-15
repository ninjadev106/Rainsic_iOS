//
//  YoutubeVideoModel.m
//  YoutubeSearch
//
//  Created by An Nguyen on 10/27/17.
//  Copyright © 2017 An Nguyen. All rights reserved.
//

#import "YoutubeVideoModel.h"
//#import <XCDYouTubeKit/XCDYouTubeKit.h>
#import "YYModel.h"

@interface YoutubeVideoModel()

//@property (nonatomic, weak) id<XCDYouTubeOperation> videoOperation;
@property (nonatomic) NSURL *url;
@property (nonatomic) NSURL *thumb;
@end

@implementation YoutubeVideoModel

+ (NSDictionary *)modelCustomPropertyMapper {
    return @{@"videoId" : @"id.videoId",
             @"duration" : @"contentDetails.duration",
             @"title" : @"snippet.title",
             @"thumbnails" : @"snippet.thumbnails.default.url"};
}

+ (instancetype)createWithDictionary:(NSDictionary *)dictionary{
    if ([dictionary isKindOfClass:[NSNull class]]) {
        return nil;
    }
    return [self yy_modelWithDictionary:dictionary];
}

+ (NSMutableArray*)createWithArray:(NSArray *)array{
    if ([array isKindOfClass:[NSNull class]]) {
        return nil;
    }
    NSMutableArray *datas = [NSMutableArray new];
    for(NSDictionary *dic in array){
        [datas addObject:[self createWithDictionary:dic]];
    }
    return datas;
}
/*
static NSArray *__preferredVideoQualities;

+ (NSArray *) preferredVideoQualities
{
    if (!__preferredVideoQualities)
        __preferredVideoQualities = @[ XCDYouTubeVideoQualityHTTPLiveStreaming, @(XCDYouTubeVideoQualityHD720), @(XCDYouTubeVideoQualityMedium360), @(XCDYouTubeVideoQualitySmall240) ];
    
    return __preferredVideoQualities;
}*/
- (NSString *)durationReadable{
    if (self.duration) {
        return [self parseDuration:self.duration];
    }
    return @"--:--";
}
- (NSString *)parseDuration:(NSString *)duration {
    NSInteger hours = 0;
    NSInteger minutes = 0;
    NSInteger seconds = 0;
    
    NSRange timeRange = [duration rangeOfString:@"T"];
    duration = [duration substringFromIndex:timeRange.location];
    
    while (duration.length > 1) {
        duration = [duration substringFromIndex:1];
        
        NSScanner *scanner = [NSScanner.alloc initWithString:duration];
        NSString *part = [NSString.alloc init];
        [scanner scanCharactersFromSet:[NSCharacterSet decimalDigitCharacterSet] intoString:&part];
        
        NSRange partRange = [duration rangeOfString:part];
        
        duration = [duration substringFromIndex:partRange.location + partRange.length];
        
        NSString *timeUnit = [duration substringToIndex:1];
        if ([timeUnit isEqualToString:@"H"])
        hours = [part integerValue];
        else if ([timeUnit isEqualToString:@"M"])
        minutes = [part integerValue];
        else if ([timeUnit isEqualToString:@"S"])
        seconds = [part integerValue];
    }
    if (hours>0) {
        return [NSString stringWithFormat:@"%ld:%02ld:%02ld", (long)hours, (long)minutes, (long)seconds];

    }
    return [NSString stringWithFormat:@"%02ld:%02ld",(long)minutes, (long)seconds];
}
/*
- (void)getLink:(IMediaItemLinkCallback)callback{
    
    if (self.url) {
        callback(_url, _thumb, nil);
    }
    
    [self.videoOperation cancel];
    self.videoOperation = [[XCDYouTubeClient defaultClient] getVideoWithIdentifier:self.videoId completionHandler:^(XCDYouTubeVideo *video, NSError *error)
                           {
                               if (video)
                               {
                                   NSURL *streamURL = nil;
                                   for (NSNumber *videoQuality in [YoutubeVideoModel preferredVideoQualities])
                                   {
                                       streamURL = video.streamURLs[videoQuality];
                                       if (streamURL)
                                       {
                                           callback(streamURL, video.largeThumbnailURL, nil);
//                                           [self startVideo:video streamURL:streamURL];
                                           break;
                                       }
                                   }
                                   
                                   if (!streamURL)
                                   {
                                       NSError *noStreamError = [NSError errorWithDomain:XCDYouTubeVideoErrorDomain code:XCDYouTubeErrorNoStreamAvailable userInfo:nil];
                                       callback(nil, nil, noStreamError);
//                                       [self stopWithError:noStreamError];
                                   }
                               }
                               else
                               {
                                   callback(nil, nil, error);
//                                   [self stopWithError:error];
                               }
                           }];
}*/
@end
