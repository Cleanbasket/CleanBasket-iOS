//
//  AppDelegate.h
//  CleanBasket
//
//  Created by 이상진 on 2015. 12. 7..
//  Copyright © 2015년 WashappKorea. All rights reserved.
//

#import <UIKit/UIKit.h>

@class LoginViewController;
@class WebViewController;
@class ModalViewController;

@interface AppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;
@property (strong, nonatomic) LoginViewController *loginVC;
@property (strong, nonatomic) WebViewController *webVC;
@property (strong, nonatomic) ModalViewController *modalVC;

@end

