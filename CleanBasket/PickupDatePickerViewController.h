//
//  PickupDatePickerViewController.h
//  CleanBasket
//
//  Created by Wonhyo Yi on 2014. 10. 22..
//  Copyright (c) 2014년 WashAppKorea. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Realm/Realm.h>
#import "CBConstants.h"
#import "CBLabel.h"
#import "AFNetworking.h"
#import "DTOManager.h"
#import "User.h"
#import "Address.h"
#import "Order.h"
#import "ChooseLaundryViewController.h"
#import "AddressInputViewController.h"

@interface PickupDatePickerViewController : UIViewController
{
    UIDatePicker *datePicker;
    UILabel *dateInfoLabel;
    UIButton *confirmButton;
    UIButton *cancelButton;
    NSTimer *changeDateInfoLabelBgColorTimer;
    DTOManager *dtoManager;
    RLMRealm *realm;
    NSString *pickupDateString;
}

@property Order *currentOrder;

@end
