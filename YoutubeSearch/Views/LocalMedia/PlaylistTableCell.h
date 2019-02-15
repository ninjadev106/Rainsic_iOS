//
//  PlaylistTableCell.h
//  YoutubeSearch
//
//  Created by An Nguyen on 10/31/17.
//  Copyright © 2017 An Nguyen. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PlaylistModel.h"

@protocol PlaylistTableCellDelegate <NSObject>

@optional
- (void)dlgPlaylistTableCellSelect:(PlaylistModel*)data;

@end

@interface PlaylistTableCell : UITableViewCell
@property (nonatomic, weak) id<PlaylistTableCellDelegate> delegate;
@property (nonatomic) PlaylistModel *data;
@end
