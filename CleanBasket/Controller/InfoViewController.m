//
//  InfoViewController.m
//  CleanBasket
//
//  Created by 이상진 on 2015. 12. 22..
//  Copyright © 2015년 WashappKorea. All rights reserved.
//

#import "InfoViewController.h"
#import "ModalViewController.h"
#import "AppDelegate.h"
#import "NoticeViewController.h"
#import "BottomBorderButton.h"
#import <AFNetworking/AFNetworking.h>
#import <SVProgressHUD/SVProgressHUD.h>
#import "CBConstants.h"

@interface InfoViewController () {
    AFHTTPRequestOperationManager *_manager;
}

@property (weak, nonatomic) IBOutlet UIView *phoneAuthView;
@property (weak, nonatomic) IBOutlet UIView *memberInfoView;
@property (weak, nonatomic) IBOutlet UITextField *emailTextField;
@property (weak, nonatomic) IBOutlet UITextField *phoneTextField;
@property (weak, nonatomic) IBOutlet UITextField *authCodeTextField;
@property (weak, nonatomic) IBOutlet UIImageView *classImageView;
@property (weak, nonatomic) IBOutlet UILabel *emailLabel;
@property (weak, nonatomic) IBOutlet UILabel *classNameLabel;
@property (weak, nonatomic) IBOutlet UILabel *classInfoLabel;
@property (weak, nonatomic) IBOutlet UILabel *mileageLabel;

@end

@implementation InfoViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    [self setTitle:NSLocalizedString(@"menu_label_information", @"내 정보")];
    
    [self setNeedsStatusBarAppearanceUpdate];

    _manager = [AFHTTPRequestOperationManager manager];

    
    [_phoneAuthView setHidden:YES];
    [_memberInfoView setHidden:YES];

    [self setTopView];
    
}


- (void)setTopView{
    
    _manager.responseSerializer = [AFJSONResponseSerializer serializer];
    _manager.responseSerializer.acceptableContentTypes = [_manager.responseSerializer.acceptableContentTypes setByAddingObject:@"text/html"];
    
    NSString *urlString = [NSString stringWithFormat:@"%@%@",CB_SERVER_URL,@"member/user"];
    [_manager GET:urlString
      parameters:nil
         success:^(AFHTTPRequestOperation *operation, id responseObject) {

             NSError *jsonError;
             NSData *objectData = [responseObject[@"data"] dataUsingEncoding:NSUTF8StringEncoding];

             NSDictionary *data = [NSJSONSerialization JSONObjectWithData:objectData
                                                                  options:NSJSONReadingMutableContainers
                                                                    error:&jsonError];


             //인증 데이터 있을 때
             if (data){

                 switch ([data[@"user_class"] integerValue]) {
                     case 0:
                         [_classImageView setImage:[UIImage imageNamed:@"ic_class_clean"]];
                         [_classNameLabel setText:NSLocalizedString(@"bronze_basket",nil)];
                         [_classInfoLabel setText:NSLocalizedString(@"bronze_info",nil)];
                         break;
                         
                     case 1:
                         [_classImageView setImage:[UIImage imageNamed:@"ic_class_silver"]];
                         [_classNameLabel setText:NSLocalizedString(@"silver_basket",nil)];
                         [_classInfoLabel setText:NSLocalizedString(@"silver_info",nil)];
                         break;
                         
                     case 2:
                         [_classImageView setImage:[UIImage imageNamed:@"ic_class_gold"]];
                         [_classNameLabel setText:NSLocalizedString(@"gold_basket",nil)];
                         [_classInfoLabel setText:NSLocalizedString(@"gold_info",nil)];
                         break;
                         
                     case 3:
                         [_classImageView setImage:[UIImage imageNamed:@"ic_class_love"]];
                         [_classNameLabel setText:NSLocalizedString(@"love_basket",nil)];
                         [_classInfoLabel setText:NSLocalizedString(@"love_info",nil)];
                         break;
                         
                     default:
                         break;
                 }
                 
                 [_emailLabel setText:data[@"email"]];

                 NSNumberFormatter *numberFormatter = [NSNumberFormatter new];
                 [numberFormatter setNumberStyle:NSNumberFormatterDecimalStyle];

                 NSString *mileageString = [numberFormatter stringFromNumber:data[@"mileage"]];
                 [_mileageLabel setText:[NSString stringWithFormat:@"%@ : %@",NSLocalizedString(@"mileage_available",nil),mileageString]];
                 
                 [_memberInfoView setHidden:NO];
                 [_phoneAuthView setHidden:YES];
             }
             else {

                 [_memberInfoView setHidden:YES];
                 [_phoneAuthView setHidden:NO];

             }



         } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                NSLog(@"Error: %@", error);
            }];


}




- (IBAction)getAuthCode:(id)sender {

    [self.view endEditing:YES];

    _manager.requestSerializer = [AFJSONRequestSerializer serializer];
    _manager.responseSerializer = [AFJSONResponseSerializer serializer];
    _manager.responseSerializer.acceptableContentTypes = [_manager.responseSerializer.acceptableContentTypes setByAddingObject:@"text/html"];


    if (!_phoneTextField.text.length){
        [SVProgressHUD showErrorWithStatus:NSLocalizedString(@"phone_empty",nil)];
        [_phoneTextField becomeFirstResponder];
        return;
    }

    
    NSString *urlString = [NSString stringWithFormat:@"%@%@",CB_SERVER_URL,@"code"];
    [_manager POST:urlString
       parameters:@{@"phone":_phoneTextField.text}
          success:^(AFHTTPRequestOperation *operation, id responseObject) {

              [SVProgressHUD showSuccessWithStatus:NSLocalizedString(@"authorization_code_sent",nil)];


          } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                NSLog(@"Error: %@,\n response : %@", error,operation.responseString);
            }];

}


- (IBAction)registAuthUser:(id)sender {
    if (!_emailTextField.text.length){
#warning Need LocalizedString
        [SVProgressHUD showErrorWithStatus:@"이메일을 입력해주세요"];
        [_emailTextField becomeFirstResponder];
        return;
    }
    else if (!_phoneTextField.text.length){
        [SVProgressHUD showErrorWithStatus:NSLocalizedString(@"phone_empty",nil)];
        [_phoneTextField becomeFirstResponder];
        return;
    }
   

    NSDictionary *parameters = @{
            @"email":_emailTextField.text,
            @"phone":_phoneTextField.text,
            @"code":_authCodeTextField.text,
            @"agent":@"iOS"
    };

    
    NSString *urlString = [NSString stringWithFormat:@"%@%@",CB_SERVER_URL,@"member/user"];
    [_manager POST:urlString
        parameters:parameters
           success:^(AFHTTPRequestOperation *operation, id responseObject) {


               if ([responseObject[@"constant"] integerValue] == 1){
                   [SVProgressHUD showSuccessWithStatus:NSLocalizedString(@"sign_up_success",nil)];
                   [self setTopView];
               }
               else{
#warning 인증 실패시 메시지
                   [SVProgressHUD showErrorWithStatus:responseObject[@"message"]];
               }


           } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                NSLog(@"Error: %@", error);
                [SVProgressHUD showErrorWithStatus:NSLocalizedString(@"network_error",nil)];
            }];


}








- (IBAction)showNoticeVC:(id)sender {
    
    NoticeViewController *noticeViewController = [NoticeViewController new];
//    [noticeViewController loadNotice];


    [self.navigationController pushViewController:noticeViewController animated:YES];
    
}

- (void)viewWillAppear:(BOOL)animated {
    
    [self.navigationController setNavigationBarHidden:YES animated:NO];
}



- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}



- (IBAction)showClassInfo:(id)sender {


    AppDelegate *delegate = [[UIApplication sharedApplication]delegate];


    if ([UIDevice currentDevice].systemVersion.integerValue >= 7)
        [self setModalPresentationStyle:UIModalPresentationCurrentContext];

    [self presentViewController:delegate.modalVC animated:NO completion:nil];
    
    
}

- (UIStatusBarStyle)preferredStatusBarStyle{
    return UIStatusBarStyleDefault;
}



@end
