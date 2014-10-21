//
//  CouponListViewController.m
//  CleanBasket
//
//  Created by Wonhyo Yi on 2014. 10. 21..
//  Copyright (c) 2014년 WashAppKorea. All rights reserved.
//

#import "CouponListViewController.h"

@interface CouponListViewController () <UITableViewDataSource, UITableViewDelegate>

@end

@implementation CouponListViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self.view setBackgroundColor:[UIColor whiteColor]];
    [self setTitle:@"보유 쿠폰"];
    couponTableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, DEVICE_WIDTH, DEVICE_HEIGHT) style:UITableViewStylePlain];
    [couponTableView setDelegate:self];
    [couponTableView setDataSource:self];
    [couponTableView.layer setBorderWidth:1.0f];
    [couponTableView.layer setBorderColor:[UIColor redColor].CGColor];
    
    [self.view addSubview:couponTableView];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *CellIdentifier = @"couponCell";
    int couponIndex = [indexPath row];
    RLMArray *couponList = [Coupon allObjects];
    Coupon *currentCoupon = [couponList objectAtIndex:couponIndex];
    
    CBCouponTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    if (cell == nil) {
        
        cell = [[CBCouponTableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier];
    }
    [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
    [cell.couponNameLabel setText:[currentCoupon name]];
    [cell setCpid:[currentCoupon cpid]];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    RLMArray *couponList = [Coupon allObjects];
    if ([couponList count] > 0 && [couponList objectAtIndex:[indexPath row]]) {
        Coupon *selectedCoupon = [couponList objectAtIndex:[indexPath row]];
        [self.delegate setViewController:self currentCoupon:selectedCoupon];
        [self.navigationController popViewControllerAnimated:YES];
    }
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    RLMArray *couponList = [Coupon allObjects];
    return [couponList count];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 172.0f;
}

@end
