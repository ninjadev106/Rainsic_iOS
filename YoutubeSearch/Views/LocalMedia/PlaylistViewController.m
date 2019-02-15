//
//  PlaylistViewController.m
//  YoutubeSearch
//
//  Created by An Nguyen on 10/31/17.
//  Copyright © 2017 An Nguyen. All rights reserved.
//

#import "PlaylistViewController.h"
#import "UIAlertView+BlocksKit.h"
#import "PlaylistModel.h"
#import "AppSession.h"
#import "PlaylistTableCell.h"
#import "UIActionSheet+BlocksKit.h"
#import <ISMessages.h>
#import "AudioTableViewCell.h"
#import "MultimediaPlayerView.h"
#import "ControllerServices.h"
#import "AppDefine.h"
#import "RootTabBarController.h"
#import "DeviceMediaModel.h"

@interface PlaylistViewController ()<UITableViewDelegate, UITableViewDataSource, PlaylistTableCellDelegate, AudioTableViewCellDelegate>
@property (weak, nonatomic) IBOutlet UITableView *playlistTableView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *newplistTop;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *plistTop;

@property (nonatomic) PlaylistModel* currentPlaylist;
@property (weak, nonatomic) IBOutlet UIButton *backSearchButton;

@property (weak, nonatomic) IBOutlet UIView *createNewBgView;

@property (weak, nonatomic) IBOutlet UILabel *playlistNameLabel;
@property (weak, nonatomic) IBOutlet UIView *listItemView;
@property (weak, nonatomic) IBOutlet UITableView *listItemTableView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *bottomCst;
@property (weak, nonatomic) IBOutlet UIView *playplistbgView;
@property (weak, nonatomic) IBOutlet UILabel *lblPlayListname;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *CreateNewbgHight;
@property (nonatomic) DeviceMediaModel *data;

@end

@implementation PlaylistViewController
@synthesize newplistTop, plistTop;

- (void)viewDidLoad {
    [super viewDidLoad];
    [self initTableView];
    if (_isNotFromRoot){
        newplistTop.constant = 0;
        plistTop.constant = 0;
    }
    
    
//    UITabBarController * tab = [[RootTabBarController alloc]init];
//    tab.tabBarItem.selectedImage =  [[UIImage imageNamed:@"favorite"]
//                                     imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
//    
//    tab.tabBarItem.image  = [[UIImage imageNamed:@"favorite"]
//                             imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
    
    self.playplistbgView.hidden = true;
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
    [self reloadData];
    self.backSearchButton.hidden = [AppSession sharedInstance].lastSelectVideo == nil;
    self.backSearchButton.hidden = true;
    
    if ([AppSession sharedInstance].lastSelectVideo) {
        self.listItemView.hidden = true;
    }
    [AppSession sharedInstance].rootTabBarController.childTab = self;
    [[AppSession sharedInstance].rootTabBarController.audioController minimizeIfNeeded];
}

- (void)viewDidDisappear:(BOOL)animated{
    [super viewDidDisappear:animated];
    [AppSession sharedInstance].lastSelectVideo = nil;
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
    [self.playlistTableView reloadData];
    [self.listItemTableView reloadData];
}

- (void)initTableView{
    
    self.playlistTableView.dataSource = self;
    self.playlistTableView.delegate = self;
    self.listItemTableView.dataSource = self;
    self.listItemTableView.delegate = self;
    self.playlistTableView.backgroundView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"bg"]];
    self.listItemTableView.backgroundView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"bg"]];


}
- (void)setCurrentPlaylist:(PlaylistModel *)currentPlaylist{
    _currentPlaylist = currentPlaylist;
    
    if (_currentPlaylist) {
        self.playlistNameLabel.text = _currentPlaylist.name;
        self.lblPlayListname.text = _currentPlaylist.name;
    }
}

- (IBAction)BtbClosePlist:(UIButton *)sender {
    [UIView animateWithDuration:0.2 animations:^{
        self.listItemView.alpha = 0;
    } completion:^(BOOL finished) {
        self.listItemView.hidden = true;
        self.playplistbgView.hidden = true;
    }];
}


- (IBAction)onClosePlaylistTouched:(UIButton *)sender {
    [UIView animateWithDuration:0.2 animations:^{
        self.listItemView.alpha = 0;
    } completion:^(BOOL finished) {
        self.listItemView.hidden = true;
        self.playplistbgView.hidden = true;
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

- (PlaylistModel*)createPlaylist:(NSString*)name{
    PlaylistModel *playlist = [[PlaylistModel alloc]init];
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
        AudioTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell"];
        cell.data = [self.currentPlaylist.datas objectAtIndex:indexPath.row];
        cell.delegate = self;
        return cell;
    }
    return nil;
}

- (void)dlgAudioTableViewCellPlay:(DeviceMediaModel*)data{
    [ControllerServices playAudio:data inList:self.currentPlaylist.datas];
}

- (void)dlgAudioTableViewCellAdd:(DeviceMediaModel*)data{
    // old action sheet
  /*  UIAlertController* alert = [UIAlertController alertControllerWithTitle:@"Action" message:nil preferredStyle:(UIAlertControllerStyleActionSheet)];
    
    UIAlertAction* cancel = [UIAlertAction actionWithTitle:@"Cancel" style:(UIAlertActionStyleCancel) handler:^(UIAlertAction * _Nonnull action) {
        
    }];
    [alert addAction:cancel];
    
    UIAlertAction* favorite = [UIAlertAction actionWithTitle:@"Add To Favorites" style:(UIAlertActionStyleDefault) handler:^(UIAlertAction * _Nonnull action) {
        [ControllerServices addToFavorite:data];
    }];
    [alert addAction:favorite];
    
    UIAlertAction* delete = [UIAlertAction actionWithTitle:@"Delete" style:(UIAlertActionStyleDefault) handler:^(UIAlertAction * _Nonnull action) {
        [ControllerServices deleteAudio:data fromPlaylist:nil];
        
    }];
    [alert addAction:delete];
    
    UIAlertAction* share = [UIAlertAction actionWithTitle:@"Share" style:(UIAlertActionStyleDefault) handler:^(UIAlertAction * _Nonnull action) {
        [ControllerServices shareAudio:data];
        
    }];
    [alert addAction:share];
    
    [self presentViewController:alert animated:true completion:nil];*/
    // old action sheet
    
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:nil
                                                                             message:nil
                                                                      preferredStyle:UIAlertControllerStyleActionSheet];
    
    UIAlertAction *AddToFavorites = [UIAlertAction
                                     actionWithTitle:@"Add To Favorites"
                                     style:UIAlertActionStyleDefault
                                     handler:^(UIAlertAction *action){
                                         NSLog(@"Add To Favorites");
                                        [ControllerServices addToFavorite:data];
                                         
                                     }];
    [alertController addAction:AddToFavorites];
    
    
    UIAlertAction *RenamePlaylist = [UIAlertAction
                                     actionWithTitle:@"Rename Playlist"
                                     style:UIAlertActionStyleDefault
                                     handler:^(UIAlertAction *action){
                                         NSLog(@"Rename Playlist");
                                         self.data = data;
                                         [self renameCurrentPlaylistDetail];
                                         
                                     }];
    [alertController addAction:RenamePlaylist];
    
    UIAlertAction *Delete = [UIAlertAction
                                     actionWithTitle:@"Delete"
                                     style:UIAlertActionStyleDefault
                                     handler:^(UIAlertAction *action) {
                                         NSLog(@"Delete ");
                                        self.data = data;
                                        [self deleteCurrentPlaylistAudio];
                                      // [ControllerServices deleteAudio:data fromPlaylist:nil];
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
        
        if ([AppSession sharedInstance].lastSelectVideo) {
            [[AppSession sharedInstance].lastSelectVideo renameDocumentToUniqueIfNeeded];
            PlaylistModel *playlist = [[AppSession sharedInstance].playlists objectAtIndex:indexPath.row];
            [playlist addObject:[AppSession sharedInstance].lastSelectVideo];
            [AppSession sharedInstance].lastSelectVideo = nil;
            [[AppSession sharedInstance] save];
            
            [[NSNotificationCenter defaultCenter]
             postNotificationName:ChangeDataNotification
             object:nil];
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
            self.createNewBgView.hidden = true;
            self.playplistbgView.hidden = false;
             self.CreateNewbgHight.constant = 0;
            [self.listItemTableView reloadData];
            [UIView animateWithDuration:0.2 animations:^{
                self.listItemView.alpha = 1;
                
            }];
        }
    }
    
}


- (void)dlgPlaylistTableCellSelect:(PlaylistModel*)data{
    // old action sheet
  /*  UIActionSheet *actionSheet = [UIActionSheet bk_actionSheetWithTitle:@"Menu Action"];
    
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
    [actionSheet showInView:self.view];*/
    // old action sheet
    
    
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:nil
                                                                             message:nil
                                                                      preferredStyle:UIAlertControllerStyleActionSheet];
    
    UIAlertAction *RenamePlaylist = [UIAlertAction
                                    actionWithTitle:@"Rename Playlist"
                                    style:UIAlertActionStyleDefault
                                    handler:^(UIAlertAction *action){
                                        NSLog(@"Rename Playlist");
                                        self.currentPlaylist = data;
                                        [self renameCurrentPlaylist];
                                        
                                    }];
    [alertController addAction:RenamePlaylist];
    
    
    UIAlertAction *DeletePlaylist = [UIAlertAction
                             actionWithTitle:@"Delete Playlist"
                             style:UIAlertActionStyleDefault
                             handler:^(UIAlertAction *action) {
                                 NSLog(@"Delete Playlist");
                                 self.currentPlaylist = data;
                                 [self deleteCurrentPlaylist];
                             }];
    [alertController addAction:DeletePlaylist];
    
  
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


- (void)deleteCurrentPlaylistAudio{
    
    UIAlertView *confirmView = [UIAlertView bk_alertViewWithTitle:nil message:@"Are your sure?"];
    [confirmView bk_addButtonWithTitle:@"No" handler:^{
    }];
    [confirmView bk_addButtonWithTitle:@"Yes" handler:^{
        [self.currentPlaylist.datas removeObject:self.data];
        [self.listItemTableView reloadData];
        [[AppSession sharedInstance] save];
        
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
         NSLog(@"self.currentPlaylist %@",self.currentPlaylist);
        self.currentPlaylist.name = namefield.text;
        [[AppSession sharedInstance] save];
        [self.playlistTableView reloadData];
        
    }]];
    [self presentViewController:alertController animated:YES completion:nil];
}
    
- (void)renameCurrentPlaylistDetail{
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
        NSLog(@"self.data %@",self.data.localName);
        self.data.localName = namefield.text;
        //[[AppSession sharedInstance] save];
        [[AppSession sharedInstance] save];
        [self.listItemTableView reloadData];
        
    }]];
    [self presentViewController:alertController animated:YES completion:nil];
}

@end
