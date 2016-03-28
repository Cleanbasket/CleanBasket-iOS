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
#import <Realm/Realm.h>
#import "User.h"
#import "Notification.h"
#import <ZDCChat/ZDCChat.h>


@interface AppDelegate ()

@property AuthCheckViewController *authCheckViewController;
//@property id lastViewController;

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    
    //이전 버전에 쓰이던 유저 정보 마이그레이션
    [self realmMigration];
    
    //기존 세팅 있을때
    if ([[NSUserDefaults standardUserDefaults] objectForKey:@"isGetEventNoti"]){
        
    }
    //없을때(처음 실행)
    else{
        
        [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"isGetEventNoti"];
        [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"isGetOrderNoti"];
        
        [[NSUserDefaults standardUserDefaults]synchronize];
    }
    
    
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];

    // Override point for customization after application launch.
    self.window.backgroundColor = CleanBasketMint;
    [self.window makeKeyAndVisible];


    [AFNetworkActivityIndicatorManager sharedManager].enabled = YES;

    [[UITabBarItem appearance] setTitleTextAttributes:@{ NSForegroundColorAttributeName : [UIColor grayColor] }
                                             forState:UIControlStateNormal];
    [[UITabBarItem appearance] setTitleTextAttributes:@{ NSForegroundColorAttributeName : CleanBasketMint }
                                             forState:UIControlStateSelected];
    [[UITabBar appearance] setTintColor:CleanBasketMint];

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

//    _estimateVC = [sb instantiateViewControllerWithIdentifier:@"EstimateVC"];

    [self.window setRootViewController:_authCheckViewController];

    
    [[UIApplication sharedApplication]registerUserNotificationSettings:[UIUserNotificationSettings settingsForTypes:UIUserNotificationTypeAlert categories:nil]];
    
    
    //zopim
    [ZDCChat configure:^(ZDCConfig *defaults) {
        
        defaults.accountKey = @"3IvIR4PxJLUypCdpgbBmJLBjYby32CVD";
    }];
//    
//    [[RLMRealm defaultRealm] transactionWithBlock:^{
//        
//        [[RLMRealm defaultRealm] deleteObjects:[Notification allObjects]];
//        [[UIApplication sharedApplication] cancelAllLocalNotifications];
//    }];
//    
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

- (void)application:(UIApplication *)application didReceiveLocalNotification:(UILocalNotification *)notification{
    
    
    //local db에 저장.
    Notification *noti = [Notification new];
    noti.message = notification.alertBody;
    noti.oid = notification.userInfo[@"oid"];
    

    if ([notification.alertAction isEqualToString:@"PICKUP_NOTI"]) {
        noti.imageName = @"ic_alarm_pickup";
        noti.date = notification.userInfo[@"dropOffDate"];
    }
    else if ([notification.alertAction isEqualToString:@"DROPOFF_NOTI"]){
        noti.imageName = @"ic_alarm_delivery";
        noti.date = notification.userInfo[@"dropOffDate"];
    }
    
    RLMRealm *realm = [RLMRealm defaultRealm];
    [realm beginWriteTransaction];
    [realm addObject:noti];
    [realm commitWriteTransaction];
}


- (void)applicationWillEnterForeground:(UIApplication *)application {

    
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    
    manager.responseSerializer = [AFJSONResponseSerializer serializer];
    manager.responseSerializer.acceptableContentTypes = [manager.responseSerializer.acceptableContentTypes setByAddingObject:@"text/html"];
    
    NSString *urlString = [NSString stringWithFormat:@"%@%@",CB_SERVER_URL,@"auth/check"];
    [manager GET:urlString
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



- (void)realmMigration {
    RLMRealmConfiguration *config = [RLMRealmConfiguration defaultConfiguration];
    config.schemaVersion = 2;
    config.migrationBlock = ^(RLMMigration *migration, uint64_t oldSchemaVersion) {
        if (oldSchemaVersion < 1) {
            [migration enumerateObjects:User.className
                                  block:^(RLMObject *oldObject, RLMObject *newObject) {
                                      
                                      // combine name fields into a single field
                                      newObject[@"email"] = oldObject[@"email"];
                                      newObject[@"password"] = oldObject[@"email"];
                                      newObject[@"phone"] = oldObject[@"phone"];
                                  }];
        }
    };
    [RLMRealmConfiguration setDefaultConfiguration:config];
}



@end
