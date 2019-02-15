//
//  YoutubeTableViewCell.h
//  YoutubeSearch
//
//  Created by An Nguyen on 10/27/17.
//  Copyright © 2017 An Nguyen. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "YoutubeVideoModel.h"

@protocol YoutubeTableViewCellDelegate <NSObject>

@optional
- (void)dlgYoutubeTableViewCellPlay:(YoutubeVideoModel*)data;
- (void)dlgYoutubeTableViewCellAdd:(YoutubeVideoModel*)data;

@end

@interface YoutubeTableViewCell : UITableViewCell
@property (nonatomic, weak) id<YoutubeTableViewCellDelegate> delegate;
@property (nonatomic) YoutubeVideoModel *data;
@end
