//
//  ChooseLaundryViewController.h
//  CleanBasket
//
//  Created by Wonhyo Yi on 2014. 10. 16..
//  Copyright (c) 2014년 WashAppKorea. All rights reserved.
//

#import <UIKit/UIKit.h>


@class Order;
@class Address;
@class Coupon;

@interface ChooseLaundryViewController : UIViewController

@property Order *currentOrder;
@property Address *currentAddress;
@property Coupon *currentCoupon;

@end
