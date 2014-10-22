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
    
    UIBarButtonItem *rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"닫기" style:UIBarButtonItemStylePlain target:self action:@selector(doneButtonTouched)];
    [self.navigationItem setRightBarButtonItem:rightBarButtonItem];
    
    emailTextField = [self makeTextField];
    [emailTextField setTag:0];
    [emailTextField setFrame:[self makeRect:emailTextField]];
    [emailTextField setPlaceholder:@"mail@cleanbasket.co.kr"];
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

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [self sendButtonTouched];
    return YES;
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
    [self.view endEditing:YES];
    NSDictionary *parameter = @{@"email":[emailTextField text]};
    
    [MBProgressHUD showHUDAddedTo:self.view animated:YES labelText:@"서버와 통신 중"];
    AFHTTPRequestOperationManager *afManager = [AFHTTPRequestOperationManager manager];
    afManager.requestSerializer = [AFJSONRequestSerializer serializer];
    afManager.responseSerializer = [AFJSONResponseSerializer serializer];
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_LOW, 0), ^{
        [afManager POST:@"http://cleanbasket.co.kr/password/inquiry"  parameters:parameter success:^(AFHTTPRequestOperation *operation, id responseObject) {
            NSNumber *constant = [responseObject valueForKey:@"constant"];
            dispatch_async(dispatch_get_main_queue(), ^{
                [MBProgressHUD hideHUDForView:self.view animated:YES];
                switch ([constant intValue]) {
                    case CBServerConstantSuccess: {
                        [emailTextField setText:@""];
                        [self showHudMessage:@"해당 이메일로 새 비밀번호를 전송했습니다."];
                        [self performSelector:@selector(doneButtonTouched) withObject:nil afterDelay:3];
                    }
                        break;
                    case CBServerConstantError: {
                        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:nil message:@"서버 오류가 발생했습니다. 매니저에게 연락 부탁드립니다." delegate:self cancelButtonTitle:@"닫기" otherButtonTitles:nil, nil];
                        [alertView show];
                    }
                        break;
                    case CBServerConstantEmailError: {
                        [self showHudMessage:@"해당 이메일은 존재하지 않습니다."];
                    }
                        break;
                    default:
                        break;
                }
            });
            
        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
            dispatch_async(dispatch_get_main_queue(), ^{
                [MBProgressHUD hideHUDForView:self.view animated:YES];
            });
            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:nil message:@"네트워크 연결 상태를 확인해주세요." delegate:self cancelButtonTitle:@"닫기" otherButtonTitles:nil, nil];
            [alertView show];
            NSLog(@"%@", error);
        }];
    });
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event{
    [self.view endEditing:YES];
    [super touchesBegan:touches withEvent:event];
}

- (void) showHudMessage:(NSString*)message {
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES labelText:nil];
    
    // Configure for text only and offset down
    hud.mode = MBProgressHUDModeText;
    hud.labelText = message;
    [hud setLabelFont:[UIFont systemFontOfSize:14.0f]];
    hud.margin = 10.f;
    hud.removeFromSuperViewOnHide = YES;
    [hud hide:YES afterDelay:2];
    return;
}

@end
