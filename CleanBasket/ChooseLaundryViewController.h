//
//  ChooseLaundryViewController.h
//  CleanBasket
//
//  Created by Wonhyo Yi on 2014. 10. 16..
//  Copyright (c) 2014년 WashAppKorea. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Realm/Realm.h>
#import "CBConstants.h"
#import "ALScrollViewPaging.h"
#import "ALScrollViewPaging.h"
#import "RPVerticalStepper.h"
#import "Order.h"
#import "Item.h"
#import "ChooseOtherLaundryViewController.h"
#import "NSString+CBString.h"
#import "MBProgressHUD.h"
#import "DTOManager.h"
#import "AFNetworking.h"

@interface ChooseLaundryViewController : UIViewController {
    UIImageView *laundryImageView;
    NSArray *laundryImages;
    NSUInteger imageIdx;
    NSArray *laundryNames;
    UILabel *laundryLabel;
    UILabel *quantityLabel;
    RPVerticalStepper *stepper;
    RLMArray *itemArray;
    Item *currentItem;
    RLMRealm *realm;
    UILabel *priceLabel;
    UILabel *priceValueLabel;
    UILabel *sumLabel;
    UILabel *sumValueLabel;
    UILabel *totalLabel;
    UILabel *totalValueLabel;
    UITextField *memoTextField;
    UIButton *confirmButton;
    UIScrollView *scrollView;
    UIButton *couponButton;
    int totalPrice;
}

@property Order *currentOrder;
@property Address *currentAddress;

@end
