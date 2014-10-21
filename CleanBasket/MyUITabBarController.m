//
//  MyUITabBarController.m
//  CleanBasket
//
//  Created by Wonhyo Yi on 2014. 10. 3..
//  Copyright (c) 2014년 WashAppKorea. All rights reserved.
//

#import "MyUITabBarController.h"

@interface MyUITabBarController () <UINavigationControllerDelegate>

@end

@implementation MyUITabBarController

- (instancetype)init {
    self = [super init];
    if (self) {
        UILabel *moreTitleView = [[UILabel alloc] init];
        [moreTitleView setText:@"더 보기"];
    }
    
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self.navigationController setNavigationBarHidden:NO];
    [self.navigationItem setTitle:@"주문하기"];
    
//    //로그아웃 버튼 생성
//    UIBarButtonItem *rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"로그아웃" style:UIBarButtonItemStylePlain target:self action:@selector(logoutButtonDidTap)];
//    [self.navigationItem setRightBarButtonItem:rightBarButtonItem];
    
    //create a custom view for the tab bar
    CGRect frame = CGRectMake(0.0, 0.0, self.view.bounds.size.width, 49);
    UIView *v = [[UIView alloc] initWithFrame:frame];
    [v setBackgroundColor:UltraLightGray];
    [[self tabBar] addSubview:v];
    [v.layer setBorderWidth:0];
    
    //set the tab bar title appearance for normal state
    [[UITabBarItem appearance]
     setTitleTextAttributes:@{UITextAttributeTextColor : [UIColor lightGrayColor],
                              UITextAttributeFont:[UIFont systemFontOfSize:14.0f]}
     forState:UIControlStateNormal];
    
    //set the tab bar title appearance for selected state
    [[UITabBarItem appearance]
     setTitleTextAttributes:@{ UITextAttributeTextColor : CleanBasketMint,
                               UITextAttributeFont:[UIFont systemFontOfSize:14.0f]}
     forState:UIControlStateSelected];
    
    [self.tabBar setTintColor:CleanBasketMint];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)tabBar:(UITabBar *)tabBar didSelectItem:(UITabBarItem *)item {
    if (item.title == nil) {
        [self.navigationController setNavigationBarHidden:YES];
        [self.moreNavigationController.navigationItem setTitle:@"더 보기"];
    } else {
        [self.navigationItem setTitle:item.title];
        [self.navigationController setNavigationBarHidden:NO];
    }
    
    if ( [item.title isEqualToString:@"진행상태" ]) {
        UIBarButtonItem *leftBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"주문내역" style:UIBarButtonItemStylePlain target:self action:@selector(orderBarButtonDidTap)];
        [self.navigationItem setLeftBarButtonItem:leftBarButtonItem];
    } else {
        [self.navigationItem setLeftBarButtonItem:nil];
    }
}

- (void)dealloc {
    NSLog(@"tabbar dealloc");
}

- (void) orderBarButtonDidTap {
    OrderDetailViewController *orderDetailViewController = [[OrderDetailViewController alloc] init];
    [self.navigationController pushViewController:orderDetailViewController animated:YES];
}

@end
