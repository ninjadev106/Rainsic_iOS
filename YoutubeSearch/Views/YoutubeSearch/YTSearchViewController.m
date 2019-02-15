//
//  ViewController.m
//  YoutubeSearch
//
//  Created by An Nguyen on 10/27/17.
//  Copyright © 2017 An Nguyen. All rights reserved.
//
//https://www.googleapis.com/youtube/v3/search?q=pokemon&maxResults=25&part=snippet&key=AIzaSyAoJQe1YFP6ycLrlf0a-UMtW2NvPNSC8R8
//https://www.googleapis.com/youtube/v3/videos?id=hnYcZSsS77w,vNzm4vYK8E0&key=AIzaSyAoJQe1YFP6ycLrlf0a-UMtW2NvPNSC8R8&part=contentDetails


#import "YTSearchViewController.h"
#import "AINetworkRequest.h"
#import "YoutubeVideoModel.h"
#import "YoutubeTableViewCell.h"
#import <SVProgressHUD.h>
#import "UIAlertView+BlocksKit.h"
#import "UIActionSheet+BlocksKit.h"
#import "AppSession.h"
#import <ISMessages.h>
#import "MultimediaPlayerView.h"

#import "NSObject+Block.h"

@interface YTSearchViewController ()<UITableViewDelegate, UITableViewDataSource, UISearchBarDelegate, YoutubeTableViewCellDelegate>
@property (weak, nonatomic) IBOutlet UISearchBar *searchBar;
@property (weak, nonatomic) IBOutlet UITableView *tableView;

@property (nonatomic) NSMutableArray<YoutubeVideoModel*>* datasources;
@property NSInteger loadQueueCount;
@property NSInteger lastQueueIndex;
@property BOOL isLoading;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *searchIndicator;

@end

@implementation YTSearchViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self initDefault];
    UITapGestureRecognizer *tapDismis = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(tapDismissKeyboard:)];
    [self.view addGestureRecognizer:tapDismis];
    self.loadQueueCount = 0;
}
- (void)tapDismissKeyboard:(UITapGestureRecognizer*)sender{
    [self.view endEditing:true];
}
- (void)initDefault{
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.searchBar.delegate = self;
    self.searchIndicator.hidden = true;
}
- (void)finishLoading{
    self.isLoading = false;
    if (self.lastQueueIndex < self.loadQueueCount) {
        [self searchDelay:self.searchBar.text];
    }else{
        [self showIndicator:false];
    }
}
- (void)showIndicator:(BOOL)isShow{
    self.searchIndicator.hidden = !isShow;
    if (isShow) {
        [self.searchIndicator startAnimating];
    }else{
        [self.searchIndicator stopAnimating];
    }
}
- (void)searchWithString:(NSString*)searchString queueIndex:(NSInteger)queueIndex{
    
    if (self.loadQueueCount!=queueIndex || self.isLoading) {
        return;
    }
    [self showIndicator:true];
    NSLog(@"Search Queue %@ %ld",searchString,queueIndex);
    self.isLoading = true;
    self.lastQueueIndex = self.loadQueueCount;
    NSString *fullRequest = [NSString stringWithFormat:@"https://www.googleapis.com/youtube/v3/search?q=%@&maxResults=50&part=snippet,id&type=video&key=%@",searchString,GoogleAPIKey];
    
    NSLog(@"Start search: %@",searchString);
    AINetworkRequest *rq = [[AINetworkRequest alloc]init];
    rq.fullURL = fullRequest;
    rq.isPOST = false;
    __block NSInteger currentQueue = self.lastQueueIndex;
    [rq startRequestWithSuccessHandler:^(NSDictionary *data, NSString *message) {
        if (currentQueue<self.loadQueueCount) {
            [self finishLoading];
        }else{
            self.datasources = [YoutubeVideoModel createWithArray:data [@"items"]];
            [self getListDurrationURLQueueIndex:currentQueue];
        }
    } failureHandler:^(NSError *error) {
        [UIAlertView bk_showAlertViewWithTitle:@"Error" message:error.localizedDescription cancelButtonTitle:@"OK" otherButtonTitles:nil handler:nil];
        [self finishLoading];
    }];
}

- (void)setDatasources:(NSMutableArray<YoutubeVideoModel *> *)datasources{
    _datasources = datasources;
}

- (void)getListDurrationURLQueueIndex:(NSInteger)queueIndex{
    __block NSInteger currentQueue = self.lastQueueIndex;
    if (self.datasources.count==0) {
        [self finishLoading];
        return;
    }
    NSMutableArray *arr = [[NSMutableArray alloc] init];
    for (YoutubeVideoModel *item in self.datasources) {
        [arr addObject:item.videoId];
    }
    NSString *listIDs = [arr componentsJoinedByString:@","];
    NSString* fullRequest = [NSString stringWithFormat:@"https://www.googleapis.com/youtube/v3/videos?id=%@&key=%@&part=contentDetails",listIDs,GoogleAPIKey];
    
    AINetworkRequest *rq = [[AINetworkRequest alloc]init];
    rq.fullURL = fullRequest;
    rq.isPOST = false;
    [rq startRequestWithSuccessHandler:^(NSDictionary *data, NSString *message) {
        
        if (currentQueue == self.loadQueueCount) {
            NSMutableArray <YoutubeVideoModel*>* durations = [YoutubeVideoModel createWithArray:data [@"items"]];
            for (NSInteger i = 0; i < durations.count; i++) {
                YoutubeVideoModel *durationItem = [durations objectAtIndex:i];
                YoutubeVideoModel *dataItem = [self.datasources objectAtIndex:i];
                if (durationItem && dataItem) {
                    dataItem.duration = durationItem.duration;
                }
            }
            [self.tableView reloadData];
        }
        
        [self finishLoading];
    } failureHandler:^(NSError *error) {
        
        [self finishLoading];
        [UIAlertView bk_showAlertViewWithTitle:@"Error" message:error.localizedDescription cancelButtonTitle:@"OK" otherButtonTitles:nil handler:nil];
    }];
    
}

- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText{
    if (searchText.length == 0) {
        return;
    }
    [self searchDelay:searchText];
}
- (void)searchDelay:(NSString*)searchString{
    
    [self showIndicator:true];
    self.loadQueueCount++;
    
    NSInteger currentQueue = self.loadQueueCount;
    NSLog(@"searchDelay Queue %@ %ld",searchString, currentQueue);
    [self performBlock:^{
        [self searchWithString:searchString queueIndex:currentQueue];
    } afterDelay:0.5];
    
}
- (void)searchBarCancelButtonClicked:(UISearchBar *)searchBar{
    [self.view endEditing:true];
}
- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar{
    [self searchDelay:searchBar.text];
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return self.datasources.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    YoutubeTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell"];
    cell.data = [self.datasources objectAtIndex:indexPath.row];
    cell.delegate = self;
    
    return cell;
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView{
    [self.view endEditing:true];
}


- (void)dlgYoutubeTableViewCellPlay:(YoutubeVideoModel*)data{
    [MultimediaPlayerView sharedInstance].datasources = self.datasources;
    [[MultimediaPlayerView sharedInstance] playAsFirstIfSuffered:data];
    [[MultimediaPlayerView sharedInstance] showFull:true];
}

- (void)dlgYoutubeTableViewCellAdd:(YoutubeVideoModel*)data{
    
    UIActionSheet *actionSheet = [UIActionSheet bk_actionSheetWithTitle:@"Menu Action"];
    
    [actionSheet bk_addButtonWithTitle:@"Add To Playlist" handler:^{
        [AppSession sharedInstance].lastSelectVideo = data;
        [AppSession sharedInstance].rootTabBarController.selectedIndex = 2;
    }];
    
    [actionSheet bk_addButtonWithTitle:@"Add To Favorites" handler:^{
        [[AppSession sharedInstance] addFavorite:data];
    }];
    
    [actionSheet bk_setCancelButtonWithTitle:@"Cancel" handler:^{
        
    }];
    [actionSheet showInView:self.view];
}

@end
