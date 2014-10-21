//
//  OrderDetailViewController.h
//  CleanBasket
//
//  Created by Wonhyo Yi on 2014. 10. 21..
//  Copyright (c) 2014년 WashAppKorea. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Realm/Realm.h>
#import "AFNetworking.h"
#import "Order.h"
#import "MBProgressHUD.h"   
#import "CBOrderDetailTableViewCell.h"
#import "NSString+CBString.h"


@interface OrderDetailViewController : UIViewController {
    AFHTTPRequestOperationManager *afManager;
    
    UITableView *orderTableView;
	RLMArray *orderList;
    NSArray *orderStateName;
}

@end
