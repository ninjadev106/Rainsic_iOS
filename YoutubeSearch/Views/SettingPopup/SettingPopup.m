//
//  SettingPopup.m
//  YoutubeSearch
//
//  Created by An Nguyen on 3/28/18.
//  Copyright © 2018 An Nguyen. All rights reserved.
//

#import "SettingPopup.h"
#import "AppSession.h"

@interface SettingPopup ()
@property (weak, nonatomic) IBOutlet UIView *backView;
@property (weak, nonatomic) IBOutlet UISegmentedControl *seekSegmented;
@end

@implementation SettingPopup

- (void)viewDidLoad {
    [super viewDidLoad];
    [self addTapDismissToView:_backView];
    self.seekSegmented.selectedSegmentIndex = ([AppSession sharedInstance].fastSeekValue/5-1);
}

- (IBAction)onDismissTouched:(UIButton *)sender {
    [self dismiss];
}


- (IBAction)onSavedouched:(UIButton *)sender {
    [AppSession sharedInstance].fastSeekValue = (self.seekSegmented.selectedSegmentIndex + 1)*5;
    [[AppSession sharedInstance] save];
    [self dismiss];
}

@end
