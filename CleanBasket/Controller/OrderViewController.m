//
//  OrderViewController.m
//  CleanBasket
//
//  Created by 이상진 on 2016. 1. 4..
//  Copyright © 2016년 WashappKorea. All rights reserved.
//

#import "OrderViewController.h"
#import "AppDelegate.h"
#import <AFNetworking/AFNetworking.h>
#import <SVProgressHUD/SVProgressHUD.h>

typedef enum : NSUInteger {
    CBPaymentMethodCard=0,
    CBPaymentMethodCash,
    CBPaymentMethodInApp,
    CBPaymentMethodNone = 10,
} CBPaymentMethod;

@interface OrderViewController () <UIActionSheetDelegate>
@property (weak, nonatomic) IBOutlet UIView *timeSelectView;
@property (weak, nonatomic) IBOutlet UIView *paymentView;
@property (weak, nonatomic) IBOutlet UIView *priceView;
@property (weak, nonatomic) IBOutlet UIView *addressView;
@property (weak, nonatomic) IBOutlet UILabel *paymentMethodLabel;
@property (weak, nonatomic) IBOutlet UILabel *estimatePriceLabel;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *testConst;

@property CBPaymentMethod paymentMethod;
@property NSNumber *estimatePrice;
@property NSNumberFormatter *numberFormatter;

@end

CGFloat defaultConst;

@implementation OrderViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    UITapGestureRecognizer *addressTGR = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(editAddress)];
    [_addressView addGestureRecognizer:addressTGR];
    
    UITapGestureRecognizer *timeSelectTGR = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(showTimeSelectVC)];
    [_timeSelectView addGestureRecognizer:timeSelectTGR];
    UITapGestureRecognizer *paymentTGR = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(paymentMethod)];
    [_paymentView addGestureRecognizer:paymentTGR];
    UITapGestureRecognizer *priceTGR = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(priceEstimation)];
    [_priceView addGestureRecognizer:priceTGR];

    defaultConst = _testConst.constant;
    _testConst.constant = defaultConst-100;

    [_timeSelectView setAlpha:0.0f];
    [_paymentView setAlpha:0.0f];
    [_priceView setAlpha:0.0f];
    
    _estimatePrice = [NSNumber new];
    _paymentMethod = CBPaymentMethodNone;



    _numberFormatter = [NSNumberFormatter new];
    [_numberFormatter setNumberStyle:NSNumberFormatterDecimalStyle];

    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(finishedEstimate:)
                                                 name:@"didFinishEstimate" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(checkCreditCard)
                                                 name:@"didFinishAddCredit" object:nil];


}

- (void)finishedEstimate:(NSNotification *)notification {

    NSNumber *totalPrice = notification.userInfo[@"totalPrice"];
    if ([totalPrice integerValue]){
        _estimatePrice = totalPrice;
        [_estimatePriceLabel setHidden:NO];
        NSString *totalPriceString = [NSString stringWithFormat:@"%@%@",[_numberFormatter stringFromNumber:_estimatePrice],NSLocalizedString(@"monetary_unit",@"원")];
        [_estimatePriceLabel setText:totalPriceString];
    }
    else {
        [_estimatePriceLabel setHidden:YES];
    }

}

- (void)viewDidAppear:(BOOL)animated{
    
    _testConst.constant = defaultConst;

    [UIView animateWithDuration:0.3f
                          delay:0.0f options:UIViewAnimationOptionCurveEaseInOut
                     animations:^{

                         [_timeSelectView setAlpha:1.0f];
                     }
                     completion:^(BOOL finished){

                     }];

    [UIView animateWithDuration:0.3f
                          delay:0.15f options:UIViewAnimationOptionCurveEaseInOut
                     animations:^{

                         [_paymentView setAlpha:1.0f];
                     }
                     completion:^(BOOL finished){

                     }];

    [UIView animateWithDuration:0.3f
                          delay:0.3f options:UIViewAnimationOptionCurveEaseInOut
                     animations:^{

                         [_priceView setAlpha:1.0f];
                     }
                     completion:^(BOOL finished){

                     }];
    
    [UIView animateWithDuration:0.3f
                          delay:0.45f
         usingSpringWithDamping:0.7f
          initialSpringVelocity:0.7f
                        options:UIViewAnimationOptionCurveEaseIn animations:^{

                            [self.view layoutIfNeeded];
            }
                     completion:^(BOOL finished) {
                         //Completion Block
                     }];


}


- (void)viewWillDisappear:(BOOL)animated {

    [_timeSelectView setAlpha:0.0f];
    [_paymentView setAlpha:0.0f];
    [_priceView setAlpha:0.0f];
    _testConst.constant = defaultConst-100;
}


- (void)showTimeSelectVC{
    NSLog(@"시간탭!");
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];

    manager.responseSerializer = [AFJSONResponseSerializer serializer];
    manager.responseSerializer.acceptableContentTypes = [manager.responseSerializer.acceptableContentTypes setByAddingObject:@"text/html"];



    [manager GET:@"http://www.cleanbasket.co.kr/member/pickup"
      parameters:nil
         success:^(AFHTTPRequestOperation *operation, id responseObject) {



             NSError *jsonError;
             NSData *objectData = [responseObject[@"data"] dataUsingEncoding:NSUTF8StringEncoding];
             NSArray *data = [NSJSONSerialization JSONObjectWithData:objectData
                                                             options:NSJSONReadingMutableContainers
                                                               error:&jsonError];

             NSLog(@"message : %@, data : %@",responseObject[@"message"],data);



         } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                NSLog(@"Error: %@", error);
            }];

}



- (void)editAddress{

    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];


    manager.requestSerializer = [AFJSONRequestSerializer serializer];
    manager.responseSerializer = [AFJSONResponseSerializer serializerWithReadingOptions:NSJSONReadingAllowFragments];

    manager.responseSerializer.acceptableContentTypes = [manager.responseSerializer.acceptableContentTypes setByAddingObject:@"text/html"];



    NSDictionary *parameters = @{@"address":@"서울 강남구 역삼동",
                                 @"addr_remainder":@"605-12 대암빌딩 104호" ,
                                 @"type":@"0",
            @"addr_building":@"",
            @"addr_number":@""
    };


    [manager POST:@"http://www.cleanbasket.co.kr/member/address/update"
       parameters:parameters

          success:^(AFHTTPRequestOperation *operation, id responseObject) {

              NSLog(@"결과: %@", [NSString stringWithUTF8String:[responseObject[@"message"] UTF8String]]);

              if (responseObject[@"constant"]) {
              }


          } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                NSLog(@"Error: %@", error);
            }];





//    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
//
//    manager.responseSerializer = [AFJSONResponseSerializer serializer];
//    manager.responseSerializer.acceptableContentTypes = [manager.responseSerializer.acceptableContentTypes setByAddingObject:@"text/html"];
//
//
//
//    [manager GET:@"http://www.cleanbasket.co.kr/member/address"
//      parameters:nil
//         success:^(AFHTTPRequestOperation *operation, id responseObject) {
//
//
//
//             NSError *jsonError;
//             NSData *objectData = [responseObject[@"data"] dataUsingEncoding:NSUTF8StringEncoding];
//             NSArray *data = [NSJSONSerialization JSONObjectWithData:objectData
//                                                             options:NSJSONReadingMutableContainers
//                                                               error:&jsonError];
//
//             NSLog(@"message : %@, data : %@",responseObject[@"message"],data);
//
//
//             if (!data.count){
//                 //주소없을때처리
//
//                 [self presentAddAddressVC];
//
//             } else {
//                 //주소있을때처리
//
//             }
//
//
//         } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
//                NSLog(@"Error: %@", error);
//            }];
}


- (void)presentAddAddressVC{
    UIStoryboard *sb = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    UINavigationController *addAddressNC = [sb instantiateViewControllerWithIdentifier:@"AddAddressNC"];

    [self presentViewController:addAddressNC animated:YES completion:nil];
}


- (void)getAddress{

    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];

    manager.responseSerializer = [AFJSONResponseSerializer serializer];
    manager.responseSerializer.acceptableContentTypes = [manager.responseSerializer.acceptableContentTypes setByAddingObject:@"text/html"];

    [manager GET:@"http://www.cleanbasket.co.kr/district"
      parameters:nil
         success:^(AFHTTPRequestOperation *operation, id responseObject) {
//
//

                           NSError *jsonError;
                           NSData *objectData = [responseObject[@"data"] dataUsingEncoding:NSUTF8StringEncoding];
                           NSArray *datas = [NSJSONSerialization JSONObjectWithData:objectData
                                                                           options:NSJSONReadingMutableContainers
                                                                             error:&jsonError];


             NSString *currentLanguage = [NSLocale preferredLanguages][0];

             //한글일때
             if ([currentLanguage isEqualToString:@"ko"]) {

                 for (NSDictionary *data in datas){

                     NSInteger dcid = [(NSNumber *)data[@"dcid"] integerValue];

                     if ( !(dcid % 2) ){
                         NSLog(@"%@\n", data);
                     }

                 }

             }
             //영어일때
             else if([currentLanguage isEqualToString:@"en"]) {

                 for (NSDictionary *data in datas){

                     NSInteger dcid = [(NSNumber *)data[@"dcid"] integerValue];

                     if (dcid % 2){
                         NSLog(@"%@\n", data);
                     }

                 }


             }

         } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                NSLog(@"Error: %@", error);
            }];
}

- (void)paymentMethod{
    NSLog(@"결제수단탭");


    UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:NSLocalizedString(@"payment_method",@"결제수단")
                                                             delegate:self
                                                    cancelButtonTitle:NSLocalizedString(@"label_cancel",@"취소")
                                               destructiveButtonTitle:nil
                                                    otherButtonTitles:NSLocalizedString(@"payment_card",nil),NSLocalizedString(@"payment_cash",nil),NSLocalizedString(@"payment_in_app_finish",nil),nil];

    [actionSheet showFromTabBar:self.tabBarController.tabBar];

}


- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {

    switch (buttonIndex){
        case CBPaymentMethodCard:{
            _paymentMethod = CBPaymentMethodCard;
            [_paymentMethodLabel setHidden:NO];
            [_paymentMethodLabel setText:[actionSheet buttonTitleAtIndex:buttonIndex]];
            NSLog(@"카드결제");
            break;
        }
        case CBPaymentMethodCash:{
            _paymentMethod = CBPaymentMethodCash;
            [_paymentMethodLabel setHidden:NO];
            [_paymentMethodLabel setText:[actionSheet buttonTitleAtIndex:buttonIndex]];
            NSLog(@"현금결제");
            break;
        }
        case CBPaymentMethodInApp:{
            _paymentMethod = CBPaymentMethodInApp;
            [_paymentMethodLabel setHidden:NO];
            [_paymentMethodLabel setText:[actionSheet buttonTitleAtIndex:buttonIndex]];
            NSLog(@"인앱결제");
            [self checkCreditCard];
            break;
        }
        default:
            _paymentMethod = CBPaymentMethodNone;
            [_paymentMethodLabel setHidden:YES];
            [_paymentMethodLabel setText:@""];
            break;
    }

}


- (void)actionSheetCancel:(UIActionSheet *)actionSheet {
}




- (void)checkCreditCard{

    [SVProgressHUD show];

    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];

    manager.responseSerializer = [AFJSONResponseSerializer serializer];
    manager.responseSerializer.acceptableContentTypes = [manager.responseSerializer.acceptableContentTypes setByAddingObject:@"text/html"];


    [manager GET:@"http://www.cleanbasket.co.kr/member/payment"
      parameters:nil
         success:^(AFHTTPRequestOperation *operation, id responseObject) {



             NSError *jsonError;
             NSData *objectData = [responseObject[@"data"] dataUsingEncoding:NSUTF8StringEncoding];
             NSDictionary *data = [NSJSONSerialization JSONObjectWithData:objectData
                                                             options:NSJSONReadingMutableContainers
                                                               error:&jsonError];

             NSLog(@"message : %@, data : %@",responseObject[@"message"],data);

             if ([data[@"cardName"] isEqualToString:@""]){
                 [SVProgressHUD showWithStatus:@"등록된 카드가 없습니다.\n카드 등록 화면으로 이동합니다."];

                 UIStoryboard *sb = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
                 UINavigationController *creditViewController = [sb instantiateViewControllerWithIdentifier:@"AddCreditVC"];

                 [self presentViewController:creditViewController animated:YES completion:^{[SVProgressHUD dismiss];}];
             } else{

                 [_paymentMethodLabel setHidden:NO];
                 NSString *creditInfoString = [NSString stringWithFormat:@"%@\n%@",data[@"cardName"],data[@"authDate"]];

                 [_paymentMethodLabel setText:creditInfoString];
                 [SVProgressHUD dismiss];

             }



//             [SVProgressHUD dismiss];


         } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                NSLog(@"Error: %@", error);
                [SVProgressHUD showErrorWithStatus:NSLocalizedString(@"network_error",nil)];
            }];


}



- (void)priceEstimation{


    AppDelegate *delegate = [[UIApplication sharedApplication] delegate];


    [self presentViewController:delegate.estimateVC animated:YES completion:nil];



//    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
//
//    manager.responseSerializer = [AFJSONResponseSerializer serializer];
//    manager.responseSerializer.acceptableContentTypes = [manager.responseSerializer.acceptableContentTypes setByAddingObject:@"text/html"];
//
//
//
//    [manager GET:@"http://www.cleanbasket.co.kr/item"
//      parameters:nil
//         success:^(AFHTTPRequestOperation *operation, id responseObject) {
//
//
//
//             NSError *jsonError;
//             NSData *objectData = [responseObject[@"data"] dataUsingEncoding:NSUTF8StringEncoding];
//             NSArray *data = [NSJSONSerialization JSONObjectWithData:objectData
//                                                             options:NSJSONReadingMutableContainers
//                                                               error:&jsonError];
//
//             NSLog(@"message : %@, data : %@",responseObject[@"message"],data);
//
//
//
//         } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
//                NSLog(@"Error: %@", error);
//            }];




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

@end
