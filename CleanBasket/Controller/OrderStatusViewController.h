//
//  OrderStatusViewController.h
//  CleanBasket
//
//  Created by 이상진 on 2016. 2. 2..
//  Copyright © 2016년 WashappKorea. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "RoundedButton.h"
#import "BottomBorderButton.h"

@interface OrderStatusViewController : UIViewController
@property (weak, nonatomic) IBOutlet UIImageView *deliverImageView;
@property (weak, nonatomic) IBOutlet UILabel *deliverNameLabel;
@property (weak, nonatomic) IBOutlet RoundedButton *callButton;
@property (weak, nonatomic) IBOutlet UIImageView *orderStatusImageView;
@property (weak, nonatomic) IBOutlet UILabel *pickUpDateLabel;
@property (weak, nonatomic) IBOutlet UILabel *dropOffDateLabel;
@property (weak, nonatomic) IBOutlet BottomBorderButton *itemButton;
@property (weak, nonatomic) IBOutlet BottomBorderButton *priceLabel;
@property (weak, nonatomic) IBOutlet BottomBorderButton *editOrderButton;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *orderHistoryBarBtn;
@property (weak, nonatomic) IBOutlet UIView *currentOrderViewContainer;

@end
