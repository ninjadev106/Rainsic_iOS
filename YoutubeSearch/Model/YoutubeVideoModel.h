//
//  YoutubeVideoModel.h
//  YoutubeSearch
//
//  Created by An Nguyen on 10/27/17.
//  Copyright © 2017 An Nguyen. All rights reserved.
//

#import "BaseAppModel.h"
#import "IMediaItem.h"

@interface YoutubeVideoModel : BaseAppModel<IMediaItem>

@property (nonatomic) NSString *videoId;
@property (nonatomic) NSString *title;
@property (nonatomic) NSString *duration;
@property (nonatomic, readonly) NSString *durationReadable;
@property (nonatomic) NSString *thumbnails;

@end
