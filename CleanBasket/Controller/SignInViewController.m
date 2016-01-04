//
//  SignInViewController.m
//  CleanBasket
//
//  Created by 이상진 on 2015. 12. 14..
//  Copyright © 2015년 WashappKorea. All rights reserved.
//

#import "SignInViewController.h"
#import "AFNetworking/AFNetworking.h"
#import "SignTextField.h"
#import "CBConstants.h"
#import "AppDelegate.h"
#import <Realm/Realm.h>
#import "User.h"
#import <SVProgressHUD/SVProgressHUD.h>

@interface SignInViewController ()

@property (weak, nonatomic) IBOutlet UIView *signInView;
@property (weak, nonatomic) IBOutlet UIView *signUpView;
@property (weak, nonatomic) IBOutlet SignTextField *emailTextField;
@property (weak, nonatomic) IBOutlet SignTextField *pwTextField;
@property (weak, nonatomic) IBOutlet UIView *findPasswordView;
@property (weak, nonatomic) IBOutlet UIButton *findPwBtn;

@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;


@end

@implementation SignInViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [_scrollView setContentSize:self.view.frame.size];

    
    NSLog(@"%f,%f",_scrollView.contentSize.width,_scrollView.contentSize.height);

    
    _emailTextField.delegate = self;
    _pwTextField.delegate = self;
}




- (void)awakeFromNib {
    [self setModalPresentationStyle:UIModalPresentationCustom];
    [self setNeedsStatusBarAppearanceUpdate];
}

- (IBAction)login:(id)sender {
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];



//    manager.requestSerializer = [AFHTTPRequestSerializer serializer];
//    manager.responseSerializer = [AFJSONResponseSerializer serializerWithReadingOptions:NSJSONReadingMutableContainers];

    manager.responseSerializer = [AFJSONResponseSerializer serializer];
    manager.responseSerializer.acceptableContentTypes = [manager.responseSerializer.acceptableContentTypes setByAddingObject:@"text/html"];
//    manager.requestSerializer = [AFJSONRequestSerializer serializer];
////
//    [manager.requestSerializer setValue:@"application/json" forHTTPHeaderField:@"Accept"];
//    [manager.requestSerializer setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
//
    NSDictionary *parameters = @{@"email": _emailTextField.text,
                                 @"password": _pwTextField.text};

//    NSString *authUrl = [NSString stringWithFormat:@"%@auth",REAL_SERVER_URL_STRING];

    [manager POST:@"http://www.cleanbasket.co.kr/auth" parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject) {

        [self.view endEditing:YES];



        NSNumber *value = responseObject[@"constant"];
        switch ([value integerValue]) {
                // 회원정보 일치: 로그인 성공
            case CBServerConstantSuccess:
            {


                NSError *jsonError;
                NSData *objectData = [responseObject[@"data"] dataUsingEncoding:NSUTF8StringEncoding];
                NSDictionary *data = [NSJSONSerialization JSONObjectWithData:objectData
                                                                   options:NSJSONReadingMutableContainers
                                                                     error:&jsonError];


                NSLog(@"%@",data);

                RLMRealm *realm = [RLMRealm defaultRealm];
                User *user = [[User alloc] initWithValue:@{@"email": _emailTextField.text,
                                                           @"password": _pwTextField.text,
                                                           @"uid":data[@"uid"]}];

                [realm beginWriteTransaction];
                [realm deleteObjects:[User allObjects]];
                [realm addObject:user];
                [realm commitWriteTransaction];


                UIStoryboard *sb = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
                UIViewController *mainTBC = [sb instantiateViewControllerWithIdentifier:@"MainTBC"];
                AppDelegate *appDelegate = [[UIApplication sharedApplication] delegate];
                [appDelegate.window setRootViewController:mainTBC];

                [self dismissVC:nil];

                break;
            }
                // 이메일 주소 없음
            case CBServerConstantEmailError:
            {
                dispatch_async(dispatch_get_main_queue(), ^{
                    [SVProgressHUD dismiss];
                    [SVProgressHUD showErrorWithStatus:@"이메일 주소를 다시 확인해주세요."];
                });
                break;
            }
                // 이메일 주소에 대한 비밀번호 다름
            case CBServerConstantPasswordError:
            {
                dispatch_async(dispatch_get_main_queue(), ^{
                    [SVProgressHUD dismiss];
                    [SVProgressHUD showErrorWithStatus:@"비밀번호를 다시 확인해주세요."];
                });
                break;
            }
                // 정지 계정
            case CBServerConstantAccountDisabled :
            {
                dispatch_async(dispatch_get_main_queue(), ^{

                    [SVProgressHUD dismiss];
                    [SVProgressHUD showErrorWithStatus:@"해당 계정은 사용하실 수 없습니다."];
                });
                break;
            }
        }





    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"Error: %@", error);
    }];
}


- (IBAction)signUp:(id)sender {
}

- (IBAction)findPassword:(id)sender {
}



- (IBAction)goToSignUp:(id)sender {


    [_signInView setHidden:YES];
    [_signUpView setHidden:NO];
    [_findPasswordView setHidden:YES];


}

- (IBAction)goToFindPw:(id)sender {

    [_signInView setHidden:YES];
    [_signUpView setHidden:YES];
    [_findPasswordView setHidden:NO];
}


- (IBAction)returnToSignIn:(id)sender {
    [_signInView setHidden:NO];
    [_signUpView setHidden:YES];
    [_findPasswordView setHidden:YES];
}


//Todo: 키보드처리(키보드 가리기, 뷰 올리기)
// 배경 터치하면 취소
- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {

    UITouch  *touch = [touches anyObject];
    if ([touch view] == self.scrollView){
        [self.view endEditing:YES];

    }


}
- (IBAction)dismissVC:(id)sender {
    
    [self dismissViewControllerAnimated:YES completion:nil];
}


- (BOOL)textFieldShouldReturn:(UITextField *)textField{

    if (textField == _emailTextField) {
        [_pwTextField becomeFirstResponder];
    } else {
        [self.view endEditing:YES];
    }

    return YES;
}

- (IBAction)resignOnTap:(id)sender {
    [self.view endEditing:YES];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (UIStatusBarStyle)preferredStatusBarStyle {
    return UIStatusBarStyleLightContent;
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self registNotification];
}

-(void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [self unregistNotification];
}

-(void) registNotification
{
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWasShown:)
                                                 name:UIKeyboardDidShowNotification
                                               object:nil];

    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillBeHidden:)
                                                 name:UIKeyboardWillHideNotification
                                               object:nil];
}

-(void) unregistNotification
{
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:UIKeyboardDidShowNotification object:nil];

    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:UIKeyboardDidHideNotification object:nil];
}


-(void)textFieldDidBeginEditing:(UITextField *)textField
{
//    self.activeField = textField;
//    self.activeField.delegate = self;
}

-(void)textFieldDidEndEditing:(UITextField *)textField
{
//    self.activeField = nil;
}

- (void)keyboardWasShown:(NSNotification*)aNotification
{
    NSDictionary* info = [aNotification userInfo];
    CGSize kbSize = [[info objectForKey:UIKeyboardFrameBeginUserInfoKey] CGRectValue].size;

    UIEdgeInsets contentInsets = UIEdgeInsetsMake(0.0, 0.0, kbSize.height, 0.0);
    self.scrollView.contentInset = contentInsets;
    self.scrollView.scrollIndicatorInsets = contentInsets;

    CGRect aRect = self.view.frame;
    aRect.size.height -= kbSize.height;

    if (!CGRectContainsPoint(aRect, _findPwBtn.frame.origin) ) {
        [self.scrollView setContentSize:CGSizeMake(CGRectGetWidth(self.scrollView.frame), CGRectGetHeight(self.scrollView.frame) + kbSize.height)];
        CGPoint scrollPoint = CGPointMake(0.0, _findPwBtn.frame.origin.y - aRect.size.height + _findPwBtn.frame.size.height);
        [self.scrollView setContentOffset:scrollPoint animated:YES];

        NSLog(@"%f,%f",_scrollView.contentSize.width,_scrollView.contentSize.height);

//        [self.scrollView scrollRectToVisible:_findPwBtn.frame animated:YES];
    }


//    if (!CGRectContainsPoint(aRect, buttonOrigin)){
//
//        CGPoint scrollPoint = CGPointMake(0.0, buttonOrigin.y - visibleRect.size.height + buttonHeight);
//
//        [self.scrollView setContentOffset:scrollPoint animated:YES];
//
//    }

}

- (void)keyboardWillBeHidden:(NSNotification*)aNotification
{
    [self.scrollView setContentOffset:CGPointZero animated:YES];
}

@end
