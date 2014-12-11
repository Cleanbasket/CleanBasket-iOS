//
//  EmailSignUpViewController.m
//  CleanBasket
//
//  Created by Wonhyo Yi on 2014. 10. 3..
//  Copyright (c) 2014년 WashAppKorea. All rights reserved.
//

#import "EmailSignUpViewController.h"
#import "CBConstants.h"
#import "AddressInputViewController.h"
#import "TermsViewController.h"
#import "AFNetworking.h"
#import "AppDelegate.h"
#import "Address.h"
#import "MBProgressHUD.h"

#define CenterX (DEVICE_WIDTH - kFieldWidth)/2

static const CGFloat kFieldHeight = 35.0f;
static const CGFloat kFieldWidth = 260.0f;
static const CGFloat kFirstYPosition = 80.0f;
static CGFloat kSpacing;

@interface EmailSignUpViewController () <UITextFieldDelegate> {
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
    NSDictionary *parameters;
}

@end

@implementation EmailSignUpViewController

- (instancetype)init {
    self = [super init];
    if (self) {
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(notificationReceived:) name:@"addressCreated" object:nil];
        if (isiPhone5) {
            kSpacing = 55.0f;
        } else {
            kSpacing = 45.0f;
        }
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
    
    termsLabel = [[UILabel alloc] initWithFrame:CGRectMake((DEVICE_WIDTH - 280) / 2, addressButton.frame.origin.y + kSpacing, 280, 35)];
    [termsLabel setText:@"가입과 함께 약관에 동의하신 것으로 간주합니다."];
    [termsLabel setFont:[UIFont systemFontOfSize:12.0f]];
    [termsLabel setTextColor:[UIColor grayColor]];
    [termsLabel setTextAlignment:NSTextAlignmentLeft];
    
    termsButton = [[UIButton alloc] initWithFrame:CGRectMake(termsLabel.frame.origin.x + 240, termsLabel.frame.origin.y, 44, 35)];
    [termsButton setTitle:@"약관보기" forState:UIControlStateNormal];
    [termsButton setTitleColor:[UIColor grayColor] forState:UIControlStateNormal];
    [termsButton.titleLabel setFont:[UIFont systemFontOfSize:12.0f]];
    [termsButton addTarget:self action:@selector(presentTermsViewController) forControlEvents:UIControlEventTouchUpInside];
    
    signUpButton = [[UIButton alloc] init];
    [signUpButton setTag:6];
    [signUpButton setFrame:[self makeRect:signUpButton]];
    [signUpButton setBackgroundColor:CleanBasketMint];
    [signUpButton setTitle:@"가입하기" forState:UIControlStateNormal];
    [signUpButton setTitle:@"반가워요" forState:UIControlStateHighlighted];
    [signUpButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [signUpButton setTitleColor:[UIColor blackColor] forState:UIControlStateHighlighted];
    [signUpButton.layer setCornerRadius:15.0f];
    [signUpButton addTarget:self action:@selector(didTouchSignUp) forControlEvents:UIControlEventTouchUpInside];
    
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
    return CGRectMake(CenterX, kFirstYPosition + kSpacing * [view tag], kFieldWidth, kFieldHeight);
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event{
    [self.view endEditing:YES];
    [super touchesBegan:touches withEvent:event];
}

- (void)didTouchSignUp {
    if ([emailTextField.text length] < 1 || [self isValidEmail:emailTextField.text] == NO) {
        [self showHudMessage:@"올바른 이메일 주소를 입력해주세요." delay:1];
        return;
    }
    
    if ([passwordTextField.text length] == 0) {
        [self showHudMessage:@"비밀번호를 입력해주세요." delay:1];
        return;
    }
    
    if ( [passwordCheckTextField.text length] == 0 ) {
        [self showHudMessage:@"비밀번호를 한번 더 입력해주세요." delay:1];
        return;
    }
    
    if (!([[passwordTextField text] isEqual:[passwordCheckTextField text]])) {
        [self showHudMessage:@"비밀번호가 서로 일치하지 않습니다." delay:1];
        return;
    }
    
    if ([passwordTextField.text length] < 6) {
        [self showHudMessage:@"보안을 위해 비밀번호는 6자 이상으로 해주세요!" delay:1];
        return;
    }
    
    if ([passwordTextField.text length] > 20) {
        [self showHudMessage:@"비밀번호가 지나치게 길지 않나요?" delay:1];
        return;
    }
    
    [MBProgressHUD showHUDAddedTo:self.view animated:YES labelText:@"로그인 중"];
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_LOW, 0), ^{
        parameters = @{
                       @"email": [emailTextField text],
                       @"password": [passwordTextField text],
                       @"phone":[contactTextField text],
                       @"address":[newAddress valueForKey:@"address"],
                       @"addr_number":[newAddress valueForKey:@"addr_number"],
                       @"addr_building":[newAddress valueForKey:@"addr_building"],
                       @"addr_remainder":[newAddress valueForKey:@"addr_remainder"]
                       };
        
        [manager POST:@"http://cleanbasket.co.kr/member/join" parameters:parameters
              success:^(AFHTTPRequestOperation *operation, id responseObject) {
                  NSNumber *value = responseObject[@"constant"];
                  switch ([value integerValue]) {
                      case CBServerConstantSuccess:
                      {
                          dispatch_async(dispatch_get_main_queue(), ^{
                              [MBProgressHUD hideHUDForView:self.view animated:YES];
                              [self showHudMessage:@"회원가입을 축하드립니다 :)" delay:2];
                              [self performSelector:@selector(signupComplete) withObject:nil afterDelay:3];
                          });
                      }
                          break;
                      case CBServerConstantsAccountDuplication:
                      {
                          dispatch_async(dispatch_get_main_queue(), ^{
                              [MBProgressHUD hideHUDForView:self.view animated:YES];
                              [self showHudMessage:@"해당 이메일 주소는 이미 존재합니다." delay:1];
                          });
                          break;
                      }
                  }
              } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                  dispatch_async(dispatch_get_main_queue(), ^{
                      [MBProgressHUD hideHUDForView:self.view animated:YES];
                      [self showHudMessage:@"네트워크 상태를 확인해주세요" delay:1];
                      NSLog(@"%@", error);
                  });
              }];
    });
    
}

- (void) signupComplete {
    [self dismissViewControllerAnimated:YES completion:^{
        [[NSNotificationCenter defaultCenter] postNotificationName:@"signUpComplete" object:self userInfo:parameters];
        [emailTextField setText:@""];
        [passwordTextField setText:@""];
        [passwordCheckTextField setText:@""];
        [contactTextField setText:@""];
    }];
}

-(BOOL) isValidEmail:(NSString *)checkString
{
    BOOL stricterFilter = NO;
    NSString *stricterFilterString = @"[A-Z0-9a-z\\._%+-]+@([A-Za-z0-9-]+\\.)+[A-Za-z]{2,4}";
    NSString *laxString = @".+@([A-Za-z0-9-]+\\.)+[A-Za-z]{2}[A-Za-z]*";
    NSString *emailRegex = stricterFilter ? stricterFilterString : laxString;
    NSPredicate *emailTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", emailRegex];
    return [emailTest evaluateWithObject:checkString];
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
    TermsViewController *termsViewController = [[TermsViewController alloc] init];
    [self.navigationController pushViewController:termsViewController animated:YES];
}

- (void) showHudMessage:(NSString*)message delay:(int)delay;{
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.navigationController.view animated:YES labelText:nil];
    
    // Configure for text only and offset down
    hud.mode = MBProgressHUDModeText;
    hud.labelText = message;
    [hud setLabelFont:[UIFont systemFontOfSize:14.0f]];
    
    hud.margin = 10.f;
    hud.removeFromSuperViewOnHide = YES;
    [hud hide:YES afterDelay:delay];
    return;
}

@end
