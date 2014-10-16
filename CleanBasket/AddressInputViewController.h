//
//  AddressInputViewController.h
//  CleanBasket
//
//  Created by Wonhyo Yi on 2014. 10. 3..
//  Copyright (c) 2014년 WashAppKorea. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Realm/Realm.h>
#import "CBConstants.h"
#import "UITextField+CleanBasket.h"
#import "Address.h"
#import "User.h"

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
    RLMRealm *realm;
    UIPickerView *addrPickerView;
}

@end
