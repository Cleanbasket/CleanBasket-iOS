//
//  ItemListViewController.m
//  CleanBasket
//
//  Created by 이상진 on 2016. 3. 6..
//  Copyright © 2016년 WashappKorea. All rights reserved.
//

#import "ItemListViewController.h"
#import "ItemListTableViewCell.h"

@interface ItemListViewController ()<UITableViewDataSource,UITableViewDelegate>

@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (strong, nonatomic) NSNumberFormatter *numberFormatter;

@end

@implementation ItemListViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    _numberFormatter = [NSNumberFormatter new];
    _numberFormatter.numberStyle = NSNumberFormatterDecimalStyle;
    _tableView.tableFooterView = [UIView new];
    [self setTitle:NSLocalizedString(@"label_item", @"품목")];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}



#pragma mark - tableview
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
    if (_items.count) {
        
        self.tableView.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
        self.tableView.backgroundView = [UIView new];
        return 1;
        
    } else {
        
        // Display a message when the table is empty
        UILabel *messageLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width, self.view.bounds.size.height)];
        
        messageLabel.text = NSLocalizedString(@"품목이 없습니다.", @"품목이 없습니다.");
        messageLabel.textColor = [UIColor blackColor];
        messageLabel.numberOfLines = 0;
        messageLabel.textAlignment = NSTextAlignmentCenter;
        messageLabel.font = [UIFont systemFontOfSize:20 weight:UIFontWeightUltraLight];
        [messageLabel sizeToFit];
        
        self.tableView.backgroundView = messageLabel;
        self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        
    }
    
    return 0;
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return _items.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    

    ItemListTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"ItemListTableViewCell"];
    cell.itemNameLabel.text = _items[indexPath.row][@"name"];
    
    NSString *itemPriceString =  [NSString stringWithFormat:@"%@%@",[_numberFormatter stringFromNumber:_items[indexPath.row][@"price"]],NSLocalizedString(@"monetary_unit",@"원")];
    cell.itemPriceLabel.text = itemPriceString;
    
    
    NSString *itemCountString =  [NSString stringWithFormat:@"%@%@",[_numberFormatter stringFromNumber:_items[indexPath.row][@"count"]],NSLocalizedString(@"item_unit",@"개")];
    cell.itemCountLabel.text = itemCountString;
    
    return cell;
}

@end
