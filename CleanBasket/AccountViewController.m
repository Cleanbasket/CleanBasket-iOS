//
//  AccountViewController.m
//  CleanBasket
//
//  Created by Wonhyo Yi on 2014. 10. 3..
//  Copyright (c) 2014년 WashAppKorea. All rights reserved.
//

#import "AccountViewController.h"
#import <Realm/Realm.h>
#import "AFNetworking.h"
#import "User.h"
#import "Order.h"
#define X_FIRST 10
#define X_SECOND 80
#define X_CENTER_DEVICE (DEVICE_WIDTH - WIDTH_REGULAR)/2
#define Y_FIRST 89
#define WIDTH_REGULAR 300
#define WIDTH_SMALL 60
#define WIDTH_LARGE 230
#define WIDTH_FULL 300
#define HEIGHT_REGULAR 35
#define MARGIN_REGULAR 60

@class AppDelegate;

@interface AccountViewController ()
{
    AFHTTPRequestOperationManager *manager;
    RLMRealm *realm;
    UILabel *personalLabel;
    UILabel *emailLabel;
    UILabel *emailValueLabel;
    UILabel *contactLabel;
    UILabel *contactValueLabel;
    UILabel *passwordLabel;
    UIButton *passwordChangeButton;
    UILabel *pushNotiLabel;
}

@end

@implementation AccountViewController

- (instancetype)init {
    self = [super init];
    if (self) {
        UIImage *tabBarImage = [UIImage imageNamed:@"tab_account.png"];
        self.tabBarItem = [self.tabBarItem initWithTitle:@"개인설정" image:tabBarImage selectedImage:tabBarImage];
        manager = [AFHTTPRequestOperationManager manager];
    }
    
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self.view setBackgroundColor:[UIColor whiteColor]];
    
    
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void) userDidLogout {
    manager.requestSerializer = [AFJSONRequestSerializer serializer];
    [manager POST:@"http://cleanbasket.co.kr/logout" parameters:@{} success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSArray *cookies = [[NSHTTPCookieStorage sharedHTTPCookieStorage] cookiesForURL: [NSURL URLWithString:@"http://cleanbasket.co.kr/"]];
        for (NSHTTPCookie *cookie in cookies)
        {
            [[NSHTTPCookieStorage sharedHTTPCookieStorage] deleteCookie:cookie];
        }
        [self.tabBarController.moreNavigationController popToRootViewControllerAnimated:NO];
        
        realm = [RLMRealm defaultRealm];
        [realm beginWriteTransaction];
        [realm deleteObjects:[Order allObjects]];
        [realm deleteObjects:[User allObjects]];
        [realm commitWriteTransaction];
        NSError *error;
        [[NSFileManager defaultManager] removeItemAtPath:[RLMRealm defaultRealmPath] error:&error];
        if (error) NSLog(@"%@", error);
        
        //AppDelegate에 사용자가 로그아웃했음을 알림.
        [[NSNotificationCenter defaultCenter] postNotificationName:@"userDidLogout" object:self];
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"%@", error);
    }];
}

@end
