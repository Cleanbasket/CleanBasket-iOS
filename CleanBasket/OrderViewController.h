//
//  OrderViewController.h
//  CleanBasket
//
//  Created by Wonhyo Yi on 2014. 10. 3..
//  Copyright (c) 2014년 WashAppKorea. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Realm/Realm.h>
#import "PickupDatePickerViewController.h"
#import "DeliverDatePickerViewController.h"
#import "CBConstants.h"
#import "CBLabel.h"
#import "AFNetworking.h"
#import "DTOManager.h"
#import "User.h"
#import "Address.h"
#import "Order.h"
#import "ChooseLaundryViewController.h"
#import "AddressInputViewController.h"

@interface OrderViewController : UITabBarController {
    AFHTTPRequestOperationManager *AFManager;
    RLMRealm *realm;
    UITextField *contactTextField;
    CBLabel *inputAddressLabel;
    DTOManager *dtoManager;
    Order *currentOrder;
    CBLabel *pickupDateLabel;
    CBLabel *deliverDateLabel;
    UIScrollView *scrollView;
    UISegmentedControl *addressControl;
    Address *currentAddress;
}

@end
