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

@property (weak, nonatomic) IBOutlet SignTextField *emailTextField;
@property (weak, nonatomic) IBOutlet SignTextField *pwTextField;

@end

@implementation SignInViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}


- (void)awakeFromNib {

    [self setModalPresentationStyle:UIModalPresentationCustom];
    [self setNeedsStatusBarAppearanceUpdate];
}

- (IBAction)login:(id)sender {
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];



//    manager.requestSerializer = [AFHTTPRequestSerializer serializer];
//    manager.responseSerializer = [AFJSONResponseSerializer serializerWithReadingOptions:NSJSONReadingMutableContainers];

//
    manager.responseSerializer = [AFJSONResponseSerializer serializer];
    manager.responseSerializer.acceptableContentTypes = [manager.responseSerializer.acceptableContentTypes setByAddingObject:@"text/html"];
    manager.requestSerializer = [AFJSONRequestSerializer serializer];
////
//    [manager.requestSerializer setValue:@"application/json" forHTTPHeaderField:@"Accept"];
//    [manager.requestSerializer setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
//
    NSDictionary *parameters = @{@"email": _emailTextField.text,
                                 @"password": _pwTextField.text,
                                 @"remember":@"true"};

//    NSString *authUrl = [NSString stringWithFormat:@"%@auth",REAL_SERVER_URL_STRING];
    
    [manager POST:@"http://www.cleanbasket.co.kr/auth" parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSLog(@"JSON: %@", responseObject );


        UIStoryboard *sb = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
        UIViewController *mainTBC = [sb instantiateViewControllerWithIdentifier:@"MainTBC"];

        AppDelegate *appDelegate = [[UIApplication sharedApplication] delegate];

        [appDelegate.window setRootViewController:mainTBC];


//        _emailTextField.text = responseObject;

    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"Error: %@", error);
    }];
}

- (IBAction)goToSignUp:(id)sender {
}

- (IBAction)goToFindPw:(id)sender {
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {


    UITouch  *touch = [touches anyObject];
    if ([touch view] == self.view){

        NSLog(@"타치");
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
