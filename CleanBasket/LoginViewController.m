//
//  MainViewController.m
//  CleanBasket
//
//  Created by Wonhyo Yi on 2014. 10. 3..
//  Copyright (c) 2014년 WashAppKorea. All rights reserved.
//

#import "LoginViewController.h"
#import "DTOManager.h"
#import "User.h"
#import "Keychain.h"
#import "OrderViewController.h"
#import "EmailSignUpViewController.h"
#import "FindPasswordViewController.h"
#import "AppDelegate.h"
#import "AFNetworking.h"
#import "MBProgressHUD.h"
#import "CBConstants.h"

#define CenterX (DEVICE_WIDTH - kFieldWidth)/2
static const CGFloat kFieldHeight = 38.0f;
static const CGFloat kFieldWidth = 200.0f;
static const CGFloat kFirstYPosition = 100.0f;
static CGFloat kSpacing;

@interface LoginViewController () <UITextFieldDelegate> {
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

@implementation LoginViewController

- (instancetype)init {
    self = [super init];
    if (self) {
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(didRecieveNotification:)
                                                     name:@"signUpComplete"
                                                   object:nil];
        if (isiPhone5)
        {
            kSpacing = 63.0f;
        }
        else
        {
            kSpacing = 53.0f;
        }
    }
    
    return self;
}

- (void) didRecieveNotification:(NSNotification *)noti {
    if ([[noti name] isEqualToString:@"signUpComplete"]) {
        [emailTextField setText:[noti.userInfo objectForKey:@"email"]];
        [passwordTextField setText:[noti.userInfo objectForKey:@"password"]];
        [self signIn];
    }
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self.navigationItem setTitle:@"크린바스켓"];
    [self.view setBackgroundColor:[UIColor whiteColor]];
    manager = [AFHTTPRequestOperationManager manager];
    dtoManager = [DTOManager defaultManager];
    emailTextField = [[UITextField alloc] initWithFrame:CGRectMake(CenterX, kFirstYPosition, kFieldWidth, kFieldHeight)];
    [emailTextField setDelegate:self];
    [emailTextField setPlaceholder:@"mail@cleanbasket.co.kr"];
    [emailTextField setBackgroundColor:UltraLightGray];
    [emailTextField setTextColor:[UIColor blackColor]];
    [emailTextField setBorderStyle:UITextBorderStyleNone];
    [emailTextField setTextAlignment:NSTextAlignmentLeft];
    [emailTextField setClearButtonMode:UITextFieldViewModeWhileEditing];
    [emailTextField setReturnKeyType:UIReturnKeyNext];
    [emailTextField setAutocapitalizationType:UITextAutocapitalizationTypeNone];
    [emailTextField setAutocorrectionType:UITextAutocorrectionTypeNo];
    [emailTextField.layer setCornerRadius:15.0f];
    UIView *emailPaddingView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 10, 20)];
    [emailTextField setLeftView:emailPaddingView];
    [emailTextField setLeftViewMode:UITextFieldViewModeAlways];
    [emailTextField setTag:0];
    [emailTextField setAdjustsFontSizeToFitWidth:YES];
    
    passwordTextField = [[UITextField alloc] initWithFrame:CGRectMake(CenterX, kFirstYPosition + kSpacing, kFieldWidth, kFieldHeight)];
    [passwordTextField setDelegate:self];
    [passwordTextField setPlaceholder:@"●●●●●●"];
    [passwordTextField setBackgroundColor:UltraLightGray];
    [passwordTextField setTextColor:[UIColor blackColor]];
    [passwordTextField setBorderStyle:UITextBorderStyleNone];
    [passwordTextField setTextAlignment:NSTextAlignmentLeft];
    [passwordTextField setClearButtonMode:UITextFieldViewModeWhileEditing];
    [passwordTextField setReturnKeyType:UIReturnKeyGo];
    [passwordTextField setAutocapitalizationType:UITextAutocapitalizationTypeNone];
    [passwordTextField setAutocorrectionType:UITextAutocorrectionTypeNo];
    [passwordTextField setSecureTextEntry:YES];
    [passwordTextField.layer setCornerRadius:15.0f];
    UIView *passPaddingView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 10, 20)];
    [passwordTextField setLeftView:passPaddingView];
    [passwordTextField setLeftViewMode:UITextFieldViewModeAlways];
    [passwordTextField setTag:1];
    
    
    signInButton = [[UIButton alloc] initWithFrame:CGRectMake(CenterX, kFirstYPosition + kSpacing * 2, kFieldWidth, kFieldHeight)];
    [signInButton setBackgroundColor:CleanBasketMint];
    [signInButton setTitle:@"로그인" forState:UIControlStateNormal];
    [signInButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [signInButton setTitleColor:[UIColor blackColor] forState:UIControlStateHighlighted];
    [signInButton.layer setCornerRadius:15.0f];
    [signInButton addTarget:self action:@selector(signIn) forControlEvents:UIControlEventTouchUpInside];
    
    orLabel = [[UILabel alloc] initWithFrame:CGRectMake(CenterX, kFirstYPosition + kSpacing * 3, kFieldWidth, kFieldHeight)];
    [orLabel setText:@"처음 이용하시나요?"];
    [orLabel setTextAlignment:NSTextAlignmentCenter];
    [orLabel setTextColor:[UIColor grayColor]];
    
    signUpButton = [[UIButton alloc] initWithFrame:CGRectMake(CenterX, kFirstYPosition + kSpacing * 4, kFieldWidth, kFieldHeight)];
    [signUpButton setBackgroundColor:CleanBasketRed];
    [signUpButton setTitle:@"이메일 가입" forState:UIControlStateNormal];
    [signUpButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [signUpButton setTitleColor:[UIColor blackColor] forState:UIControlStateHighlighted];
    [signUpButton.layer setCornerRadius:15.0f];
    [signUpButton addTarget:self action:@selector(emailSignUpTouched) forControlEvents:UIControlEventTouchUpInside];
    
    fbSignUpButton = [[UIButton alloc] initWithFrame:CGRectMake(CenterX, kFirstYPosition + kSpacing * 5, kFieldWidth, kFieldHeight)];
    [fbSignUpButton setBackgroundColor:FacebookBlue];
    [fbSignUpButton setTitle:@"페이스북 연결하기" forState:UIControlStateNormal];
    [fbSignUpButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [fbSignUpButton setTitleColor:[UIColor blackColor] forState:UIControlStateHighlighted];
    [fbSignUpButton.layer setCornerRadius:15.0f];
    
    iForgotButton = [[UIButton alloc] initWithFrame:CGRectMake(CenterX, kFirstYPosition + kSpacing * 6, kFieldWidth, kFieldHeight)];
    [iForgotButton setBackgroundColor:[UIColor whiteColor]];
    [iForgotButton setTitleColor:[UIColor grayColor] forState:UIControlStateNormal];
    [iForgotButton setTitle:@"비밀번호 찾기" forState:UIControlStateNormal];
    [iForgotButton.titleLabel setFont:[UIFont systemFontOfSize:14.0]];
    [iForgotButton setTitleColor:CleanBasketMint forState:UIControlStateHighlighted];
    [iForgotButton.layer setCornerRadius:15.0f];
    [iForgotButton addTarget:self action:@selector(iForgotTouched) forControlEvents:UIControlEventTouchUpInside];
    
    [self.view addSubview:emailTextField];
    [self.view addSubview:passwordTextField];
    [self.view addSubview:signInButton];
    [self.view addSubview:orLabel];
    [self.view addSubview:signUpButton];
    [self.view addSubview:iForgotButton];
    
    if ([[User allObjects] count] > 0) {
        User *latestUser = [[User allObjects] objectAtIndex:0];
        [emailTextField setText:[latestUser email]];
        Keychain *keychain = [[Keychain alloc] initWithService:APP_NAME_STRING withGroup:nil];
        NSData *passwordData = [keychain find:[latestUser email]];
        if (passwordData) {
            [passwordTextField setText:[[NSString alloc] initWithData:passwordData encoding:NSUTF8StringEncoding]];
            [self signIn];
        } else {
            NSLog(@"Keychain data not found");
        }
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event{
    [self.view endEditing:YES];
    [super touchesBegan:touches withEvent:event];
}

-(BOOL)textFieldShouldReturn:(UITextField*)textField;
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
        [self signIn];
    }
    return NO; // We do not want UITextField to insert line-breaks.
}

- (void) signIn {
    NSMutableDictionary *parameters = [NSMutableDictionary dictionaryWithDictionary: @{
                                                                                       @"email": [emailTextField text],
                                                                                       @"password": [passwordTextField text],
                                                                                       @"remember" : @"true",
                                                                                       @"regid":@""
                                                                                       }];

    manager.requestSerializer = [AFHTTPRequestSerializer serializer];
    manager.responseSerializer = [AFJSONResponseSerializer serializerWithReadingOptions:NSJSONReadingMutableContainers];
    
    [MBProgressHUD showHUDAddedTo:self.view animated:YES labelText:@"로그인 중"];
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_LOW, 0), ^{
        [manager POST:@"https://www.cleanbasket.co.kr/auth" parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
            NSNumber *value = responseObject[@"constant"];
            switch ([value integerValue]) {
                    // 회원정보 일치: 로그인 성공
                case CBServerConstantSuccess:
                {
                    AppDelegate *appDelegate = [[UIApplication sharedApplication] delegate];
                    [self.navigationController presentViewController:appDelegate.tabNavController animated:YES completion:^{
                        [emailTextField setText:@""];
                        [passwordTextField setText:@""];
                    }];
                    // 로그인 성공 시, 세션 기반으로 회원 정보를 받아온다.
                    manager.requestSerializer = [AFJSONRequestSerializer serializer];
                    [manager POST:@"https://www.cleanbasket.co.kr/member" parameters:@{} success:^(AFHTTPRequestOperation *operation, id responseObject) {
                        NSDictionary *jsonDict =
                        [NSJSONSerialization JSONObjectWithData: [responseObject[@"data"] dataUsingEncoding:NSUTF8StringEncoding]
                                                        options: NSJSONReadingMutableContainers
                                                          error: nil];
                        
                        // 현재 User ID, PASSWORD를 Keychain에 저장
                        Keychain *keychain = [[Keychain alloc]initWithService:APP_NAME_STRING withGroup:nil];
                        NSString *emailAsKey = [emailTextField text];
                        NSData *passwordAsValue = [[passwordTextField text] dataUsingEncoding:NSUTF8StringEncoding];
                        if ([keychain insert:emailAsKey :passwordAsValue]) {
                            NSLog(@"data added to keychain: %@ %@", emailAsKey, passwordAsValue);
                        }
                        // 실패한 경우 업데이트 시도
                        else if ([keychain update:emailAsKey :passwordAsValue]) {
                            NSLog(@"failed to add. keychain data updated: %@ %@", emailAsKey, passwordAsValue);
                        } else {
                            NSLog(@"Failed update.");
                            NSLog(@"%@", [keychain find:emailAsKey]);
                        }
                        
                        RLMRealm *realm = [RLMRealm defaultRealm];
                        [realm beginWriteTransaction];
                        [realm deleteObjects:[User allObjects]];
                        [realm commitWriteTransaction];
                        
                        // 수신한 JSON 데이터를 기반으로, User 객체를 생성한다.
                        [dtoManager createUser:jsonDict];
                        
                    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                        dispatch_async(dispatch_get_main_queue(), ^{
                            [MBProgressHUD hideHUDForView:self.view animated:YES];
                            [self showHudMessage:@"네트워크 상태를 확인해주세요"];
                            NSLog(@"%@", error);
                        });
                    }];
                    
                    // 세션 기반으로 아이템 코드를 가져온다.
                    [manager POST:@"https://www.cleanbasket.co.kr/item/code" parameters:@{} success:^(AFHTTPRequestOperation *operation, id responseObject) {
                        //                    NSLog(@"[ITEM CODE]\r%@", [responseObject valueForKey:@"data"]);
                        
                        NSArray *jsonArray = [NSJSONSerialization JSONObjectWithData:[responseObject[@"data"] dataUsingEncoding:NSUTF8StringEncoding] options:NSJSONReadingMutableContainers error:nil];
                        
                        [dtoManager createItemCode:jsonArray];
                        
                    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                        dispatch_async(dispatch_get_main_queue(), ^{
                            [MBProgressHUD hideHUDForView:self.view animated:YES];
                            [self showHudMessage:@"네트워크 상태를 확인해주세요"];
                            NSLog(@"%@", error);
                        });
                    }];
                    
                    dispatch_async(dispatch_get_main_queue(), ^{
                        [MBProgressHUD hideHUDForView:self.view animated:YES];
                    });
                    // 세션 기반으로 쿠폰들을 가져온다.
                    [manager POST:@"https://www.cleanbasket.co.kr/member/coupon" parameters:@{} success:^(AFHTTPRequestOperation *operation, id responseObject) {
                        
                        NSArray *jsonArray = [NSJSONSerialization JSONObjectWithData:[responseObject[@"data"] dataUsingEncoding:NSUTF8StringEncoding] options:NSJSONReadingMutableContainers error:nil];
                        [dtoManager createCoupon:jsonArray];
                    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                        dispatch_async(dispatch_get_main_queue(), ^{
                            [MBProgressHUD hideHUDForView:self.view animated:YES];
                        });
                        NSLog(@"%@", error);
                    }];
                    
                    break;
                }
                    // 이메일 주소 없음
                case CBServerConstantEmailError:
                {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        [MBProgressHUD hideHUDForView:self.view animated:YES];
                        [self showHudMessage:@"이메일 주소를 다시 확인해주세요."];
                    });
                    break;
                }
                    // 이메일 주소에 대한 비밀번호 다름
                case CBServerConstantPasswordError:
                {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        [MBProgressHUD hideHUDForView:self.view animated:YES];
                        [self showHudMessage:@"비밀번호를 다시 확인해주세요."];
                    });
                    break;
                }
                    // 정지 계정
                case CBServerConstantAccountDisabled :
                {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        [MBProgressHUD hideHUDForView:self.view animated:YES];
                        [self showHudMessage:@"해당 계정은 사용하실 수 없습니다."];
                    });
                    break;
                }
            }
            
        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
            NSLog(@"Error: %@", error);
            dispatch_async(dispatch_get_main_queue(), ^{
                [MBProgressHUD hideHUDForView:self.view animated:YES];
            });
            [self loginFailed];
        }];
    });
    
    // Email & Password 기반의 로그인 검증
}

- (void) loginFailed {
    [self showHudMessage:@"네트워크 연결 상태를 확인해주세요"];
    return;
}

- (void) emailSignUpTouched {
    EmailSignUpViewController *emailSignUpViewController = [[EmailSignUpViewController alloc] init];
    UINavigationController *navController = [[UINavigationController alloc] initWithRootViewController:emailSignUpViewController];
    [self.navigationController presentViewController:navController animated:YES completion:nil];
}

- (void) iForgotTouched {
    FindPasswordViewController *findPassViewController = [[FindPasswordViewController alloc] init];
    UINavigationController *navController = [[UINavigationController alloc] initWithRootViewController:findPassViewController];
    [self.navigationController presentViewController:navController animated:YES completion:nil];
}

- (void) showHudMessage:(NSString*)message {
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.navigationController.view animated:YES labelText:nil];
    
    // Configure for text only and offset down
    hud.mode = MBProgressHUDModeText;
    hud.labelText = message;
    [hud setLabelFont:[UIFont systemFontOfSize:14.0f]];
    hud.margin = 10.f;
    hud.removeFromSuperViewOnHide = YES;
    [hud hide:YES afterDelay:1];
    return;
}

@end
