//
//  AddAddressTableViewController.m
//  CleanBasket
//
//  Created by 이상진 on 2016. 1. 5..
//  Copyright © 2016년 WashappKorea. All rights reserved.
//

#import "AddAddressTableViewController.h"

@interface AddAddressTableViewController ()

@property UISearchController *searchController;
@property UITableViewController *resultController;
@property NSMutableArray *datas;
@property NSArray *numbers;

@end

@implementation AddAddressTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];


    _numbers = @[@"1",@"2",@"3"];

    _searchController = [[UISearchController alloc]initWithSearchResultsController:_resultController];

    self.tableView.tableHeaderView = _searchController.searchBar;

    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;

    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return _numbers.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [UITableViewCell new];

    cell.textLabel.text = _numbers[indexPath.row];

    return cell;
}




@end
