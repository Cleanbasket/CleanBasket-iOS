//
//  CouponListViewController.h
//  CleanBasket
//
//  Created by Wonhyo Yi on 2014. 10. 21..
//  Copyright (c) 2014년 WashAppKorea. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CBCouponTableViewCell.h"
#import "CBConstants.h"
#import <Realm/Realm.h>
#import "Coupon.h"
#import "NSString+CBString.h"

@class CouponListViewController;
@protocol CouponListViewControllerDelegate <NSObject>

- (void)setViewController:(CouponListViewController*)controller currentCoupon:(Coupon*)currentCoupon;

@end

@interface CouponListViewController : UIViewController {
    UITableView *couponTableView;
}

@property (nonatomic, weak) id <CouponListViewControllerDelegate> delegate;

@end
