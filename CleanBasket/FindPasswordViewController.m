//
//  FindPasswordViewController.m
//  CleanBasket
//
//  Created by Wonhyo Yi on 2014. 10. 3..
//  Copyright (c) 2014년 WashAppKorea. All rights reserved.
//

#import "FindPasswordViewController.h"
#define FieldHeight 35
#define FieldWidth 240
#define CenterX (DEVICE_WIDTH - FieldWidth)/2
#define FirstElementY 80
#define Interval 45

@interface FindPasswordViewController () <UITextFieldDelegate>

@end

@implementation FindPasswordViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self.navigationItem setTitle:@"비밀번호 찾기"];
    [self.view setBackgroundColor:[UIColor whiteColor]];
    
    [self.navigationItem setRightBarButtonItem:[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self action:@selector(doneButtonTouched)]];
    
    emailTextField = [self makeTextField];
    [emailTextField setTag:0];
    [emailTextField setFrame:[self makeRect:emailTextField]];
    [emailTextField setPlaceholder:@"example@naver.com"];
    [emailTextField setReturnKeyType:UIReturnKeyDone];
    
    sendButton = [[UIButton alloc] init];
    [sendButton setTag:1];
    [sendButton setFrame:[self makeRect:sendButton]];
    [sendButton setTitle:@"전송" forState:UIControlStateNormal];
    [sendButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [sendButton setBackgroundColor:CleanBasketMint];
    [sendButton.layer setCornerRadius:15.0f];
    [sendButton addTarget:self action:@selector(sendButtonTouched) forControlEvents:UIControlEventTouchUpInside];
    
    [self.view addSubview:emailTextField];
    [self.view addSubview:sendButton];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (UITextField *)makeTextField {
    UITextField *textField = [UITextField new];
    [textField setDelegate:self];
    [textField setBackgroundColor:UltraLightGray];
    [textField setTextColor:[UIColor blackColor]];
    [textField setBorderStyle:UITextBorderStyleNone];
    [textField setTextAlignment:NSTextAlignmentLeft];
    [textField setClearButtonMode:UITextFieldViewModeWhileEditing];
    [textField setAutocapitalizationType:UITextAutocapitalizationTypeNone];
    [textField setAutocorrectionType:UITextAutocorrectionTypeNo];
    [textField.layer setCornerRadius:15.0f];
    UIView *paddingView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 10, 20)];
    [textField setLeftView:paddingView];
    [textField setLeftViewMode:UITextFieldViewModeAlways];
    
    return textField;
}

- (void) doneButtonTouched {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (CGRect) makeRect: (UIView*)view {
    return CGRectMake(CenterX, FirstElementY + Interval * [view tag], FieldWidth, FieldHeight);
}

- (void) sendButtonTouched {
    
    if ([emailTextField.text length] <= 0) {
        UIAlertView *invalidEmailAlertView = [[UIAlertView alloc] initWithTitle:nil message:@"올바른 회원 정보를 입력해주세요:)" delegate:self cancelButtonTitle:@"닫기" otherButtonTitles:nil, nil];
        [invalidEmailAlertView show];
        return;

    }
    
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:nil message:@"해당 이메일로\n임시비밀번호를 전송했습니다." delegate:self cancelButtonTitle:@"닫기" otherButtonTitles:nil, nil];
    [alertView show];
}

@end
