//
//  EmailSignUpViewController.h
//  CleanBasket
//
//  Created by Wonhyo Yi on 2014. 10. 3..
//  Copyright (c) 2014년 WashAppKorea. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CBConstants.h"
#import "AddressInputViewController.h"
#import "TermsViewController.h"
#import "AFNetworking.h"
#import "AppDelegate.h"


@interface EmailSignUpViewController : UIViewController {
    UITextField *emailTextField;
    UITextField *passwordTextField;
    UITextField *passwordCheckTextField;
    UITextField *contactTextField;
    UIButton *addressButton;
    UILabel *termsLabel;
    UIButton *termsButton;
    UIButton *signUpButton;
    AFHTTPRequestOperationManager *manager;
    Address *newAddress;
}

@end
