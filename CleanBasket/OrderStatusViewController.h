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

@interface OrderStatusViewController : UIViewController {
    int processIndex;
    UIImageView *processImageView;
    NSArray *processImages;
    UIButton *orderListButton;
	RLMRealm *realm;
	AFHTTPRequestOperationManager *afManager;
	NSArray *dataArray;
	UIImageView *profileView;
	UIImage *managerPhotoImage;
	UILabel *managerNameLabel;
	UILabel *visitDateLabel;
    Order *firstOrder;
}

@end
