//
//  AudioTableViewCell.m
//  YoutubeSearch
//
//  Created by An Nguyen on 10/27/17.
//  Copyright © 2017 An Nguyen. All rights reserved.
//

#import "AudioTableViewCell.h"
#import "UIImageView+WebCache.h"
#import "MultimediaPlayerView.h"

@interface AudioTableViewCell()
@property (weak, nonatomic) IBOutlet UIImageView *thumbView;
@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
@property (weak, nonatomic) IBOutlet UILabel *durationLabel;

@end

@implementation AudioTableViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapGestureHandler:)];
    [self addGestureRecognizer:tapGesture];
    // Initialization code
}

- (void)tapGestureHandler:(UITapGestureRecognizer*)sender{
    DeviceMediaModel* data = self.data;
    if ([self.delegate respondsToSelector:@selector(dlgAudioTableViewCellPlay:)]) {
        [self.delegate dlgAudioTableViewCellPlay:data];
    }
}
                                          
                                          

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}


- (void)setData:(DeviceMediaModel *)data{
    _data = data;
    self.nameLabel.text = _data.localName;
    self.thumbView.alpha = 1;
    self.durationLabel.text = _data.durationReadable;
//    [self.thumbView sd_setImageWithURL:[NSURL URLWithString:_data.thumbnails] placeholderImage:nil completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
//        if (image) {
//            self.thumbView.image = image;
//        }else{
//            self.thumbView.image = [UIImage imageNamed:@"youtube_thumb.jpg"];
//        }
//        [UIView animateWithDuration:0.2 animations:^{
//            self.thumbView.alpha = 1;
//        }];
//    }];
}
- (IBAction)onAddTouched:(UIButton *)sender {
    if ([self.delegate respondsToSelector:@selector(dlgAudioTableViewCellAdd:)]) {
        [self.delegate dlgAudioTableViewCellAdd:self.data];
    }
}
@end
