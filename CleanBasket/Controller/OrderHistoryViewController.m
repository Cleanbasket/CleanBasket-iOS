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
    
    [manager GET:@"http://www.cleanbasket.co.kr/member/order/all"
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
    cell.orderNumberLabel.text = [NSString stringWithFormat:@"%@ %@",NSLocalizedString(@"order_number", @"주문번호"),self.orders[indexPath.row][@"order_number"]];
    
    switch ([self.orders[indexPath.row][@"state"] integerValue]) {
        case 0:
            cell.orderStatusLabel.text = NSLocalizedString(@"pick_up_wait", @"수거대기");
            break;
        case 1:
            cell.orderStatusLabel.text = NSLocalizedString(@"pick_up_man_selected", @"수거예정");
            break;
        case 2:
            cell.orderStatusLabel.text = NSLocalizedString(@"pick_up_finish", @"세탁중");
            break;
        case 3:
            cell.orderStatusLabel.text = NSLocalizedString(@"deliverer_selected", @"배달예정");
            break;
        case 4:
            cell.orderStatusLabel.text = NSLocalizedString(@"deliverer_finish", @"배달완료");
            break;
            
        default:
            break;
    }
    
    
    NSInteger itemCount = 0;
    
    for (NSDictionary *item in self.orders[indexPath.row][@"item"]) {
        itemCount += [item[@"count"] integerValue];
    }
    
    cell.itemLabel.text = [NSString stringWithFormat:@"품목 %zd개",itemCount];
    
    cell.paymentMethodLabel.text = [NSString stringWithFormat:@"%@",self.orders[indexPath.row][@"payment_method"] ? @"카드결제":@"등록카드"];
    
    return cell;
    
}


- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    if (self.orders.count) {
        
        self.tableView.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
        self.tableView.backgroundView = [UIView new];
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
