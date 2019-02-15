//
//  YTPlaylistViewController.m
//  YoutubeSearch
//
//  Created by An Nguyen on 10/31/17.
//  Copyright © 2017 An Nguyen. All rights reserved.
//

#import "YTPlaylistViewController.h"
#import "UIAlertView+BlocksKit.h"
#import "VideoPlaylistModel.h"
#import "AppSession.h"
#import "PlaylistTableCell.h"
#import "UIAlertView+BlocksKit.h"
#import "UIActionSheet+BlocksKit.h"
#import <ISMessages.h>
#import "YoutubeTableViewCell.h"
#import "MultimediaPlayerView.h"

@interface YTPlaylistViewController ()<UITableViewDelegate, UITableViewDataSource, PlaylistTableCellDelegate, YoutubeTableViewCellDelegate>
@property (weak, nonatomic) IBOutlet UITableView *playlistTableView;

@property (nonatomic) VideoPlaylistModel* currentPlaylist;
@property (weak, nonatomic) IBOutlet UIButton *backSearchButton;


@property (weak, nonatomic) IBOutlet UILabel *playlistNameLabel;
@property (weak, nonatomic) IBOutlet UIView *listItemView;
@property (weak, nonatomic) IBOutlet UITableView *listItemTableView;

@end

@implementation YTPlaylistViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.playlistTableView.dataSource = self;
    self.playlistTableView.delegate = self;
    self.listItemTableView.dataSource = self;
    self.listItemTableView.delegate = self;
    // Do any additional setup after loading the view.
}

- (void)viewDidDisappear:(BOOL)animated{
    [super viewDidDisappear:animated];
    [AppSession sharedInstance].lastSelectVideo = nil;
}
- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    self.backSearchButton.hidden = [AppSession sharedInstance].lastSelectVideo == nil;
    if ([AppSession sharedInstance].lastSelectVideo) {
        self.listItemView.hidden = true;
    }
}

- (void)setCurrentPlaylist:(VideoPlaylistModel *)currentPlaylist{
    _currentPlaylist = currentPlaylist;
    
    if (_currentPlaylist) {
        self.playlistNameLabel.text = _currentPlaylist.name;
    }
}

- (IBAction)onClosePlaylistTouched:(UIButton *)sender {
    [UIView animateWithDuration:0.2 animations:^{
        self.listItemView.alpha = 0;
    } completion:^(BOOL finished) {
        self.listItemView.hidden = true;
    }];
}
- (IBAction)onBackSearchTouched:(UIButton *)sender {
    [AppSession sharedInstance].rootTabBarController.selectedIndex = 0;
}

- (IBAction)onCreatePlaylistTouched:(id)sender {
    
    UIAlertController * alertController = [UIAlertController alertControllerWithTitle: nil
                                                                              message: @"Name New Playlist"
                                                                       preferredStyle:UIAlertControllerStyleAlert];
    [alertController addTextFieldWithConfigurationHandler:^(UITextField *textField) {
    }];
    [alertController addAction:[UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        
    }]];
    [alertController addAction:[UIAlertAction actionWithTitle:@"Done" style:UIAlertActionStyleCancel handler:^(UIAlertAction *action) {
        NSArray * textfields = alertController.textFields;
        UITextField * namefield = textfields[0];
        [self createPlaylist:namefield.text];
        [self.playlistTableView reloadData];
        
    }]];
    [self presentViewController:alertController animated:YES completion:nil];
}

- (VideoPlaylistModel*)createPlaylist:(NSString*)name{
    VideoPlaylistModel *playlist = [[VideoPlaylistModel alloc]init];
    playlist.name = name;
    [[AppSession sharedInstance] addPlayList:playlist];
    return playlist;
}

#pragma mark - Table

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    if (tableView == self.playlistTableView) {
        return [AppSession sharedInstance].playlists.count;
    }
    if (tableView == self.listItemTableView) {
        return self.currentPlaylist.datas.count;
    }
    return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    if (tableView == self.playlistTableView) {
        PlaylistTableCell* cell = [tableView dequeueReusableCellWithIdentifier:@"cell"];
        cell.data = [[AppSession sharedInstance].playlists objectAtIndex:indexPath.row];
        cell.delegate = self;
        return cell;
    }
    
    if (tableView == self.listItemTableView) {
        YoutubeTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell"];
        cell.data = [self.currentPlaylist.datas objectAtIndex:indexPath.row];
        cell.delegate = self;
        return cell;
    }
    return nil;
}

- (void)dlgYoutubeTableViewCellPlay:(YoutubeVideoModel*)data{
    [MultimediaPlayerView sharedInstance].datasources = _currentPlaylist.datas;
    [[MultimediaPlayerView sharedInstance] playAsFirstIfSuffered:data];
    [[MultimediaPlayerView sharedInstance] showFull:true];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:true];
    
    if (tableView == self.playlistTableView) {
        
        VideoPlaylistModel *data = [[AppSession sharedInstance].playlists objectAtIndex:indexPath.row];
        self.currentPlaylist = data;
        
        if ([AppSession sharedInstance].lastSelectVideo) {
            VideoPlaylistModel *playlist = [[AppSession sharedInstance].playlists objectAtIndex:indexPath.row];
            [playlist addObject:[AppSession sharedInstance].lastSelectVideo];
            [AppSession sharedInstance].lastSelectVideo = nil;
            [[AppSession sharedInstance] save];
            
            [ISMessages showCardAlertWithTitle:nil
                                       message:[NSString stringWithFormat:@"Added to Playlist %@", playlist.name]
                                      duration:1.f
                                   hideOnSwipe:YES
                                     hideOnTap:YES
                                     alertType:ISAlertTypeSuccess
                                 alertPosition:ISAlertPositionTop
                                       didHide:^(BOOL finished) {
                                           NSLog(@"Alert did hide.");
                                       }];
        }else{
            self.listItemView.alpha = 0;
            self.listItemView.hidden = false;
            [self.listItemTableView reloadData];
            [UIView animateWithDuration:0.2 animations:^{
                self.listItemView.alpha = 1;
                
            }];
        }
    }
    
}


- (void)dlgPlaylistTableCellSelect:(VideoPlaylistModel*)data{
    
    UIActionSheet *actionSheet = [UIActionSheet bk_actionSheetWithTitle:@"Menu Action"];
    
    [actionSheet bk_addButtonWithTitle:@"Rename Playlist" handler:^{
        self.currentPlaylist = data;
        [self renameCurrentPlaylist];
    }];
    
    [actionSheet bk_addButtonWithTitle:@"Delete Playlist" handler:^{
        self.currentPlaylist = data;
        [self deleteCurrentPlaylist];
    }];
    
    [actionSheet bk_setCancelButtonWithTitle:@"Cancel" handler:^{
        
    }];
    [actionSheet showInView:self.view];
}
- (void)deleteCurrentPlaylist{
    
    UIAlertView *confirmView = [UIAlertView bk_alertViewWithTitle:nil message:@"Are your sure?"];
    [confirmView bk_addButtonWithTitle:@"No" handler:^{
    }];
    [confirmView bk_addButtonWithTitle:@"Yes" handler:^{
        [[AppSession sharedInstance] deletePlaylist:self.currentPlaylist];
        [self.playlistTableView reloadData];
        
    }];
    [confirmView show];
}
- (void)renameCurrentPlaylist{
    UIAlertController * alertController = [UIAlertController alertControllerWithTitle: nil
                                                                              message: @"Rename Playlist"
                                                                       preferredStyle:UIAlertControllerStyleAlert];
    [alertController addTextFieldWithConfigurationHandler:^(UITextField *textField) {
    }];
    [alertController addAction:[UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        
    }]];
    [alertController addAction:[UIAlertAction actionWithTitle:@"Rename" style:UIAlertActionStyleCancel handler:^(UIAlertAction *action) {
        NSArray * textfields = alertController.textFields;
        UITextField * namefield = textfields[0];
        self.currentPlaylist.name = namefield.text;
        [[AppSession sharedInstance] save];
        [self.playlistTableView reloadData];
        
    }]];
    [self presentViewController:alertController animated:YES completion:nil];
}

@end
