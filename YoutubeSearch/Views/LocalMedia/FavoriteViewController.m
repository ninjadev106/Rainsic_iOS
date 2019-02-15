//
//  FavoriteViewController.m
//  YoutubeSearch
//
//  Created by An Nguyen on 10/31/17.
//  Copyright © 2017 An Nguyen. All rights reserved.
//

#import "FavoriteViewController.h"
#import "AppSession.h"
#import "AudioTableViewCell.h"
#import "PlaylistTableCell.h"
#import "MultimediaPlayerView.h"
#import "ControllerServices.h"
#import "AppDefine.h"
#import "RootTabBarController.h"
#import "DeviceMediaModel.h"

@interface FavoriteViewController ()<UITableViewDelegate, UITableViewDataSource, AudioTableViewCellDelegate>
@property (weak, nonatomic) IBOutlet UITableView *favoriteTableView;
@property (weak, nonatomic) IBOutlet UITableView *playlistTableView;

@property (weak, nonatomic) IBOutlet UIView *playlistsView;

@property (weak, nonatomic) IBOutlet UILabel *playlistNameLabel;
@property (weak, nonatomic) IBOutlet UIView *listItemView;
@property (weak, nonatomic) IBOutlet UITableView *listItemTableView;
@property (nonatomic) PlaylistModel *currentPlaylist;
@property (nonatomic) DeviceMediaModel *data;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *bottomCst;
@end

@implementation FavoriteViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self initTableView];
//    UITabBarController * tab = [[RootTabBarController alloc]init];
//    tab.tabBarItem.selectedImage =  [[UIImage imageNamed:@"favorite"]
//                                     imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
//    
//    tab.tabBarItem.image  = [[UIImage imageNamed:@"favorite"]
//                             imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(playerAppearNotificationListener:)
                                                 name:PlayerAppearNotification
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(changDataNotificationListener:)
                                                 name:ChangeDataNotification
                                               object:nil];
    
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [AppSession sharedInstance].rootTabBarController.childTab = self;
    [[AppSession sharedInstance].rootTabBarController.audioController minimizeIfNeeded];
    [self reloadData];
    [self hideAll];
}

- (void)playerAppearNotificationListener:(NSNotification *) notification
{
    if ([[notification name] isEqualToString:PlayerAppearNotification]){
        
        BOOL isNeedSpace = [notification.object boolValue];
        self.bottomCst.constant = isNeedSpace?120:0;
    }
}

- (void)changDataNotificationListener:(NSNotification *) notification{
    if ([[notification name] isEqualToString:ChangeDataNotification]){
        [self reloadData];
    }
}

- (void)reloadData{
    [self.favoriteTableView reloadData];
    [self.playlistTableView reloadData];
    [self.listItemTableView reloadData];
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
    self.favoriteTableView.backgroundView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"bg"]];
    
    self.playlistTableView.delegate = self;
    self.playlistTableView.dataSource = self;
    self.playlistTableView.separatorInset = UIEdgeInsetsZero;
    self.playlistTableView.backgroundView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"bg"]];
    
    self.listItemTableView.delegate = self;
    self.listItemTableView.dataSource = self;
    self.playlistTableView.separatorInset = UIEdgeInsetsZero;
    self.listItemTableView.backgroundView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"bg"]];
    
    
}

- (void)hideAll{
    self.playlistsView.alpha = 0;
    self.playlistsView.hidden = true;
    self.listItemView.alpha = 0;
    self.listItemView.hidden = true;
}
- (IBAction)onShowPlaylistTouched:(UIButton *)sender {
    [AppSession sharedInstance].rootTabBarController.selectedIndex = 2;
//    if (self.playlistsView.hidden) {
//        self.playlistsView.alpha = 0;
//        self.playlistsView.hidden = false;
//        [UIView animateWithDuration:0.2 animations:^{
//            self.playlistsView.alpha = 1;
//        }];
//    }else{
//
//        [UIView animateWithDuration:0.2 animations:^{
//            self.playlistsView.alpha = 0;
//            self.listItemView.alpha = 0;
//        } completion:^(BOOL finished) {
//            self.playlistsView.hidden = true;
//            self.listItemView.hidden = true;
//        }];
//    }
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
        AudioTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell"];
        DeviceMediaModel *data = [[AppSession sharedInstance].favorite.datas objectAtIndex:indexPath.row];
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
        AudioTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell"];
        DeviceMediaModel *data = [self.currentPlaylist.datas objectAtIndex:indexPath.row];
        cell.data = data;
        cell.delegate = self;
        return cell;
    }
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell"];
    return cell;
}

- (void)dlgAudioTableViewCellPlay:(DeviceMediaModel*)data{
    [ControllerServices playAudio:data inList:[AppSession sharedInstance].favorite.datas];
}

- (void)dlgAudioTableViewCellAdd:(DeviceMediaModel*)data{
    // OLD ACTION SHEET
   /* UIAlertController* alert = [UIAlertController alertControllerWithTitle:@"Action" message:nil preferredStyle:(UIAlertControllerStyleActionSheet)];
    
    UIAlertAction* cancel = [UIAlertAction actionWithTitle:@"Cancel" style:(UIAlertActionStyleCancel) handler:^(UIAlertAction * _Nonnull action) {
        
    }];
    [alert addAction:cancel];
    
    
    UIAlertAction* playlist = [UIAlertAction actionWithTitle:@"Add To Playlist" style:(UIAlertActionStyleDefault) handler:^(UIAlertAction * _Nonnull action) {
        [ControllerServices addToPlaylist:data];
        
    }];
    [alert addAction:playlist];
    
    UIAlertAction* delete = [UIAlertAction actionWithTitle:@"Delete" style:(UIAlertActionStyleDefault) handler:^(UIAlertAction * _Nonnull action) {
        [ControllerServices deleteAudio:data fromPlaylist:nil];
        
    }];
    [alert addAction:delete];
    
    
    UIAlertAction* share = [UIAlertAction actionWithTitle:@"Share" style:(UIAlertActionStyleDefault) handler:^(UIAlertAction * _Nonnull action) {
        [ControllerServices shareAudio:data];
        
    }];
    [alert addAction:share];
    
    [self presentViewController:alert animated:true completion:nil];*/
    //OLD Action sheet
    
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:nil
                                                                             message:nil
                                                                      preferredStyle:UIAlertControllerStyleActionSheet];
    
    UIAlertAction *addToPlaylist = [UIAlertAction
                                    actionWithTitle:@"Add To Playlist"
                                    style:UIAlertActionStyleDefault
                                    handler:^(UIAlertAction *action){
                                        NSLog(@"Add To Playlist");
                                        [ControllerServices addToPlaylist:data];
                                        
                                    }];
    [alertController addAction:addToPlaylist];
    
    
    UIAlertAction *RenameFavorite = [UIAlertAction
                                     actionWithTitle:@"Rename Favorite"
                                     style:UIAlertActionStyleDefault
                                     handler:^(UIAlertAction *action){
                                         self.data = data;
                                        // [ControllerServices renameFavorite:data];
                                         [self renameFavoriteList];
                                         
                                     }];
    [alertController addAction:RenameFavorite];
    
    UIAlertAction *Delete = [UIAlertAction
                                     actionWithTitle:@"Delete"
                                     style:UIAlertActionStyleDefault
                                     handler:^(UIAlertAction *action) {
                                         NSLog(@"Delete");
                                       [ControllerServices deleteAudio:data fromPlaylist:nil];
                                     }];
    [alertController addAction:Delete];
    
    UIAlertAction *Share = [UIAlertAction
                                      actionWithTitle:@"Share"
                                      style:UIAlertActionStyleDefault
                                      handler:^(UIAlertAction *action) {
                                          NSLog(@"Share");
                                    [ControllerServices shareAudio:data];
                                          
                                      }];
    [alertController addAction:Share];
    
    
    UIAlertAction *Cancel = [UIAlertAction
                            actionWithTitle:@"Cancel"
                            style:UIAlertActionStyleDefault
                            handler:^(UIAlertAction *action) {
                                NSLog(@"Cancel");
                                
                            }];
    [alertController addAction:Cancel];
    
    
    alertController.view.tintColor = [UIColor whiteColor];
    UIView *subView = alertController.view.subviews.firstObject;
    
    UIView *alertContentView = subView.subviews.firstObject;
    for (UIView *subSubView in alertContentView.subviews) {
        subSubView.backgroundColor = [UIColor colorWithRed:83/255.0f green:133/255.0f blue:140/255.0f alpha:1.0f];
    }
    alertContentView.layer.cornerRadius = 5;
    [self presentViewController:alertController animated:YES completion:nil];
    
    
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
        
        DeviceMediaModel *data = [self.currentPlaylist.datas objectAtIndex:indexPath.row];
        [[AppSession sharedInstance] addFavorite:data];
        [self.favoriteTableView reloadData];
    }
}

- (void)renameFavoriteList{
    UIAlertController * alertController = [UIAlertController alertControllerWithTitle: nil
                                                                              message: @"Rename Favorite"
                                                                       preferredStyle:UIAlertControllerStyleAlert];
    [alertController addTextFieldWithConfigurationHandler:^(UITextField *textField) {
    }];
    [alertController addAction:[UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        
    }]];
    [alertController addAction:[UIAlertAction actionWithTitle:@"Rename" style:UIAlertActionStyleCancel handler:^(UIAlertAction *action) {
        NSArray * textfields = alertController.textFields;
        UITextField * namefield = textfields[0];
        self.data.localName = namefield.text;
        [[AppSession sharedInstance] save];
        [self.favoriteTableView reloadData];
        
    }]];
    [self presentViewController:alertController animated:YES completion:nil];
}

@end
