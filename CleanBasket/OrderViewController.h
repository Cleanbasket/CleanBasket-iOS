//
//  OrderViewController.h
//  CleanBasket
//
//  Created by Wonhyo Yi on 2014. 10. 3..
//  Copyright (c) 2014년 WashAppKorea. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CBConstants.h"
#import "CBLabel.h"
#import "AFNetworking.h"
#import "DTOManager.h"
#import <Realm/Realm.h>
#import "User.h"
#import "Address.h"
#import "ChooseLaundryViewController.h"

@interface OrderViewController : UITabBarController {
    AFHTTPRequestOperationManager *AFManager;
    RLMRealm *realm;
    UITextField *contactTextField;
    CBLabel *inputAddressLabel;
    
}

@end
