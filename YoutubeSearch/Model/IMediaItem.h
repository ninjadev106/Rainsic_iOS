//
//  IMediaItem.h
//  YoutubeSearch
//
//  Created by An Nguyen on 12/25/17.
//  Copyright © 2017 An Nguyen. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef void(^IMediaItemLinkCallback)(NSURL* url, NSURL* thumb, NSError *error);

@protocol IMediaItem <NSObject>

- (void)getLink:(IMediaItemLinkCallback)callback;

@end
