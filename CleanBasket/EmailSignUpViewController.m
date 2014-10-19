//
//  EmailSignUpViewController.m
//  CleanBasket
//
//  Created by Wonhyo Yi on 2014. 10. 3..
//  Copyright (c) 2014년 WashAppKorea. All rights reserved.
//

#import "EmailSignUpViewController.h"
#define FieldHeight 35
#define FieldWidth 260
#define CenterX (DEVICE_WIDTH - FieldWidth)/2
#define FirstElementY 80
#define Interval 45

@interface EmailSignUpViewController () <UITextFieldDelegate>

@end

@implementation EmailSignUpViewController

- (instancetype)init {
    self = [super init];
    if (self) {
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(notificationReceived:) name:@"addressCreated" object:nil];
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    newAddress = [[Address alloc] init];
    manager = [AFHTTPRequestOperationManager manager];
    manager.requestSerializer = [AFJSONRequestSerializer serializer];
    [self.navigationItem setTitle:@"회원가입"];
    [self.view setBackgroundColor:[UIColor whiteColor]];
    [self.navigationItem setRightBarButtonItem:[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self action:@selector(cancelButtonTouched)]];
    
    emailTextField = [self makeTextField];
    [emailTextField setTag:0];
    [emailTextField setFrame:[self makeRect:emailTextField]];
    [emailTextField setPlaceholder:@"example@naver.com"];
    [emailTextField setReturnKeyType:UIReturnKeyNext];
    
    passwordTextField = [self makeTextField];
    [passwordTextField setTag:1];
    [passwordTextField setFrame:[self makeRect:passwordTextField]];
    [passwordTextField setPlaceholder:@"●●●●●●"];
    [passwordTextField setSecureTextEntry:YES];
    [passwordTextField setReturnKeyType:UIReturnKeyNext];
    
    passwordCheckTextField = [self makeTextField];
    [passwordCheckTextField setTag:2];
    [passwordCheckTextField setFrame:[self makeRect:passwordCheckTextField]];
    [passwordCheckTextField setPlaceholder:@"●●●●●●"];
    [passwordCheckTextField setSecureTextEntry:YES];
    [passwordCheckTextField setReturnKeyType:UIReturnKeyNext];
    
    contactTextField = [self makeTextField];
    [contactTextField setTag:3];
    [contactTextField setFrame:[self makeRect:contactTextField]];
    [contactTextField setPlaceholder:@"01012345678 (선택)"];
    [contactTextField setReturnKeyType:UIReturnKeyNext];
    [contactTextField setKeyboardType:UIKeyboardTypePhonePad];
    
    addressButton = [[UIButton alloc] init];
    [addressButton setTag:4];
    [addressButton setFrame:[self makeRect:addressButton]];
    [addressButton.layer setCornerRadius:15.0f];
    [addressButton setBackgroundColor:UltraLightGray];
    [addressButton setTitle:@"주소 입력을 위해 터치해주세요 (선택)" forState:UIControlStateNormal];
    [addressButton.titleLabel setFont:[UIFont systemFontOfSize:16.0f]];
    [addressButton setTitleColor:[UIColor lightGrayColor] forState:UIControlStateNormal];
    [addressButton setContentHorizontalAlignment:UIControlContentHorizontalAlignmentLeft];
    [addressButton setContentEdgeInsets:UIEdgeInsetsMake(0, 10, 0, 10)];
    [addressButton addTarget:self action:@selector(addressTextFieldTouched) forControlEvents:UIControlEventTouchUpInside];
    [addressButton.titleLabel setAdjustsFontSizeToFitWidth:YES];
    [addressButton.titleLabel setLineBreakMode:NSLineBreakByClipping];
    
    termsLabel = [[UILabel alloc] initWithFrame:CGRectMake((DEVICE_WIDTH - 280) / 2, 305, 280, 35)];
    [termsLabel setText:@"가입과 함께 약관에 동의하신 것으로 간주합니다."];
    [termsLabel setFont:[UIFont systemFontOfSize:12.0f]];
    [termsLabel setTextColor:[UIColor grayColor]];
    [termsLabel setTextAlignment:NSTextAlignmentLeft];
    
    termsButton = [[UIButton alloc] initWithFrame:CGRectMake(260, 312, 44, 22)];
    [termsButton setTitle:@"약관보기" forState:UIControlStateNormal];
    [termsButton setTitleColor:[UIColor grayColor] forState:UIControlStateNormal];
    [termsButton.titleLabel setFont:[UIFont systemFontOfSize:12.0f]];
    [termsButton addTarget:self action:@selector(presentTermsViewController) forControlEvents:UIControlEventTouchUpInside];
    
    signUpButton = [[UIButton alloc] init];
    [signUpButton setTag:6];
    [signUpButton setFrame:[self makeRect:signUpButton]];
    [signUpButton setBackgroundColor:CleanBasketMint];
    [signUpButton setTitle:@"가입하기" forState:UIControlStateNormal];
    [signUpButton setTitle:@"반가워요!" forState:UIControlStateHighlighted];
    [signUpButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [signUpButton setTitleColor:[UIColor blackColor] forState:UIControlStateHighlighted];
    [signUpButton.layer setCornerRadius:15.0f];
    [signUpButton addTarget:self action:@selector(didTouchSignUp) forControlEvents:UIControlEventTouchUpInside];
    
    [emailTextField setText:@"test1@test.com"];
    [passwordTextField setText:@"1234"];
    [passwordCheckTextField setText:@"1234"];
    
    [self.view addSubview:emailTextField];
    [self.view addSubview:passwordTextField];
    [self.view addSubview:passwordCheckTextField];
    [self.view addSubview:contactTextField];
    [self.view addSubview:addressButton];
    [self.view addSubview:termsLabel];
    [self.view addSubview:signUpButton];
    [self.view addSubview:termsButton];
}

- (void) notificationReceived:(NSNotification*)noti {
    // AddressInputViewController에서 사용자가 주소 작성 후 확인 버튼을 누른 경우,
    if ([[noti name] isEqualToString:@"addressCreated"]) {
        newAddress = [[noti userInfo] valueForKey:@"data"];
        [addressButton setTitle:[newAddress fullAddress] forState:UIControlStateNormal];
        [addressButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void) cancelButtonTouched {
    [self dismissViewControllerAnimated:YES completion:nil];
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

- (CGRect) makeRect: (UIView*)view {
    return CGRectMake(CenterX, FirstElementY + Interval * [view tag], FieldWidth, FieldHeight);
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event{
    [self.view endEditing:YES];
    [super touchesBegan:touches withEvent:event];
}

- (void)didTouchSignUp {
    
    if ([emailTextField.text length] == 0) {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:nil message:@"이메일주소를 입력해주세요." delegate:self cancelButtonTitle:@"닫기" otherButtonTitles:nil, nil];
        [alertView show];
        return;
    }
    
    if ([passwordTextField.text length] == 0) {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:nil message:@"비밀번호를 입력해주세요." delegate:self cancelButtonTitle:@"닫기" otherButtonTitles:nil, nil];
        [alertView show];
        return;
    }
    
    if ( [passwordCheckTextField.text length] == 0 ) {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:nil message:@"비밀번호를 한 번 더 입력해주세요." delegate:self cancelButtonTitle:@"닫기" otherButtonTitles:nil, nil];
        [alertView show];
        return;
    }
    
    if (!([[passwordTextField text] isEqual:[passwordCheckTextField text]])) {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:nil
                                                            message:@"비밀번호가 서로 일치하지 않습니다."
                                                           delegate:self
                                                  cancelButtonTitle:@"닫기"
                                                  otherButtonTitles:nil, nil];
        [alertView show];
        return;
    }
    
    NSDictionary *parameters = @{
                                 @"email": [emailTextField text],
                                 @"password": [passwordTextField text],
                                 @"phone":[contactTextField text],
                                 @"address":[newAddress valueForKey:@"address"],
                                 @"addr_number":[newAddress valueForKey:@"addr_number"],
                                 @"addr_building":[newAddress valueForKey:@"addr_building"],
                                 @"addr_remainder":[newAddress valueForKey:@"addr_remainder"]
                                 };
    NSLog(@"\r[SIGNUP WITH]\r%@", parameters);
    /*
    if (newAddress != nil) {
        [parameters setValue:[newAddress valueForKey:@"address"] forKey:@"address"];
        [parameters setValue:[newAddress valueForKey:@"addr_number"] forKey:@"addr_number"];
        [parameters setValue:[newAddress valueForKey:@"addr_building"] forKey:@"addr_building"];
        [parameters setValue:[newAddress valueForKey:@"addr_remainder"] forKey:@"addr_remainder"];
    }
     */
    
    [manager POST:@"http://cleanbasket.co.kr/member/join" parameters:parameters
          success:^(AFHTTPRequestOperation *operation, id responseObject) {
              NSNumber *value = responseObject[@"constant"];
              switch ([value integerValue]) {
                  case 1:
                  {
                      [self dismissViewControllerAnimated:YES completion:^{
                          [[NSNotificationCenter defaultCenter] postNotificationName:@"signUpComplete" object:self userInfo:parameters];
                          [emailTextField setText:@""];
                          [passwordTextField setText:@""];
                          [passwordCheckTextField setText:@""];
                          [contactTextField setText:@""];
                      }];
                  }
                      break;
                  case 16:
                  {
                      UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:nil
                                                                          message:@"해당 이메일 주소는 이미 존재합니다."
                                                                         delegate:self
                                                                cancelButtonTitle:@"닫기"
                                                                otherButtonTitles:nil, nil];
                      [alertView show];
                      break;
                  }
                      
                  default:
                      break;
              }
          } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
              NSLog(@"Error: %@", error);
          }];
}



- (BOOL)textFieldShouldReturn:(UITextField*)textField;
{
    NSInteger nextTag = textField.tag + 1;
    // Try to find next responder
    UIResponder* nextResponder = [textField.superview viewWithTag:nextTag];
    if (nextResponder) {
        // Found next responder, so set it.
        [nextResponder becomeFirstResponder];
    } else {
        // Not found, so remove keyboard.
        [textField resignFirstResponder];
    }
    return NO; // We do not want UITextField to insert line-breaks.
}

- (void) addressTextFieldTouched {
    AddressInputViewController *addressInputViewController = [[AddressInputViewController alloc] init];
    [self.navigationController pushViewController:addressInputViewController animated:YES];
}

- (void) presentTermsViewController {
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:nil message:@"Terms" delegate:self cancelButtonTitle:@"닫기" otherButtonTitles:nil, nil];
    [alertView show];
}

@end
