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

@interface SignInViewController ()

@property (weak, nonatomic) IBOutlet UIView *signInView;
@property (weak, nonatomic) IBOutlet UIView *signUpView;
@property (weak, nonatomic) IBOutlet SignTextField *emailTextField;
@property (weak, nonatomic) IBOutlet SignTextField *pwTextField;
@property (weak, nonatomic) IBOutlet UIView *findPasswordView;

@end

@implementation SignInViewController

- (void)viewDidLoad {
    [super viewDidLoad];
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
                                 @"password": _pwTextField.text,
                                 @"remember":@"true"};

//    NSString *authUrl = [NSString stringWithFormat:@"%@auth",REAL_SERVER_URL_STRING];
    
    [manager POST:@"http://www.cleanbasket.co.kr/auth" parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        [self.view endEditing:YES];
        
        NSLog(@"JSON: %@", responseObject );

        UIStoryboard *sb = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
        UIViewController *mainTBC = [sb instantiateViewControllerWithIdentifier:@"MainTBC"];
        AppDelegate *appDelegate = [[UIApplication sharedApplication] delegate];
        [appDelegate.window setRootViewController:mainTBC];

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
    if ([touch view] == self.view){
        [self dismissViewControllerAnimated:YES completion:nil];
    }


}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

- (UIStatusBarStyle)preferredStatusBarStyle {
    return UIStatusBarStyleLightContent;
}

@end
