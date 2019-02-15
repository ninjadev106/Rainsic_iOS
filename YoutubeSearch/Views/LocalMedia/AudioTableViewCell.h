//
//  AudioTableViewCell.h
//  YoutubeSearch
//
//  Created by An Nguyen on 10/27/17.
//  Copyright © 2017 An Nguyen. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DeviceMediaModel.h"

@protocol AudioTableViewCellDelegate <NSObject>

@optional
- (void)dlgAudioTableViewCellPlay:(DeviceMediaModel*)data;
- (void)dlgAudioTableViewCellAdd:(DeviceMediaModel*)data;

@end

@interface AudioTableViewCell : UITableViewCell
@property (nonatomic, weak) id<AudioTableViewCellDelegate> delegate;
@property (nonatomic) DeviceMediaModel *data;
@end
