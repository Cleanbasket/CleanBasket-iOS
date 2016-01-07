//
//  OrderViewController.m
//  CleanBasket
//
//  Created by 이상진 on 2016. 1. 4..
//  Copyright © 2016년 WashappKorea. All rights reserved.
//

#import "OrderViewController.h"
#import <AFNetworking/AFNetworking.h>

@interface OrderViewController ()
@property (weak, nonatomic) IBOutlet UIView *timeSelectView;
@property (weak, nonatomic) IBOutlet UIView *paymentView;
@property (weak, nonatomic) IBOutlet UIView *priceView;
@property (weak, nonatomic) IBOutlet UIView *addressView;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *testConst;

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

    manager.responseSerializer = [AFJSONResponseSerializer serializer];
    manager.responseSerializer.acceptableContentTypes = [manager.responseSerializer.acceptableContentTypes setByAddingObject:@"text/html"];



    [manager GET:@"http://www.cleanbasket.co.kr/member/address"
      parameters:nil
         success:^(AFHTTPRequestOperation *operation, id responseObject) {



             NSError *jsonError;
             NSData *objectData = [responseObject[@"data"] dataUsingEncoding:NSUTF8StringEncoding];
             NSArray *data = [NSJSONSerialization JSONObjectWithData:objectData
                                                             options:NSJSONReadingMutableContainers
                                                               error:&jsonError];

             NSLog(@"message : %@, data : %@",responseObject[@"message"],data);


             if (!data.count){
                 //주소없을때처리

                 [self presentAddAddressVC];

             } else {
                 //주소있을때처리

             }


         } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                NSLog(@"Error: %@", error);
            }];
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
}

- (void)priceEstimation{
    NSLog(@"견적탭");



    UIStoryboard *sb = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    UINavigationController *estimationVC = [sb instantiateViewControllerWithIdentifier:@"EstimationVC"];

    [self presentViewController:estimationVC animated:YES completion:nil];



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
