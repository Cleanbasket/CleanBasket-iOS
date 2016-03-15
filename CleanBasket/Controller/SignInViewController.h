//
//  SignInViewController.h
//  CleanBasket
//
//  Created by 이상진 on 2015. 12. 14..
//  Copyright © 2015년 WashappKorea. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef enum CBModalType : NSUInteger {
    
    CBModalTypeSignIn = 101,
    CBModalTypeSignUp = 102,
    CBModalTypeFindPw = 103
    
} CBModalType ;

@interface SignInViewController : UIViewController<UITextFieldDelegate>


@property CBModalType *modalType;

@end
