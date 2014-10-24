//
//  AddressInputViewController.h
//  CleanBasket
//
//  Created by Wonhyo Yi on 2014. 10. 3..
//  Copyright (c) 2014년 WashAppKorea. All rights reserved.
//

#import <UIKit/UIKit.h>

@class Address;
@class RLMRealm;

@interface AddressInputViewController : UIViewController

@property Address *currentAddress;
@property BOOL updateAddress;
@property RLMRealm *realm;

@end
