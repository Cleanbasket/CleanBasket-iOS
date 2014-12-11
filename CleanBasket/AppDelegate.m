//
//  AppDelegate.m
//  CleanBasket
//
//  Created by Wonhyo Yi on 2014. 10. 3..
//  Copyright (c) 2014년 WashAppKorea. All rights reserved.
//

#import "AppDelegate.h"
#import <FacebookSDK/FacebookSDK.h>
#import <KakaoOpenSDK/KakaoOpenSDK.h>
#import "OrderViewController.h"
#import "LoginViewController.h"
#import "OrderStatusViewController.h"
#import "PriceViewController.h"
#import "AccountViewController.h"
#import "CouponShareViewController.h"
#import "ServiceInfoViewController.h"
#import "MyUITabBarController.h"
#import "Keychain.h"
#import "User.h"

#import "ModalAnimation.h"
#import "SlideAnimation.h"
#import "ShuffleAnimation.h"
#import "ScaleAnimation.h"

@interface AppDelegate () <UIViewControllerTransitioningDelegate, UIViewControllerAnimatedTransitioning> {
    ModalAnimation *_modalAnimationController;
    SlideAnimation *_slideAnimationController;
    ShuffleAnimation *_shuffleAnimationController;
}
@property (nonatomic) BOOL presentMode;
@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(NotificationReceived:) name:nil object:nil];
    // reset REALM.IO Database
//            [[NSFileManager defaultManager] removeItemAtPath:[RLMRealm defaultRealmPath] error:nil];
    
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent animated:NO];
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    // Override point for customization after application launch.
    self.window.backgroundColor = [UIColor whiteColor];
    [self.window makeKeyAndVisible];
    
    LoginViewController *loginViewController = [[LoginViewController alloc] init];
    UINavigationController *navController = [[UINavigationController alloc] initWithRootViewController:loginViewController];
    [[UINavigationBar appearance] setTintColor:[UIColor whiteColor]];
    [[UINavigationBar appearance] setBarTintColor:CleanBasketMint];
    [[UINavigationBar appearance] setTitleTextAttributes:@{NSForegroundColorAttributeName:[UIColor whiteColor]}];
    
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent animated:NO];
    
    [self.window setRootViewController:navController];
    
    self.tabBarController = [[MyUITabBarController alloc] init];
    [_tabBarController.moreNavigationController setTitle:@"더 보기"];
    [self.tabBarController.moreNavigationController.view setTintColor:CleanBasketMint];
    self.tabNavController = [[UINavigationController alloc] initWithRootViewController:self.tabBarController];
    
    //Load our animation controllers
    _modalAnimationController = [[ModalAnimation alloc] init];
    _slideAnimationController = [[SlideAnimation alloc] init];
    _shuffleAnimationController = [[ShuffleAnimation alloc] init];
    
    [_tabBarController setDelegate:self];
    [_tabBarController setTransitioningDelegate:self];
    [_tabBarController setModalTransitionStyle:UIModalTransitionStyleCrossDissolve];
    [_tabBarController.view setBackgroundColor:UltraLightGray];
    
    self.orderViewController = [[OrderViewController alloc] init];
    self.orderStatusViewController = [[OrderStatusViewController alloc] init];
    self.priceViewController = [[PriceViewController alloc] init];
    self.accountViewController = [[AccountViewController alloc] init];
    self.couponShareViewController = [[CouponShareViewController alloc] init];
    self.serviceInfoViewController = [[ServiceInfoViewController alloc] init];
    
    NSArray *myBizViewControllers = [[NSArray alloc] initWithObjects:self.orderViewController, self.orderStatusViewController, self.priceViewController, self.couponShareViewController, self.serviceInfoViewController, nil];
    
    [self.tabBarController setViewControllers:myBizViewControllers];

    return YES;
}

- (id<UIViewControllerAnimatedTransitioning>)tabBarController:(UITabBarController *)tabBarController animationControllerForTransitionFromViewController:(UIViewController *)fromVC toViewController:(UIViewController *)toVC {
    
     [fromVC setTransitioningDelegate:self];
     [fromVC setModalTransitionStyle:UIModalTransitionStyleCrossDissolve];
     [toVC setTransitioningDelegate:self];
     [toVC setModalTransitionStyle:UIModalTransitionStyleCrossDissolve];
    
    return self;
}


#pragma mark - UIViewControllerTransitioningDelegate Methods
- (NSTimeInterval)transitionDuration:(id<UIViewControllerContextTransitioning>)transitionContext {
    return 1.0f;
}

- (void)animateTransition:(id<UIViewControllerContextTransitioning>)transitionContext {
    
    UIViewController *fromVC = [transitionContext viewControllerForKey:UITransitionContextFromViewControllerKey];
    UIViewController *toVC = [transitionContext viewControllerForKey:UITransitionContextToViewControllerKey];
    
     NSLog(@"from %@ to %@", fromVC, toVC);
     
     [[transitionContext containerView] addSubview:fromVC.view];
     [[transitionContext containerView] addSubview:toVC.view];
     
     CGRect dismissRect = fromVC.view.frame;
     dismissRect.origin.x = -320;
     CGRect appearToRect = toVC.view.frame;
     appearToRect.origin.x = 0;
     
     CGRect appearFromRect = toVC.view.frame;
     appearFromRect.origin.x = 320;
     [toVC.view setFrame:appearFromRect];
     
     [UIView animateWithDuration:0.3f animations:^{
     NSLog(@"Animating");
     [fromVC.view setFrame:dismissRect];
     [toVC.view setFrame:appearToRect];
     } completion:^(BOOL finished) {
     [transitionContext completeTransition:YES];
     }];
 
}


- (void) NotificationReceived:(NSNotification*)noti {
    if ([[noti name] isEqualToString:@"userDidLogout"] || [[noti name] isEqualToString:@"sessionExpired"]) {
        NSLog(@"%@", [noti name]);
        [self.tabBarController.navigationController setNavigationBarHidden:NO];
        [self.tabBarController setSelectedIndex:0];
        [self.tabBarController dismissViewControllerAnimated:YES completion:nil];
        Keychain *keychain = [[Keychain alloc] initWithService:APP_NAME_STRING withGroup:nil];
        
        for (User *each in [User allObjects]) {
            [keychain remove:[each email]];
        }
    }
    
    // 주문 접수 완료 후 현재 화면을 OrderStatus로 변경
    if ([[noti name] isEqualToString:@"orderComplete"]) {
        [self.tabBarController setSelectedIndex:1];
        
        // MyUITabBarController에게 주문이 완료됨을 알림
        [[NSNotificationCenter defaultCenter] postNotificationName:@"checkCompletedOrder" object:nil];
    }
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
    // Logs 'install' and 'app activate' App Events.
    [FBAppEvents activateApp];
}

- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    // Saves changes in the application's managed object context before the application terminates.
    [self saveContext];
}

//- (BOOL)application:(UIApplication *)application
//            openURL:(NSURL *)url
//  sourceApplication:(NSString *)sourceApplication
//         annotation:(id)annotation {
//    // attempt to extract a token from the url
//    return [FBAppCall handleOpenURL:url sourceApplication:sourceApplication];
//}

- (BOOL)application:(UIApplication *)application
            openURL:(NSURL *)url
  sourceApplication:(NSString *)sourceApplication
         annotation:(id)annotation {
    
    if( [KOSession isKakaoLinkCallback:url] ) {
        NSLog(@"KakaoLink callback! query string: %@", [url query]);
        return YES;
    }
    
    BOOL urlWasHandled = [FBAppCall handleOpenURL:url
                                sourceApplication:sourceApplication
                                  fallbackHandler:^(FBAppCall *call) {
                                      NSLog(@"Unhandled deep link: %@", url);
                                      // Here goes the code to handle the links
                                      // Use the links to show a relevant view of your app to the user
                                  }];
    
    return urlWasHandled;
}

#pragma mark - Core Data stack

@synthesize managedObjectContext = _managedObjectContext;
@synthesize managedObjectModel = _managedObjectModel;
@synthesize persistentStoreCoordinator = _persistentStoreCoordinator;

- (NSURL *)applicationDocumentsDirectory {
    // The directory the application uses to store the Core Data store file. This code uses a directory named "co.kr.washappkorea.CleanBasket" in the application's documents directory.
    return [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];
}

- (NSManagedObjectModel *)managedObjectModel {
    // The managed object model for the application. It is a fatal error for the application not to be able to find and load its model.
    if (_managedObjectModel != nil) {
        return _managedObjectModel;
    }
    NSURL *modelURL = [[NSBundle mainBundle] URLForResource:@"CleanBasket" withExtension:@"momd"];
    _managedObjectModel = [[NSManagedObjectModel alloc] initWithContentsOfURL:modelURL];
    return _managedObjectModel;
}

- (NSPersistentStoreCoordinator *)persistentStoreCoordinator {
    // The persistent store coordinator for the application. This implementation creates and return a coordinator, having added the store for the application to it.
    if (_persistentStoreCoordinator != nil) {
        return _persistentStoreCoordinator;
    }
    
    // Create the coordinator and store
    
    _persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:[self managedObjectModel]];
    NSURL *storeURL = [[self applicationDocumentsDirectory] URLByAppendingPathComponent:@"CleanBasket.sqlite"];
    NSError *error = nil;
    NSString *failureReason = @"There was an error creating or loading the application's saved data.";
    if (![_persistentStoreCoordinator addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:storeURL options:nil error:&error]) {
        // Report any error we got.
        NSMutableDictionary *dict = [NSMutableDictionary dictionary];
        dict[NSLocalizedDescriptionKey] = @"Failed to initialize the application's saved data";
        dict[NSLocalizedFailureReasonErrorKey] = failureReason;
        dict[NSUnderlyingErrorKey] = error;
        error = [NSError errorWithDomain:@"YOUR_ERROR_DOMAIN" code:9999 userInfo:dict];
        // Replace this with code to handle the error appropriately.
        // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
        abort();
    }
    
    return _persistentStoreCoordinator;
}


- (NSManagedObjectContext *)managedObjectContext {
    // Returns the managed object context for the application (which is already bound to the persistent store coordinator for the application.)
    if (_managedObjectContext != nil) {
        return _managedObjectContext;
    }
    
    NSPersistentStoreCoordinator *coordinator = [self persistentStoreCoordinator];
    if (!coordinator) {
        return nil;
    }
    _managedObjectContext = [[NSManagedObjectContext alloc] init];
    [_managedObjectContext setPersistentStoreCoordinator:coordinator];
    return _managedObjectContext;
}

#pragma mark - Core Data Saving support

- (void)saveContext {
    NSManagedObjectContext *managedObjectContext = self.managedObjectContext;
    if (managedObjectContext != nil) {
        NSError *error = nil;
        if ([managedObjectContext hasChanges] && ![managedObjectContext save:&error]) {
            // Replace this implementation with code to handle the error appropriately.
            // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
            NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
            abort();
        }
    }
}

@end
