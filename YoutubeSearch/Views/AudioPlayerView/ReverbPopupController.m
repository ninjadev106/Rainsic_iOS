//
//  ReverbPopupController.m
//  YoutubeSearch
//
//  Created by An Nguyen on 3/23/18.
//  Copyright © 2018 An Nguyen. All rights reserved.
//

#import "ReverbPopupController.h"

@interface ReverbPopupController()<UITableViewDelegate, UITableViewDataSource>
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UIView *backView;

@property (nonatomic) NSMutableArray* datasources;

@end

@implementation ReverbPopupController

- (void)viewDidLoad{
    [super viewDidLoad];
    [self initTableView];
    [self addTapDismissToView:self.backView];
}

- (void)initTableView{
    self.datasources = [NSMutableArray new];
    [self.datasources addObject:@"None"];
    [self.datasources addObject:@"Small Room"];
    [self.datasources addObject:@"Medium Room"];
    [self.datasources addObject:@"Large Room"];
    [self.datasources addObject:@"Medium Hall"];
    [self.datasources addObject:@"Large Hall"];
    [self.datasources addObject:@"Plate"];
    [self.datasources addObject:@"Medium Chamber"];
    [self.datasources addObject:@"Large Chamber"];
    [self.datasources addObject:@"Cathedral"];
    [self.datasources addObject:@"Large Room 2"];
    [self.datasources addObject:@"Medium Hall 2"];
    [self.datasources addObject:@"Medium Hall 3"];
    [self.datasources addObject:@"Large Hall 2"];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
}



- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return self.datasources.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    UITableViewCell* cell = [tableView dequeueReusableCellWithIdentifier:@"cell" forIndexPath:indexPath];
    UILabel* label = [cell viewWithTag:110];
    NSInteger index = indexPath.row;
    label.text = [self.datasources objectAtIndex:index];
    if (index == self.reverbCode) {
        label.textColor = [UIColor redColor];
    }else{
        label.textColor = [UIColor blackColor];
    }
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    self.reverbCode = indexPath.row;
    self.reverbName = [self.datasources objectAtIndex:indexPath.row];
    [self.tableView reloadData];
    [self.delegate dlgReverbPopupControllerChanged:self];
}
@end
