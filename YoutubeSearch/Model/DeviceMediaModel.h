//
//  DeviceMediaModel.h
//  YoutubeSearch
//
//  Created by An Nguyen on 12/27/17.
//  Copyright © 2017 An Nguyen. All rights reserved.
//

#import "BaseAppModel.h"
#import "IMediaItem.h"
#import <MediaPlayer/MediaPlayer.h>
#import <AssetsLibrary/AssetsLibrary.h>

@interface DeviceMediaModel : BaseAppModel
@property (nonatomic) NSURL *localURL;
@property (nonatomic) NSString* localName;
@property (nonatomic) NSString* iid;
@property (nonatomic) NSString* documentFileName;
@property (nonatomic) BOOL isFromDocument;
@property (nonatomic) BOOL isFromBundle;
@property (nonatomic) NSString *bundleName;
@property (nonatomic) NSString *bundleExt;
@property (nonatomic) CGFloat duration;
@property (nonatomic, readonly) NSString* durationReadable;
- (NSString*)name;
- (BOOL)renameDocumentToUniqueIfNeeded;
+ (DeviceMediaModel*)createWithMediaItem:(MPMediaItem*)item;
+ (DeviceMediaModel*)createWithALAsset:(ALAsset*)item;
+ (NSString*)randomID;
+ (NSString*)durationString:(CGFloat)duration;
@end
