//
//  AppDelegate.m
//  CleanBasket
//
//  Created by 이상진 on 2015. 12. 7..
//  Copyright © 2015년 WashappKorea. All rights reserved.
//

#import "AppDelegate.h"
#import "LoginViewController.h"
#import "WebViewController.h"
#import "CBConstants.h"
#import "AuthCheckViewController.h"
#import "MainTabBarViewController.h"
#import "ModalViewController.h"
#import "EstimateViewController.h"
#import <AFNetworking/AFNetworking.h>
#import <AFNetworking/AFNetworkActivityIndicatorManager.h>
#import <KakaoOpenSDK/KakaoOpenSDK.h>

@interface AppDelegate ()

@property AuthCheckViewController *authCheckViewController;
//@property id lastViewController;

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {

    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];

    // Override point for customization after application launch.
    self.window.backgroundColor = CleanBasketMint;
    [self.window makeKeyAndVisible];


    [AFNetworkActivityIndicatorManager sharedManager].enabled = YES;

    [[UITabBarItem appearance] setTitleTextAttributes:@{ NSForegroundColorAttributeName : [UIColor whiteColor] }
                                             forState:UIControlStateNormal];
    [[UITabBarItem appearance] setTitleTextAttributes:@{ NSForegroundColorAttributeName : [UIColor blackColor] }
                                             forState:UIControlStateSelected];
    [[UITabBar appearance] setTintColor:[UIColor blackColor]];

    [[UITextField appearance] setTintColor:CleanBasketMint];

    [[UILabel appearanceWhenContainedIn:[UITableViewHeaderFooterView class], nil] setFont:[UIFont boldSystemFontOfSize:14]];



    UIStoryboard *sb = [UIStoryboard storyboardWithName:@"Main" bundle:nil];

    _authCheckViewController = (AuthCheckViewController *) [sb instantiateViewControllerWithIdentifier:@"AuthVC"];
    
    [[UINavigationBar appearance] setTintColor:[UIColor whiteColor]];
    [[UINavigationBar appearance] setBarTintColor:CleanBasketMint];
    [[UINavigationBar appearance] setTitleTextAttributes:@{NSForegroundColorAttributeName:[UIColor whiteColor]}];
    [[UINavigationBar appearance] setTranslucent:NO];
    [[UINavigationBar appearance] setBarStyle:UIBarStyleBlackTranslucent];

    LoginViewController *loginViewController = (LoginViewController *) [sb instantiateViewControllerWithIdentifier:@"LoginVC"];
    _loginVC = (id) [[UINavigationController alloc] initWithRootViewController:loginViewController];


    _webVC = [sb instantiateViewControllerWithIdentifier:@"WebVC"];


    _modalVC = [sb instantiateViewControllerWithIdentifier:@"ModalVC"];

    _estimateVC = [sb instantiateViewControllerWithIdentifier:@"EstimateVC"];

    
    //sex!
    [self.window setRootViewController:[sb instantiateViewControllerWithIdentifier:@"LoginNVC"]];


    //기존 세팅 있을때
    if ([[NSUserDefaults standardUserDefaults] objectForKey:@"isGetEventNoti"]){
              NSLog(@"!!");
    }
    //없을때
    else{
        [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"isGetEventNoti"];
        [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"isGetOrderNoti"];

        [[NSUserDefaults standardUserDefaults]synchronize];
    }



    return YES;


}

- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
//    _lastViewController = self.window.rootViewController;
    
}

- (void)applicationWillEnterForeground:(UIApplication *)application {

    
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    
    manager.responseSerializer = [AFJSONResponseSerializer serializer];
    manager.responseSerializer.acceptableContentTypes = [manager.responseSerializer.acceptableContentTypes setByAddingObject:@"text/html"];
    
    [manager GET:@"http://www.cleanbasket.co.kr/auth/check"
      parameters:nil
         success:^(AFHTTPRequestOperation *operation, id responseObject) {
             
             if ([responseObject[@"constant"]integerValue] == 17) {
                 
             } else {
                 [self.window setRootViewController:_authCheckViewController];
             }
             
             
             
         } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
             NSLog(@"Error: %@", error);
             
             [self.window setRootViewController:_authCheckViewController];
             
         }];

}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    [KOSession handleDidBecomeActive];
}


- (BOOL)application:(UIApplication *)application handleOpenURL:(NSURL *)url {
    if ([KOSession isKakaoAccountLoginCallback:url]) {
        return [KOSession handleOpenURL:url];
    }
    return NO;
}

- (BOOL)application:(UIApplication *)application openURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication annotation:(id)annotation {
    if ([KOSession isKakaoAccountLoginCallback:url]) {
        return [KOSession handleOpenURL:url];
    }
    return NO;
}



- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

@end
