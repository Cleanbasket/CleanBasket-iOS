//
//  MyUITabBarController.h
//  CleanBasket
//
//  Created by Wonhyo Yi on 2014. 10. 3..
//  Copyright (c) 2014년 WashAppKorea. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CBConstants.h"
#import "OrderDetailViewController.h"
#import "OrderStatusViewController.h"
#import <Realm/Realm.h>
#import "Order.h"

@interface MyUITabBarController : UITabBarController {
    UITabBarItem *currentItem;
}

@end
