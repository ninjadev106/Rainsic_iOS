//
//  YTPlaylistTableCell.m
//  YoutubeSearch
//
//  Created by An Nguyen on 10/31/17.
//  Copyright © 2017 An Nguyen. All rights reserved.
//

#import "YTPlaylistTableCell.h"

@interface YTPlaylistTableCell()
@property (weak, nonatomic) IBOutlet UILabel *nameLabel;

@end

@implementation YTPlaylistTableCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)setData:(VideoPlaylistModel *)data{
    _data = data;
    self.nameLabel.text = _data.name;
}

- (IBAction)onEditTouched:(UIButton *)sender {
    if ([self.delegate respondsToSelector:@selector(dlgYTPlaylistTableCellSelect:)]) {
        [self.delegate dlgYTPlaylistTableCellSelect:self.data];
    }
}

@end
