//
//  OrderStatusViewController.h
//  CleanBasket
//
//  Created by Wonhyo Yi on 2014. 10. 3..
//  Copyright (c) 2014년 WashAppKorea. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Realm/Realm.h>
#import "AFNetworking.h"
#import "CBConstants.h"
#import "Order.h"
#import "MBProgressHUD.h"
#import "NSString+CBString.h"

@interface OrderStatusViewController : UIViewController {
    int processIndex;
    UIImageView *processImageView;
    NSArray *processImages;
    UIButton *orderListButton;
	RLMRealm *realm;
	AFHTTPRequestOperationManager *afManager;
	UIImageView *profileView;

	UILabel *managerNameLabel;
	UILabel *visitDateLabel;
    UILabel *visitTimeLabel;
    Order *firstOrder;
}

@property NSArray *dataArray;

@end
