//
//  OrderViewController.h
//  CleanBasket
//
//  Created by 이상진 on 2016. 1. 4..
//  Copyright © 2016년 WashappKorea. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "OrderCheckViewController.h"

@interface OrderViewController : UIViewController<OrderViewDelegate> {
    NSString *phone;
    NSString *memo;

}
@property NSString *phone;
@property NSString *memo;


@end
