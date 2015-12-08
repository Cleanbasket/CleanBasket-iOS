//
//  AuthCheckViewController.m
//  CleanBasket
//
//  Created by 이상진 on 2015. 12. 7..
//  Copyright © 2015년 WashappKorea. All rights reserved.
//

#import "AuthCheckViewController.h"
#import "LoginViewController.h"
#import "AppDelegate.h"
#import <AFNetworking/AFNetworking.h>

#define TEST_SERVER_URL @"http://54.183.212.215:8080/"
#define REAL_SERVER_URL @"http://www.cleanbasket.co.kr/"

@interface AuthCheckViewController ()

@end

@implementation AuthCheckViewController


- (void)viewDidLoad {
//    [self init];
    [super viewDidLoad];

    [self authCheck];



}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}




//로그인 체크 메서드
- (void)authCheck{

    if (1) {
        AppDelegate *appDelegate = [[UIApplication sharedApplication] delegate];
        [self presentViewController:appDelegate.loginVC animated:NO completion:nil];
    }
    else {

    }




}


@end
