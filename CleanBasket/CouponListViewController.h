//
//  CouponListViewController.h
//  CleanBasket
//
//  Created by Wonhyo Yi on 2014. 10. 21..
//  Copyright (c) 2014년 WashAppKorea. All rights reserved.
//

#import <UIKit/UIKit.h>


@class CouponListViewController;
@class Coupon;
@protocol CouponListViewControllerDelegate <NSObject>

- (void)setViewController:(CouponListViewController*)controller currentCoupon:(Coupon*)currentCoupon;

@end

@interface CouponListViewController : UIViewController

@property (nonatomic, weak) id <CouponListViewControllerDelegate> delegate;

@end
