//
//  MainViewController.h
//  CleanBasket
//
//  Created by Wonhyo Yi on 2014. 10. 3..
//  Copyright (c) 2014년 WashAppKorea. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AppDelegate.h"
#import "AFNetworking.h"
#import "MBProgressHUD.h"
#import "CBConstants.h"

@class OrderViewController;
@class EmailSignUpViewController;
@class FindPasswordViewController;
@class DTOManager;
@class User;
@class Keychain;

@interface LoginViewController : UIViewController {
    UITextField *emailTextField;
    UITextField *passwordTextField;
    UIButton *signInButton;
    UILabel *orLabel;
    UIButton *signUpButton;
    UIButton *fbSignUpButton;
    UIButton *iForgotButton;
    AFHTTPRequestOperationManager *manager;
    DTOManager *dtoManager;
    ServerContant serverConstant;
}

@end

