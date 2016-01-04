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

@interface AppDelegate ()

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {

    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];

    // Override point for customization after application launch.
    self.window.backgroundColor = [UIColor whiteColor];
    [self.window makeKeyAndVisible];


    [[UITabBarItem appearance] setTitleTextAttributes:@{ NSForegroundColorAttributeName : [UIColor whiteColor] }
                                             forState:UIControlStateNormal];
    [[UITabBarItem appearance] setTitleTextAttributes:@{ NSForegroundColorAttributeName : [UIColor blackColor] }
                                             forState:UIControlStateSelected];
    [[UITabBar appearance] setTintColor:[UIColor blackColor]];



    UIStoryboard *sb = [UIStoryboard storyboardWithName:@"Main" bundle:nil];

    AuthCheckViewController *authCheckViewController = (AuthCheckViewController *) [sb instantiateViewControllerWithIdentifier:@"AuthVC"];
    
    UINavigationController *navController = [[UINavigationController alloc] initWithRootViewController:authCheckViewController];
    [[UINavigationBar appearance] setTintColor:[UIColor whiteColor]];
    [[UINavigationBar appearance] setBarTintColor:CleanBasketMint];
    [[UINavigationBar appearance] setTitleTextAttributes:@{NSForegroundColorAttributeName:[UIColor whiteColor]}];


//    MainTabBarViewController *tabBarViewController = (MainTabBarViewController *) [sb instantiateViewControllerWithIdentifier:@"MainTBC"];
    
    [self.window setRootViewController:navController];


    LoginViewController *loginViewController = (LoginViewController *) [sb instantiateViewControllerWithIdentifier:@"LoginVC"];
    _loginVC = (id) [[UINavigationController alloc] initWithRootViewController:loginViewController];


    _webVC = (WebViewController *) [sb instantiateViewControllerWithIdentifier:@"WebVC"];


    _modalVC =     (ModalViewController *) [sb instantiateViewControllerWithIdentifier:@"ModalVC"];


//    self.tabBarController = [[MyUITabBarController alloc] init];
//    [_tabBarController.moreNavigationController setTitle:@"더 보기"];
//    [self.tabBarController.moreNavigationController.view setTintColor:CleanBasketMint];
//    self.tabNavController = [[UINavigationController alloc] initWithRootViewController:self.tabBarController];
//
//    //Load our animation controllers
//    _modalAnimationController = [[ModalAnimation alloc] init];
//    _slideAnimationController = [[SlideAnimation alloc] init];
//    _shuffleAnimationController = [[ShuffleAnimation alloc] init];
//
//    [_tabBarController setDelegate:self];
//    [_tabBarController setTransitioningDelegate:self];
//    [_tabBarController setModalTransitionStyle:UIModalTransitionStyleCrossDissolve];
//    [_tabBarController.view setBackgroundColor:UltraLightGray];
//
//    self.orderViewController = [[OrderViewController alloc] init];
//    self.orderStatusViewController = [[OrderStatusViewController alloc] init];
//    self.priceViewController = [[PriceViewController alloc] init];
//    self.accountViewController = [[AccountViewController alloc] init];
//    self.couponShareViewController = [[CouponShareViewController alloc] init];
//    self.serviceInfoViewController = [[ServiceInfoViewController alloc] init];
//
//    NSArray *myBizViewControllers = [[NSArray alloc] initWithObjects:self.orderViewController, self.orderStatusViewController, self.priceViewController, self.couponShareViewController, self.serviceInfoViewController, nil];
//
//    [self.tabBarController setViewControllers:myBizViewControllers];

    return YES;


}

- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

@end
