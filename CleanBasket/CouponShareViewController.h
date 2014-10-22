//
//  CouponShareViewController.h
//  CleanBasket
//
//  Created by Wonhyo Yi on 2014. 10. 3..
//  Copyright (c) 2014년 WashAppKorea. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Realm/Realm.h>
#import "NSString+CBString.h"
#import "CBCouponTableViewCell.h"
#import "CBConstants.h"
#import "Coupon.h"

@interface CouponShareViewController : UIViewController {
    UITableView *couponTableView;
    UIButton *couponInsertButton;
}

@end
