//
//  CouponShareViewController.m
//  CleanBasket
//
//  Created by Wonhyo Yi on 2014. 10. 3..
//  Copyright (c) 2014년 WashAppKorea. All rights reserved.
//

#import "CouponShareViewController.h"

@interface CouponShareViewController () <UITableViewDelegate, UITableViewDataSource>

@end

@implementation CouponShareViewController

- (instancetype)init {
    self = [super init];
    if (self) {
        UIImage *tabBarImage = [UIImage imageNamed:@"ic_menu_coupon_01.png"];
        UIImage *selectedTabBarImage = [UIImage imageNamed:@"ic_menu_coupon_02.png"];
        self.tabBarItem = [self.tabBarItem initWithTitle:@"쿠폰추천" image:tabBarImage selectedImage:selectedTabBarImage];
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self.view setBackgroundColor:[UIColor whiteColor]];
    [self setTitle:@"보유 쿠폰"];
    couponTableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 64, DEVICE_WIDTH, COUPON_HEIGHT) style:UITableViewStylePlain];
    [couponTableView setDelegate:self];
    [couponTableView setDataSource:self];
    
    couponInsertButton = [[UIButton alloc] initWithFrame:CGRectMake(60, 64+COUPON_HEIGHT+10, 200, 38)];
    [couponInsertButton setTitle:@"쿠폰번호 입력" forState:UIControlStateNormal];
    [couponInsertButton setBackgroundColor:UltraLightGray];
    [couponInsertButton setTitleColor:CleanBasketMint forState:UIControlStateNormal];
    
    [self.view addSubview:couponInsertButton];
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
    NSString *couponName = [currentCoupon name];
    couponName = [couponName stringByAppendingString:@". "];
    couponName = [couponName stringByAppendingString:[NSString stringWithCurrencyFormat:[currentCoupon value]]];
    couponName = [couponName stringByAppendingString:@" 할인권!"];
    [cell.couponNameLabel setText:couponName];
    
    [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
    [cell setCpid:[currentCoupon cpid]];
    return cell;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    RLMArray *couponList = [Coupon allObjects];
    return [couponList count];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 172.0f;
}

@end
