//
//  ChangePasswordViewController.m
//  CleanBasket
//
//  Created by 이상진 on 2016. 1. 15..
//  Copyright © 2016년 WashappKorea. All rights reserved.
//

#import <SVProgressHUD/SVProgressHUD.h>
#import "ChangePasswordViewController.h"
#import "SignTextField.h"
#import "User.h"

#import <AFNetworking/AFNetworking.h>
#import <Realm/Realm.h>

@interface ChangePasswordViewController()

@property (weak, nonatomic) IBOutlet SignTextField *currentPwTF;
@property (weak, nonatomic) IBOutlet SignTextField *changePwTF;
@property (weak, nonatomic) IBOutlet SignTextField *repeatTF;


@end


@implementation ChangePasswordViewController

- (void)viewDidLoad{
    
}


- (void)awakeFromNib {
    [self setModalPresentationStyle:UIModalPresentationCustom];
    [self setNeedsStatusBarAppearanceUpdate];
}

- (IBAction)changePassword:(id)sender {

    if (!_currentPwTF.text.length) {
        [SVProgressHUD showErrorWithStatus:@"현재 비밀번호를 입력해주세요."];
        [_currentPwTF becomeFirstResponder];
    }
    else if (!_changePwTF.text.length) {
        [SVProgressHUD showErrorWithStatus:@"새 비밀번호를 입력해주세요."];
        [_changePwTF becomeFirstResponder];
        
    }
    else if (!_repeatTF.text.length) {
        [SVProgressHUD showErrorWithStatus:@"새 비밀번호를 한번 더 입력해주세요."];
        [_repeatTF becomeFirstResponder];
        
    } else if (![_changePwTF.text isEqualToString:_repeatTF.text]){
        [SVProgressHUD showErrorWithStatus:NSLocalizedString(@"error_incorrect_repeat",nil)];
    } else {
        AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];


        manager.requestSerializer = [AFJSONRequestSerializer serializer];
        manager.responseSerializer = [AFJSONResponseSerializer serializer];
        manager.responseSerializer.acceptableContentTypes = [manager.responseSerializer.acceptableContentTypes setByAddingObject:@"text/html"];


        [manager POST:@"http://52.79.39.100:8080/member/password/update/new"
            parameters:@{@"current_password":_currentPwTF.text,@"password": _changePwTF.text}
               success:^(AFHTTPRequestOperation *operation, id responseObject) {



                   if ([responseObject[@"constant"] integerValue] == 1){

                       [SVProgressHUD showSuccessWithStatus:NSLocalizedString(@"success_password_change",nil)];

                       RLMRealm *realm = [RLMRealm defaultRealm];
                       User *user = [[User allObjects] firstObject];
                       [realm beginWriteTransaction];
                       [user setPassword:_changePwTF.text];
                       [realm commitWriteTransaction];


                       [self dismissVC:nil];

                   } else {
                       [SVProgressHUD showErrorWithStatus:NSLocalizedString(@"error_password_change",nil)];
                   }



               } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                    NSLog(@"Error: %@", error);
                }];


    }
    
}

- (IBAction)dismissVC:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}


- (UIStatusBarStyle)preferredStatusBarStyle {
    return UIStatusBarStyleLightContent;
}

@end
