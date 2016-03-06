//
//  CouponTableViewController.m
//  CleanBasket
//
//  Created by 이상진 on 2016. 2. 28..
//  Copyright © 2016년 WashappKorea. All rights reserved.
//

#import "CouponTableViewController.h"
#import <AFNetworking/AFNetworking.h>
#import "CouponTableViewCell.h"
#import <SVProgressHUD/SVProgressHUD.h>

@interface CouponTableViewController ()

@property (nonatomic) NSArray *coupons;

@end

@implementation CouponTableViewController


- (void)viewDidLoad{
    [super viewDidLoad];
    [self setTitle:NSLocalizedString(@"coupon", @"쿠폰")];
    
    [self getCouponData];
    
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    
    [self.navigationController setNavigationBarHidden:NO animated:NO];
}

#pragma mark - networking
- (void)getCouponData{
    
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    
    manager.responseSerializer = [AFJSONResponseSerializer serializer];
    manager.responseSerializer.acceptableContentTypes = [manager.responseSerializer.acceptableContentTypes setByAddingObject:@"text/html"];
    
    [manager GET:@"http://www.cleanbasket.co.kr/member/coupon"
        parameters:nil
           success:^(AFHTTPRequestOperation *operation, id responseObject) {
               
               NSError *jsonError;
               NSData *objectData = [responseObject[@"data"] dataUsingEncoding:NSUTF8StringEncoding];
               
               NSArray *data = [NSJSONSerialization JSONObjectWithData:objectData
                                                                    options:NSJSONReadingMutableContainers
                                                                      error:&jsonError];
               
               
               
               self.coupons = data;
               [self.tableView reloadData];
               
               
           } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
               NSLog(@"Error: %@", error);
               [SVProgressHUD showErrorWithStatus:NSLocalizedString(@"network_error",nil)];
           }];
}


#pragma mark - tableview
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return _coupons.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    CouponTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"CouponCell" forIndexPath:indexPath];
    NSDictionary *coupon = _coupons[indexPath.row];
    cell.nameLabel.text = coupon[@"name"];
    
    NSNumberFormatter *numberFormatter = [NSNumberFormatter new];
    [numberFormatter setNumberStyle:NSNumberFormatterDecimalStyle];
    
    cell.priceLabel.text = [NSString stringWithFormat:@"%@%@",[numberFormatter stringFromNumber:coupon[@"value"]],NSLocalizedString(@"monetary_unit", @"원")];
    
    if ([coupon[@"end_date"] isEqualToString:@""]) {
        cell.dateLabel.text = NSLocalizedString(@"coupon_invalidate", @"무기한");
    }
    else
        cell.dateLabel.text = coupon[@"end_date"];
    
    
    return cell;
}


- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    if (self.coupons.count) {
        
        self.tableView.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
        self.tableView.backgroundView = [UIView new];
        return 1;
        
    } else {
        
        // Display a message when the table is empty
        UILabel *messageLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width, self.view.bounds.size.height)];
        
        messageLabel.text = NSLocalizedString(@"쿠폰이 없습니다.", @"쿠폰이 없습니다.");
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
