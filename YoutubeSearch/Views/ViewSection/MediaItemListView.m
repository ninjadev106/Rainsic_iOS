//
//  MediaItemListView.m
//  YoutubeSearch
//
//  Created by An Nguyen on 12/25/17.
//  Copyright © 2017 An Nguyen. All rights reserved.
//

#import "MediaItemListView.h"
#import "YoutubeTableViewCell.h"

@interface MediaItemListView()<UITableViewDelegate, UITableViewDataSource>
@property (weak, nonatomic) IBOutlet UITableView *tableView;

@end

@implementation MediaItemListView

- (void)initCustom{
    [self initTableView];
}

- (void)initTableView{
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    [self.tableView registerNib:[UINib nibWithNibName:@"YoutubeTableViewCell" bundle:nil] forCellReuseIdentifier:@"yCell"];
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    YoutubeTableViewCell* cell = [tableView dequeueReusableCellWithIdentifier:@"yCell" forIndexPath:indexPath];
    return cell;
}

@end
