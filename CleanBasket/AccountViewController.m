//
//  AccountViewController.m
//  CleanBasket
//
//  Created by Wonhyo Yi on 2014. 10. 3..
//  Copyright (c) 2014년 WashAppKorea. All rights reserved.
//

#import "AccountViewController.h"

@class AppDelegate;

@interface AccountViewController ()

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
    
    UILabel *myLabel = [[UILabel alloc] initWithFrame:CGRectMake(20, 20, 300, 100)];
    [myLabel setCenter:self.view.center];
    myLabel.text = @"개인설정";
    myLabel.font = [UIFont boldSystemFontOfSize:24.0f];
    [self.view addSubview:myLabel];
    
    UIButton *logoutButton = [[UIButton alloc] initWithFrame:CGRectMake(100, 100, 48, 48)];
    [logoutButton setTitle:@"Title" forState:UIControlStateNormal];
    [self.view addSubview:logoutButton];
    [logoutButton addTarget:self action:@selector(userDidLogout) forControlEvents:UIControlEventTouchUpInside];
    [logoutButton setBackgroundColor:[UIColor blackColor]];
    
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
