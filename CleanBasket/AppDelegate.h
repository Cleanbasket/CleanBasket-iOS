//
//  AppDelegate.h
//  CleanBasket
//
//  Created by Wonhyo Yi on 2014. 10. 3..
//  Copyright (c) 2014년 WashAppKorea. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreData/CoreData.h>
#import "LoginViewController.h"
#import "OrderStatusViewController.h"
#import "PriceViewController.h"
#import "AccountViewController.h"
#import "CouponShareViewController.h"
#import "ServiceInfoViewController.h"
#import "MyUITabBarController.h"
#import "CBConstants.h"
#import "AFNetworking.h"

@interface AppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;
// tabbar를 loginView로 옮겨보자
@property (strong, nonatomic) MyUITabBarController *tabBarController;
@property (strong, nonatomic) OrderViewController *orderViewController;
@property (strong, nonatomic) OrderStatusViewController *orderStatusViewController;
@property (strong, nonatomic) PriceViewController *priceViewController;
@property (strong, nonatomic) AccountViewController *accountViewController;
@property (strong, nonatomic) CouponShareViewController *couponShareViewController;
@property (strong, nonatomic) ServiceInfoViewController *serviceInfoViewController;
@property (strong, nonatomic) UINavigationController *tabNavController;

@property (readonly, strong, nonatomic) NSManagedObjectContext *managedObjectContext;
@property (readonly, strong, nonatomic) NSManagedObjectModel *managedObjectModel;
@property (readonly, strong, nonatomic) NSPersistentStoreCoordinator *persistentStoreCoordinator;

- (void)saveContext;
- (NSURL *)applicationDocumentsDirectory;


@end

