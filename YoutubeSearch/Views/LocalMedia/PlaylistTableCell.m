//
//  PlaylistTableCell.m
//  YoutubeSearch
//
//  Created by An Nguyen on 10/31/17.
//  Copyright © 2017 An Nguyen. All rights reserved.
//

#import "PlaylistTableCell.h"

@interface PlaylistTableCell()
@property (weak, nonatomic) IBOutlet UILabel *nameLabel;

@end

@implementation PlaylistTableCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)setData:(PlaylistModel *)data{
    _data = data;
    self.nameLabel.text = _data.name;
}

- (IBAction)onEditTouched:(UIButton *)sender {
    if ([self.delegate respondsToSelector:@selector(dlgPlaylistTableCellSelect:)]) {
        [self.delegate dlgPlaylistTableCellSelect:self.data];
    }
}

@end
