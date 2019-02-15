//
//  RootTabBarController.m
//  YoutubeSearch
//
//  Created by An Nguyen on 10/31/17.
//  Copyright © 2017 An Nguyen. All rights reserved.
//

#import "RootTabBarController.h"
#import "AppSession.h"
#import "AppDefine.h"
#import "DeviceMediaModel.h"
#import "AudioTableViewCell.h"
#import "ControllerServices.h"
#import "UIAlertView+BlocksKit.h"
#import "UIActionSheet+BlocksKit.h"

@interface RootTabBarController ()<AudioEQControllerDelegate, UISearchBarDelegate, UITableViewDelegate, UITableViewDataSource, AudioTableViewCellDelegate, AudioPlayerControllerDelegate>
@property UISearchBar* searchBar;
@property UITabBar * tabbar;
@property (strong, nonatomic) IBOutlet UITableView *tableView;
@property (nonatomic) NSMutableArray<DeviceMediaModel*>* datasources;
@end

@implementation RootTabBarController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self initSearchBar];
    [self initTableView];
    [self updateTableBottom:0];
    [self initKeyboardListener];
    [AppSession sharedInstance].rootTabBarController = self;
}

- (void)viewDidAppear:(BOOL)animated{
    [self initEQPlayer];
    [self.view addSubview:self.tableView];
    self.tableView.hidden = true;
    
}

//- (void)viewDidDisappear:(BOOL)animated{
//    [super viewDidDisappear:animated];
//    [AppSession sharedInstance].rootTabBarController = nil;
//}

- (void)initTableView{
    self.datasources = [NSMutableArray new];
    self.tableView.delegate =self;
    self.tableView.dataSource =self;
    self.tableView.backgroundView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"bg"]];
}

- (void)initEQPlayer{
    if (self.audioController) {
        return;
    }
    self.audioController = [[UIStoryboard storyboardWithName:@"Main" bundle:nil]
                            instantiateViewControllerWithIdentifier:@"AudioPlayerController"];
    self.audioController.delegate = self;
    
    [self addChildViewController:self.audioController];
    self.audioController.view.frame = [self.audioController frameOfFloatMode:true];
    self.audioController.view.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    [self.view addSubview:self.audioController.view];
    self.audioController.view.alpha = 0;
  
    
    
}


- (void)initSearchBar{
   

    self.searchBar = [[UISearchBar alloc]initWithFrame:CGRectMake(0, 60, [UIScreen mainScreen].bounds.size.width, 60)];
   // self.searchBar.tintColor = [UIColor redColor];
    self.searchBar.barTintColor =[UIColor colorWithRed:(10.0 / 255.0) green:(81.0 / 255.0) blue:(92.0 / 255.0) alpha: 1];
    [self.view addSubview:self.searchBar];
//    [[UIBarButtonItem appearanceWhenContainedIn:[UISearchBar class], nil]
//     setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys:[UIColor colorWithRed:(10.0 / 255.0) green:(81.0 / 255.0) blue:(92.0 / 255.0) alpha: 1], NSForegroundColorAttributeName, nil]
//     forState:UIControlStateNormal];
    [[UIBarButtonItem appearanceWhenContainedIn:[UISearchBar class], nil]
     setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys:[UIColor whiteColor], NSForegroundColorAttributeName, nil]
     forState:UIControlStateNormal];
    UITextField *searchField = [self.searchBar valueForKey:@"searchField"];
    [self.searchBar setPlaceholder:@"Search"];
   
     searchField.textColor = [UIColor grayColor];
//0A515C
    self.searchBar.delegate = self;
}
- (BOOL)searchBarShouldBeginEditing:(UISearchBar *)searchBar{
    self.tableView.hidden = false;
    [self.searchBar setShowsCancelButton:true animated:true];
    return true;
}

- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText{
    self.datasources = [[AppSession sharedInstance] searchSong:[searchText lowercaseString]];
    [self.tableView reloadData];
}

- (void)searchBarCancelButtonClicked:(UISearchBar *)searchBar{
    [self endSearch];
}

- (void)endSearch{
    [self.searchBar endEditing:true];
    [self.searchBar setShowsCancelButton:false animated:true];
    self.tableView.hidden = true;
//    self.searchBar.text = @"";
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return self.datasources.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    AudioTableViewCell* cell = [tableView dequeueReusableCellWithIdentifier:@"cell" forIndexPath:indexPath];
    cell.data = [self.datasources objectAtIndex:indexPath.row];
    cell.delegate = self;
    return cell;
}

- (void)dlgAudioTableViewCellPlay:(DeviceMediaModel*)data{
    [ControllerServices playAudio:data inList:self.datasources];
    [self endSearch];
}

- (void)dlgAudioTableViewCellAdd:(DeviceMediaModel*)data{
    [self.searchBar endEditing:true];
    // OLD ACTION SHEET
   /* UIActionSheet *actionSheet = [UIActionSheet bk_actionSheetWithTitle:@"Menu Action"];
    
    [actionSheet bk_addButtonWithTitle:@"Add To Playlist" handler:^{
        [self endSearch];
        [AppSession sharedInstance].lastSelectVideo = data;
        [AppSession sharedInstance].rootTabBarController.selectedIndex = 2;
    }];
    
    [actionSheet bk_addButtonWithTitle:@"Add To Favorites" handler:^{
        [[AppSession sharedInstance] addFavorite:data];
    }];
    
    [actionSheet bk_setCancelButtonWithTitle:@"Cancel" handler:^{
        
    }];
    [actionSheet showInView:self.view];*/
     // OLD ACTION SHEET
    
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:nil
                                                                             message:nil
                                                                      preferredStyle:UIAlertControllerStyleActionSheet];
    
    UIAlertAction *addToPlaylist = [UIAlertAction
                                    actionWithTitle:@"Add To Playlist"
                                    style:UIAlertActionStyleDefault
                                    handler:^(UIAlertAction *action){
                                        NSLog(@"Add To Playlist");
                            [self endSearch];
                            [AppSession sharedInstance].lastSelectVideo = data;
                            [AppSession sharedInstance].rootTabBarController.selectedIndex = 2;
                                        
                                    }];
    [alertController addAction:addToPlaylist];
    
    
    UIAlertAction *AddToFavorites = [UIAlertAction
                             actionWithTitle:@"Add To Favorites"
                             style:UIAlertActionStyleDefault
                             handler:^(UIAlertAction *action) {
                                 NSLog(@"Add To Favorites");
                              [[AppSession sharedInstance] addFavorite:data];
                             }];
    [alertController addAction:AddToFavorites];
    
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


- (void)dlgAudioPlayerControllerSwitchFloatMode:(BOOL)floatMode{
    [[NSNotificationCenter defaultCenter]
     postNotificationName:PlayerAppearNotification
     object:@(floatMode)];
}

#pragma mark - Keyboard
- (void)initKeyboardListener{
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardDidShow:)
                                                 name:UIKeyboardDidShowNotification
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardDidHide:)
                                                 name:UIKeyboardDidHideNotification
                                               object:nil];
}
- (void)removeKeyboardListener{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardDidShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardDidHideNotification object:nil];
}


- (void)keyboardDidShow:(NSNotification *)notification {
    NSDictionary* keyboardInfo = [notification userInfo];
    NSValue* keyboardFrameBegin = [keyboardInfo valueForKey:UIKeyboardFrameEndUserInfoKey];
    CGRect keyboardFrameBeginRect = [keyboardFrameBegin CGRectValue];
    [self updateTableBottom:keyboardFrameBeginRect.size.height];
}

- (void)keyboardDidHide:(NSNotification *)notification {
    [self updateTableBottom:0];
}

- (void)updateTableBottom:(CGFloat)bottom{
    CGRect frame = self.view.bounds;
    CGFloat topHeight = 120;
    frame.origin.y += topHeight;
    frame.size.height -= (topHeight + bottom);
    self.tableView.frame = frame;
}
@end
