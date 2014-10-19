//
//  MainViewController.m
//  CleanBasket
//
//  Created by Wonhyo Yi on 2014. 10. 3..
//  Copyright (c) 2014년 WashAppKorea. All rights reserved.
//

#import "LoginViewController.h"
#define FieldHeight 35
#define FieldWidth 200
#define CenterX (DEVICE_WIDTH - FieldWidth)/2
#define FirstElementY 100
#define Interval 53

@interface LoginViewController () <UITextFieldDelegate, UIAlertViewDelegate>

@end

@implementation LoginViewController

- (instancetype)init {
    self = [super init];
    if (self) {
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(didRecieveNotification:)
                                                     name:@"signUpComplete"
                                                   object:nil];
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
    emailTextField = [[UITextField alloc] initWithFrame:CGRectMake(CenterX, FirstElementY, FieldWidth, FieldHeight)];
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
    
    passwordTextField = [[UITextField alloc] initWithFrame:CGRectMake(CenterX, FirstElementY + Interval, FieldWidth, FieldHeight)];
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
    
    
    signInButton = [[UIButton alloc] initWithFrame:CGRectMake(CenterX, FirstElementY + Interval * 2, FieldWidth, FieldHeight)];
    [signInButton setBackgroundColor:CleanBasketMint];
    [signInButton setTitle:@"로그인" forState:UIControlStateNormal];
    [signInButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [signInButton setTitleColor:[UIColor blackColor] forState:UIControlStateHighlighted];
    [signInButton.layer setCornerRadius:15.0f];
    [signInButton addTarget:self action:@selector(signIn) forControlEvents:UIControlEventTouchUpInside];
    
    orLabel = [[UILabel alloc] initWithFrame:CGRectMake(CenterX, FirstElementY + Interval * 3, FieldWidth, FieldHeight)];
    [orLabel setText:@"처음 이용하시나요?"];
    [orLabel setTextAlignment:NSTextAlignmentCenter];
    [orLabel setTextColor:[UIColor grayColor]];
    
    signUpButton = [[UIButton alloc] initWithFrame:CGRectMake(CenterX, FirstElementY + Interval * 4, FieldWidth, FieldHeight)];
    [signUpButton setBackgroundColor:CleanBasketRed];
    [signUpButton setTitle:@"이메일 가입" forState:UIControlStateNormal];
    [signUpButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [signUpButton setTitleColor:[UIColor blackColor] forState:UIControlStateHighlighted];
    [signUpButton.layer setCornerRadius:15.0f];
    [signUpButton addTarget:self action:@selector(emailSignUpTouched) forControlEvents:UIControlEventTouchUpInside];
    
    fbSignUpButton = [[UIButton alloc] initWithFrame:CGRectMake(CenterX, FirstElementY + Interval * 5, FieldWidth, FieldHeight)];
    [fbSignUpButton setBackgroundColor:FacebookBlue];
    [fbSignUpButton setTitle:@"페이스북 연결하기" forState:UIControlStateNormal];
    [fbSignUpButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [fbSignUpButton setTitleColor:[UIColor blackColor] forState:UIControlStateHighlighted];
    [fbSignUpButton.layer setCornerRadius:15.0f];
    
    iForgotButton = [[UIButton alloc] initWithFrame:CGRectMake(CenterX, FirstElementY + Interval * 6, FieldWidth, FieldHeight)];
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
    [self.view addSubview:fbSignUpButton];
    [self.view addSubview:iForgotButton];
    
    [emailTextField setText:@"woonohyo@nhnnext.org"];
    [passwordTextField setText:@"p32759"];
    
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
    
    // Email & Password 기반의 로그인 검증
    [manager POST:@"http://cleanbasket.co.kr/auth" parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
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
                [manager POST:@"http://cleanbasket.co.kr/member" parameters:@{} success:^(AFHTTPRequestOperation *operation, id responseObject) {
                    NSDictionary *jsonDict =
                    [NSJSONSerialization JSONObjectWithData: [responseObject[@"data"] dataUsingEncoding:NSUTF8StringEncoding]
                                                    options: NSJSONReadingMutableContainers
                                                      error: nil];
                    // 수신한 JSON 데이터를 기반으로, User 객체를 생성한다.
                    [dtoManager createUser:jsonDict];
                    
                    // 세션 기반으로 회원의 주문 목록을 받아온다.
                    [manager POST:@"http://cleanbasket.co.kr/member/order" parameters:@{} success:^(AFHTTPRequestOperation *operation, id responseObject) {
                        NSDictionary *jsonDict =  [NSJSONSerialization JSONObjectWithData: [responseObject[@"data"] dataUsingEncoding:NSUTF8StringEncoding]
                                                                                  options: NSJSONReadingMutableContainers
                                                                                    error: nil];
                        NSLog(@"[ORDER LIST]\r%@", jsonDict);
                    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                        NSLog(@"%@", error);
                    }];
                } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                    NSLog(@"%@ %@", operation, error);
                    [self loginFailed];
                    return;
                }];
                
                // 세션 기반으로 아이템 코드를 가져온다.
                [manager POST:@"http://cleanbasket.co.kr/item/code" parameters:@{} success:^(AFHTTPRequestOperation *operation, id responseObject) {
                    NSLog(@"[ITEM CODE]\r%@", [responseObject valueForKey:@"data"]);
                    
                    NSArray *jsonArray = [NSJSONSerialization JSONObjectWithData:[responseObject[@"data"] dataUsingEncoding:NSUTF8StringEncoding] options:NSJSONReadingMutableContainers error:nil];
                    
                    [dtoManager createItemCode:jsonArray];
                    
                } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                    NSLog(@"%@", error);
                }];
                
                break;
            }
                // 이메일 주소 없음
            case CBServerConstantEmailError:
            {
                UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:nil
                                                                    message:@"이메일 주소를 다시 확인해주세요."
                                                                   delegate:self
                                                          cancelButtonTitle:@"닫기"
                                                          otherButtonTitles:nil, nil];
                [alertView show];
                break;
            }
                // 이메일 주소에 대한 비밀번호 다름
            case CBServerConstantPasswordError:
            {
                UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:nil
                                                                    message:@"비밀번호를 다시 확인해주세요."
                                                                   delegate:self
                                                          cancelButtonTitle:@"닫기"
                                                          otherButtonTitles:nil, nil];
                [alertView show];
                break;
            }
                // 정지 계정
            case CBServerConstantAccountDisabled :
            {
                UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:nil
                                                                    message:@"해당 계정은 사용하실 수 없습니다."
                                                                   delegate:self
                                                          cancelButtonTitle:@"닫기"
                                                          otherButtonTitles:nil, nil];
                [alertView show];
                break;
            }
            default:
                [self loginFailed];
                break;
        }
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"Error: %@", error);
        [self loginFailed];
    }];
}

- (void) loginFailed {
    UIAlertView *invalidEmailAlertView = [[UIAlertView alloc] initWithTitle:nil message:@"네트워크 연결 상태를 다시 한 번 확인해주세요." delegate:self cancelButtonTitle:@"닫기" otherButtonTitles:nil, nil];
    [invalidEmailAlertView show];
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

@end
