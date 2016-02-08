//
//  OrderHistoryViewController.m
//  CleanBasket
//
//  Created by 이상진 on 2016. 2. 2..
//  Copyright © 2016년 WashappKorea. All rights reserved.
//

#import "OrderHistoryViewController.h"
#import "OrderHistoryCell.h"

#import <AFNetworking/AFNetworking.h>

@interface OrderHistoryViewController()

@property (nonatomic) NSMutableArray *orders;

@end

@implementation OrderHistoryViewController

- (void)viewDidLoad{
    [self setTitle:@"주문 내역"];
    [self.tableView setTableFooterView:[UIView new]];
    
    
    self.orders = [NSMutableArray new];
    
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
//    AFJSONResponseSerializer *responseSerializer = [AFJSONResponseSerializer serializerWithReadingOptions:NSJSONReadingAllowFragments];
        manager.responseSerializer = [AFJSONResponseSerializer serializer];
        manager.responseSerializer.acceptableContentTypes = [manager.responseSerializer.acceptableContentTypes setByAddingObject:@"text/html"];
    
    [manager GET:@"http://52.79.39.100:8080/member/order/all"
      parameters:nil
         success:^(AFHTTPRequestOperation *operation, id responseObject){
             
             NSError *jsonError;
             NSData *objectData = [responseObject[@"data"] dataUsingEncoding:NSUTF8StringEncoding];
             NSArray *orderhistory = [NSJSONSerialization JSONObjectWithData:objectData
                                                                options:NSJSONReadingMutableContainers
                                                                  error:&jsonError];
             
             
             [self.orders addObjectsFromArray:orderhistory];
             [self.tableView reloadData];

             
             if (responseObject[@"constant"]) {
                 NSLog(@"%@",responseObject);
             }
             
         } failure:^(AFHTTPRequestOperation *operation, NSError *error){
             NSLog(@"%@",error);
         }];
    
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return self.orders.count;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    OrderHistoryCell *cell = [tableView dequeueReusableCellWithIdentifier:@"OrderHistoryCell"];
    cell.pickUpTimeLabel.text = self.orders[indexPath.row][@"pickup_date"];
    cell.dropOffTimeLabel.text = self.orders[indexPath.row][@"dropoff_date"];
    cell.priceLabel.text = [NSString stringWithFormat:@"총계 %@원",[self.orders[indexPath.row][@"price"] stringValue]];
    cell.itemLabel.text = [NSString stringWithFormat:@"품목 %i개",[self.orders[indexPath.row][@"item"] count]];
    
    cell.paymentMethodLabel.text = [NSString stringWithFormat:@"%@",self.orders[indexPath.row][@"payment_method"] ? @"카드결제":@"등록카드"];
    
    return cell;
    
}


- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    if (self.orders.count) {
        
        self.tableView.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
        return 1;
        
    } else {
        
        // Display a message when the table is empty
        UILabel *messageLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width, self.view.bounds.size.height)];
        
        messageLabel.text = NSLocalizedString(@"no_history", @"주문내역없당");
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


@end
