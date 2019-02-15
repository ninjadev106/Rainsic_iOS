//
//  YTPlaylistTableCell.h
//  YoutubeSearch
//
//  Created by An Nguyen on 10/31/17.
//  Copyright © 2017 An Nguyen. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "VideoPlaylistModel.h"

@protocol YTPlaylistTableCellDelegate <NSObject>

@optional
- (void)dlgYTPlaylistTableCellSelect:(VideoPlaylistModel*)data;

@end

@interface YTPlaylistTableCell : UITableViewCell
@property (nonatomic, weak) id<YTPlaylistTableCellDelegate> delegate;
@property (nonatomic) VideoPlaylistModel *data;
@end
