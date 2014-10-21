//
//  AddressInputViewController.h
//  CleanBasket
//
//  Created by Wonhyo Yi on 2014. 10. 3..
//  Copyright (c) 2014년 WashAppKorea. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Realm/Realm.h>
#import "AFNetworking.h"
#import "CBConstants.h"
#import "UITextField+CleanBasket.h"
#import "Address.h"
#import "User.h"
#import "DTOManager.h"
#import "MBProgressHUD.h"

@interface AddressInputViewController : UIViewController {
    NSDictionary *viewProperty;
    NSDictionary *pickerAddressData;
    NSArray *pickerCityKeys;
    NSMutableArray *pickerBoroughKeys;
    NSMutableArray *pickerDongKeys;
    UITextField *streetNumber;
    UITextField *buildingName;
    UITextField *remainder;
    NSString *fullAddress;
    UIPickerView *addrPickerView;
    DTOManager *dtoManager;
}

@property Address *currentAddress;
@property BOOL updateAddress;
@property RLMRealm *realm;

@end
