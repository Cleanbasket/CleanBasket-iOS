//
//  CouponShareViewController.m
//  CleanBasket
//
//  Created by Wonhyo Yi on 2014. 10. 3..
//  Copyright (c) 2014년 WashAppKorea. All rights reserved.
//

#import "CouponShareViewController.h"

@interface CouponShareViewController ()

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
    
    UILabel *myLabel = [[UILabel alloc] initWithFrame:CGRectMake(20, 20, 300, 100)];
    [myLabel setCenter:self.view.center];
    myLabel.text = @"쿠폰&추천";
    myLabel.font = [UIFont boldSystemFontOfSize:24.0f];
    [self.view addSubview:myLabel];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
