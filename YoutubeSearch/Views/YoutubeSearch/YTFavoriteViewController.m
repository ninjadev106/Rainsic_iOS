//
//  YTFavoriteViewController.m
//  YoutubeSearch
//
//  Created by An Nguyen on 10/31/17.
//  Copyright © 2017 An Nguyen. All rights reserved.
//

#import "YTFavoriteViewController.h"
#import "AppSession.h"
#import "YoutubeTableViewCell.h"
#import "PlaylistTableCell.h"
#import "MultimediaPlayerView.h"

@interface YTFavoriteViewController ()<UITableViewDelegate, UITableViewDataSource, YoutubeTableViewCellDelegate>
@property (weak, nonatomic) IBOutlet UITableView *favoriteTableView;
@property (weak, nonatomic) IBOutlet UITableView *playlistTableView;

@property (weak, nonatomic) IBOutlet UIView *playlistsView;

@property (weak, nonatomic) IBOutlet UILabel *playlistNameLabel;
@property (weak, nonatomic) IBOutlet UIView *listItemView;
@property (weak, nonatomic) IBOutlet UITableView *listItemTableView;
@property (nonatomic) PlaylistModel *currentPlaylist;

@end

@implementation YTFavoriteViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self initTableView];
}
- (void)setCurrentPlaylist:(PlaylistModel *)currentPlaylist{
    _currentPlaylist = currentPlaylist;
    if (_currentPlaylist) {
        self.playlistNameLabel.text = _currentPlaylist.name;
    }
}
- (void)initTableView{
    self.favoriteTableView.delegate = self;
    self.favoriteTableView.dataSource = self;
    self.favoriteTableView.separatorInset = UIEdgeInsetsZero;
    self.favoriteTableView.layoutMargins = UIEdgeInsetsZero;
    
    self.playlistTableView.delegate = self;
    self.playlistTableView.dataSource = self;
    self.playlistTableView.separatorInset = UIEdgeInsetsZero;
    
    self.listItemTableView.delegate = self;
    self.listItemTableView.dataSource = self;
    self.playlistTableView.separatorInset = UIEdgeInsetsZero;
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [self reloadAllData];
    [self hideAll];
}
- (void)hideAll{
    self.playlistsView.alpha = 0;
    self.playlistsView.hidden = true;
    self.listItemView.alpha = 0;
    self.listItemView.hidden = true;
}
- (void)reloadAllData{
    [self.playlistTableView reloadData];
    [self.listItemTableView reloadData];
    [self.favoriteTableView reloadData];
}
- (IBAction)onShowPlaylistTouched:(UIButton *)sender {
    if (self.playlistsView.hidden) {
        self.playlistsView.alpha = 0;
        self.playlistsView.hidden = false;
        [UIView animateWithDuration:0.2 animations:^{
            self.playlistsView.alpha = 1;
        }];
    }else{
        
        [UIView animateWithDuration:0.2 animations:^{
            self.playlistsView.alpha = 0;
            self.listItemView.alpha = 0;
        } completion:^(BOOL finished) {
            self.playlistsView.hidden = true;
            self.listItemView.hidden = true;
        }];
    }
}

- (IBAction)onClosePlaylistTouched:(UIButton *)sender {
    [UIView animateWithDuration:0.2 animations:^{
        self.listItemView.alpha = 0;
    } completion:^(BOOL finished) {
        self.listItemView.hidden = true;
    }];
}

#pragma mark - Table
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    if (tableView == self.favoriteTableView) {
        return [AppSession sharedInstance].favorite.datas.count;
    }
    if (tableView == self.playlistTableView) {
        return [AppSession sharedInstance].playlists.count;
    }
    if (tableView == self.listItemTableView) {
        if (self.currentPlaylist) {
            return self.currentPlaylist.datas.count;
        }
    }
    return  0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    if (tableView == self.favoriteTableView) {
        YoutubeTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell"];
        YoutubeVideoModel *data = [[AppSession sharedInstance].favorite.datas objectAtIndex:indexPath.row];
        cell.data = data;
        cell.delegate = self;
        return cell;
    }
    if (tableView == self.playlistTableView) {
        PlaylistTableCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell"];
        PlaylistModel *data = [[AppSession sharedInstance].playlists objectAtIndex:indexPath.row];
        cell.data = data;
        return cell;
    }
    if (tableView == self.listItemTableView) {
        YoutubeTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell"];
        YoutubeVideoModel *data = [self.currentPlaylist.datas objectAtIndex:indexPath.row];
        cell.data = data;
        cell.delegate = self;
        return cell;
    }
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell"];
    return cell;
}

- (void)dlgYoutubeTableViewCellPlay:(YoutubeVideoModel*)data{
    [MultimediaPlayerView sharedInstance].datasources = [AppSession sharedInstance].favorite.datas;
    [[MultimediaPlayerView sharedInstance] playAsFirstIfSuffered:data];
    [[MultimediaPlayerView sharedInstance] showFull:true];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:true];
    if (tableView == self.playlistTableView) {
        PlaylistModel *data = [[AppSession sharedInstance].playlists objectAtIndex:indexPath.row];
        self.currentPlaylist = data;
        self.listItemView.alpha = 0;
        self.listItemView.hidden = false;
        [self.listItemTableView reloadData];
        [UIView animateWithDuration:0.2 animations:^{
            self.listItemView.alpha = 1;
        }];
    }
    if (tableView == self.listItemTableView) {
        
        YoutubeVideoModel *data = [self.currentPlaylist.datas objectAtIndex:indexPath.row];
        [[AppSession sharedInstance] addFavorite:data];
        [self.favoriteTableView reloadData];
    }
}

@end
