//
//  OrderViewController.m
//  CleanBasket
//
//  Created by 이상진 on 2016. 1. 4..
//  Copyright © 2016년 WashappKorea. All rights reserved.
//

#import "OrderViewController.h"
#import "AppDelegate.h"
#import "TimeSelectViewController.h"
#import <AFNetworking/AFNetworking.h>
#import <SVProgressHUD/SVProgressHUD.h>
#import <Realm/Realm.h>
#import "User.h"
#import "CBConstants.h"

typedef enum : NSUInteger {
    CBPaymentMethodCard=0,
    CBPaymentMethodCash,
    CBPaymentMethodInApp,
    CBPaymentMethodNone = 10,
} CBPaymentMethod;

@interface OrderViewController () <UIActionSheetDelegate> {

    NSDate *_pickUpDate, *_dropOffDate, *_startPickupDate;
    NSInteger _dropOffInterval;
    AFHTTPRequestOperationManager *_manager;
}


@property (weak, nonatomic) IBOutlet UIView *timeSelectView;
@property (weak, nonatomic) IBOutlet UIView *paymentView;
@property (weak, nonatomic) IBOutlet UIView *priceView;
@property (weak, nonatomic) IBOutlet UILabel *addressLabel;
@property (weak, nonatomic) IBOutlet UIView *addressView;
@property (weak, nonatomic) IBOutlet UILabel *paymentMethodLabel;
@property (weak, nonatomic) IBOutlet UILabel *estimatePriceLabel;
@property (weak, nonatomic) IBOutlet UILabel *pickUpTimeLabel;
@property (weak, nonatomic) IBOutlet UILabel *dropOffTimeLabel;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *testConst;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *topConst;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *dropOffLabelWidthConstraint;

@property (nonatomic)  CBPaymentMethod paymentMethod;
@property NSNumber *estimatePrice;
@property NSNumberFormatter *numberFormatter;
@property NSString *addressString, *addr_building, *address;
@property NSDateFormatter *stringFromDateFormatter;

@end


@implementation OrderViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    [SVProgressHUD setDefaultMaskType:SVProgressHUDMaskTypeGradient];

    _manager = [AFHTTPRequestOperationManager manager];

    _manager.responseSerializer = [AFJSONResponseSerializer serializer];
    _manager.responseSerializer.acceptableContentTypes = [_manager.responseSerializer.acceptableContentTypes setByAddingObject:@"text/html"];



    UITapGestureRecognizer *addressTGR = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(editAddress)];
    [_addressView addGestureRecognizer:addressTGR];
    
    UITapGestureRecognizer *timeSelectTGR = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(showTimeSelectVC:)];
    [_timeSelectView addGestureRecognizer:timeSelectTGR];
    UITapGestureRecognizer *dropoffTimeSelectTGR = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(showTimeSelectVC:)];
    [_dropOffTimeLabel addGestureRecognizer:dropoffTimeSelectTGR];
    UITapGestureRecognizer *paymentTGR = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(paymentMethodTap)];
    [_paymentView addGestureRecognizer:paymentTGR];
    UITapGestureRecognizer *priceTGR = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(priceEstimation)];
    [_priceView addGestureRecognizer:priceTGR];


    _testConst.constant -= 100;
    _topConst.constant -=30;
    
    
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
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(getAddress)
                                                 name:@"didFinishEditAddress" object:nil];



    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(finishedPickUpDate:)
                                                 name:@"didFinishPickUpDate"
                                               object:nil];

    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(finishedDropOffDate:)
                                                 name:@"didFinishDropOffDate"
                                               object:nil];


    _addressString = [NSString string];
    [_addressLabel setText:_addressString];


    [self getAddress];

    [self setNeedsStatusBarAppearanceUpdate];

    [self initOrder];
    
    self.stringFromDateFormatter = [NSDateFormatter new];
    self.stringFromDateFormatter.dateFormat = @"yyyy-MM-dd HH:mm:ss.s";
}


- (void)initOrder{

    _pickUpDate = nil;
    _dropOffDate = nil;

    NSCalendar *calendar = [NSCalendar autoupdatingCurrentCalendar];

    NSDate *today = [NSDate date];

    NSDateComponents *dateComponents= [calendar components:NSCalendarUnitYear|NSCalendarUnitMonth|NSCalendarUnitDay|NSCalendarUnitHour|NSCalendarUnitMinute fromDate:today];

//    NSLog(@"%@",dateComponents);

    dateComponents.hour += 2;

    //분처리
    if (dateComponents.minute>=0 && dateComponents.minute<30){
        dateComponents.minute = 30;
    }
    else if (dateComponents.minute>=30){
        dateComponents.minute = 0;
        dateComponents.hour += 1;
    }
    //시처리
    //오전 10시 이전
    if (dateComponents.hour<10){
        dateComponents.hour = 10;
        dateComponents.minute = 0;
    }
    //오후 11시 30분 이후
    else if(dateComponents.hour>=23 && dateComponents.month >= 30){
        dateComponents.day += 1;
        dateComponents.hour = 10;
        dateComponents.minute = 0;
    }
    
//
//
//    NSDate *lastNewDate=[calendar dateByAddingComponents:dateComponents toDate:_pickUpDate options:0];
    _pickUpDate = [calendar dateFromComponents:dateComponents];
    _startPickupDate = _pickUpDate;
    NSLog(@"pickUpDate = %@",_pickUpDate);
//
//
    [_pickUpTimeLabel setText:[self getStringFromDate:_pickUpDate]];
    [_dropOffTimeLabel setText:NSLocalizedString(@"time_dropoff_inform_after",nil)];


}



- (void)finishedPickUpDate:(NSNotification *)noti{

    _pickUpDate = [noti userInfo][@"date"];
    NSString *pickUpTimeString = [self getStringFromDate:_pickUpDate];
    [_pickUpTimeLabel setText:pickUpTimeString];

}


- (void)finishedDropOffDate:(NSNotification *)noti{

    _dropOffDate = [noti userInfo][@"date"];
    NSString *dropOffTimeString = [self getStringFromDate:_dropOffDate];

    NSString *dropOffTimeLabelString = [NSString stringWithFormat:@"%@%@",dropOffTimeString,NSLocalizedString(@"dropoff_datetime_c",nil)];

    [_dropOffTimeLabel setText:dropOffTimeLabelString];
}



- (NSString *)getStringFromDate:(NSDate*)date {
    NSDateFormatter *firstDateFormatter = [NSDateFormatter new];
    NSDateFormatter *lastDateFormatter = [NSDateFormatter new];

    NSString *firstDateFormat = @"a hh:mm~";
    [firstDateFormatter setDateFormat:firstDateFormat];

    NSString *lastDateFormat = @"hh:mm";
    [lastDateFormatter setDateFormat:lastDateFormat];


    NSDateComponents *components= [[NSDateComponents alloc] init];
    NSCalendar *calendar = [NSCalendar currentCalendar];



    [components setHour:1];
    NSDate *lastNewDate=[calendar dateByAddingComponents:components toDate:date options:0];


    NSDateFormatter *dateFormatter = [NSDateFormatter new];
    [dateFormatter setDateFormat:NSLocalizedString(@"datetime_parse",nil)];


    NSString *firstTimeString =   [firstDateFormatter stringFromDate:date];
    NSString *lastTimeString =   [lastDateFormatter stringFromDate:lastNewDate];

    NSDate *today = [NSDate date];
    NSDateComponents *todayDateComponents = [[NSCalendar currentCalendar] components:NSCalendarUnitMonth|NSCalendarUnitDay|NSCalendarUnitHour|NSCalendarUnitMinute fromDate:today];
    NSDateComponents *dateComponents = [[NSCalendar currentCalendar] components:NSCalendarUnitMonth|NSCalendarUnitDay|NSCalendarUnitHour|NSCalendarUnitMinute fromDate:date];

    NSString *dateString;



    if (todayDateComponents.day == dateComponents.day){

        dateString = [NSString stringWithFormat:@"%@ %@%@",NSLocalizedString(@"time_today",nil), firstTimeString, lastTimeString];
    }
    else if (todayDateComponents.day+1 == dateComponents.day){
        dateString = [NSString stringWithFormat:@"%@ %@%@",NSLocalizedString(@"time_tomorrow",nil), firstTimeString, lastTimeString];
    }
    else
        dateString = [NSString stringWithFormat:@"%@ %@%@", [dateFormatter stringFromDate:date], firstTimeString, lastTimeString];

    return dateString;
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

- (void)viewWillAppear:(BOOL)animated{
    
    _dropOffLabelWidthConstraint.constant = _timeSelectView.frame.size.width-40;
}

- (void)viewDidAppear:(BOOL)animated{
    

    [UIView animateWithDuration:0.2f
                          delay:0.0f options:UIViewAnimationOptionCurveEaseInOut
                     animations:^{

                         _addressView.alpha = 1.0f;
                         _topConst.constant = 0.0f;
                         [self.view layoutSubviews];
                     }
                     completion:^(BOOL finished){
                         
                     }];
    
    [UIView animateWithDuration:0.2f
                          delay:0.1f options:UIViewAnimationOptionCurveEaseInOut
                     animations:^{
                         
                         [_timeSelectView setAlpha:1.0f];
                     }
                     completion:^(BOOL finished){
                         
                     }];
    

    [UIView animateWithDuration:0.2f
                          delay:0.15f options:UIViewAnimationOptionCurveEaseInOut
                     animations:^{

                         [_paymentView setAlpha:1.0f];
                     }
                     completion:^(BOOL finished){

                     }];

    [UIView animateWithDuration:0.2f
                          delay:0.2f options:UIViewAnimationOptionCurveEaseInOut
                     animations:^{

                         [_priceView setAlpha:1.0f];
                     }
                     completion:^(BOOL finished){

                     }];
    
    [UIView animateWithDuration:0.2f
                          delay:0.25f
         usingSpringWithDamping:0.7f
          initialSpringVelocity:0.7f
                        options:UIViewAnimationOptionCurveEaseIn animations:^{
                            
                            _testConst.constant += 100;
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
    
    
    _addressView.alpha = 0.0f;
    _testConst.constant -= 100;
    _topConst.constant -= 30.0f;
    
}


- (void)showTimeSelectVC:(UITapGestureRecognizer *)sender{
    NSLog(@"시간탭!");

    if (!_addressString.length){

        [SVProgressHUD showErrorWithStatus:NSLocalizedString(@"address_empty",nil)];
        [self presentAddAddressVC];

        return;
    }


    UIStoryboard *sb = [UIStoryboard storyboardWithName:@"Main" bundle:nil];

    UINavigationController *timeSelectNVC = [sb instantiateViewControllerWithIdentifier:@"TimeSelectNVC"];

    if (sender.view == _timeSelectView){

        TimeSelectViewController *timeSelectViewController = [timeSelectNVC.viewControllers firstObject];
        [timeSelectViewController setTimeSelectType:CBTimeSelectTypePickUp];
        [timeSelectViewController setStartDate:_startPickupDate];



    }
    else if (sender.view == _dropOffTimeLabel){


        TimeSelectViewController *timeSelectViewController = [timeSelectNVC.viewControllers firstObject];
        [timeSelectViewController setTimeSelectType:CBTimeSelectTypeDropOff];
        [timeSelectViewController setDefaultInterval:_dropOffInterval];
    }


    [self presentViewController:timeSelectNVC animated:YES completion:nil];

    
}



- (void)editAddress{


    UIStoryboard *sb = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    UINavigationController *addAddressNC = [sb instantiateViewControllerWithIdentifier:@"AddAddressNC"];

    [self presentViewController:addAddressNC animated:YES completion:nil];




}


- (void)presentAddAddressVC{
    UIStoryboard *sb = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    UINavigationController *addAddressNC = [sb instantiateViewControllerWithIdentifier:@"AddAddressNC"];

    [self presentViewController:addAddressNC animated:YES completion:nil];
}


- (void)getAddress{

    [_manager GET:@"http://52.79.39.100:8080/member/address"
      parameters:nil
         success:^(AFHTTPRequestOperation *operation, id responseObject) {



             NSError *jsonError;
             NSData *objectData = [responseObject[@"data"] dataUsingEncoding:NSUTF8StringEncoding];
             NSArray *data = [NSJSONSerialization JSONObjectWithData:objectData
                                                             options:NSJSONReadingMutableContainers
                                                               error:&jsonError];


             if (!data.count){
                 //주소없을때처리
                 [_addressLabel setText:NSLocalizedString(@"address_empty",nil)];

             } else {
                 //주소있을때처리
                 
                 _address = data.firstObject[@"address"];
                 
                 if (data.firstObject[@"addr_remainder"]) {
                     self.addr_building = data.firstObject[@"addr_remainder"];
                 }
                 
//                 _addr_building = data.firstObject[@"addr_ramainder"];
                 _addressString = [NSString stringWithFormat:@"%@ %@",_address,_addr_building];
                 NSLog(@"주소 : %@",self.addr_building);
                 [_addressLabel setText:_addressString];
                 [self getDropOffInterval];
             }


         } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                NSLog(@"Error: %@", error);
            }];
}


- (void)getDropOffInterval{
    [_manager GET:@"http://52.79.39.100:8080/member/dropoff/dropoff_datetime"
       parameters:nil
          success:^(AFHTTPRequestOperation *operation, id responseObject) {

              _dropOffInterval = [responseObject[@"data"] integerValue];

          } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                NSLog(@"Error: %@", error);
            }];
}



- (void)paymentMethodTap{
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
//            [_paymentMethodLabel setHidden:NO];
//            [_paymentMethodLabel setText:[actionSheet buttonTitleAtIndex:buttonIndex]];
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


    [manager GET:@"http://52.79.39.100:8080/member/payment"
      parameters:nil
         success:^(AFHTTPRequestOperation *operation, id responseObject) {



             NSError *jsonError;
             NSData *objectData = [responseObject[@"data"] dataUsingEncoding:NSUTF8StringEncoding];
             NSDictionary *data = [NSJSONSerialization JSONObjectWithData:objectData
                                                             options:NSJSONReadingMutableContainers
                                                               error:&jsonError];


             if ([data[@"cardName"] isEqualToString:@""]){
                 [SVProgressHUD showWithStatus:@"등록된 카드가 없습니다."];

                 UIStoryboard *sb = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
                 UINavigationController *creditViewController = [sb instantiateViewControllerWithIdentifier:@"AddCreditVC"];

                 [self presentViewController:creditViewController animated:YES completion:^{
                     [self dismissHUD];
                 }];

             } else{

                 [_paymentMethodLabel setHidden:NO];
                 NSString *creditInfoString = [NSString stringWithFormat:@"%@\n%@",data[@"cardName"],data[@"authDate"]];

                 [_paymentMethodLabel setText:creditInfoString];
                 [SVProgressHUD dismiss];

             }



         } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                NSLog(@"Error: %@", error);
                [SVProgressHUD showErrorWithStatus:NSLocalizedString(@"network_error",nil)];
            }];
    
    


}



-(IBAction)addOrder:(id)sender{
    
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
//
    
    manager.responseSerializer = [AFJSONResponseSerializer serializer];
    manager.responseSerializer.acceptableContentTypes = [manager.responseSerializer.acceptableContentTypes setByAddingObject:@"text/html"];

    

    //    NSLog(@"시간들 : %@,%@",_pickUpDate,_dropOffDate);
//    NSLog(@"수거 :%@, 배달 : %@",[self.stringFromDateFormatter stringFromDate:_pickUpDate],[self.stringFromDateFormatter stringFromDate:_dropOffDate]);
    
    RLMResults<User *> *users = [User allObjects];
    User *user = [users firstObject];
    
//    NSLog(@"uid : %i",user.uid);
    
    NSDictionary *parameters = @{@"address":self.address,
                                 @"addr_building": self.addr_building,
                                 @"pickup_date":[self.stringFromDateFormatter stringFromDate:_pickUpDate],
                                 @"dropoff_date":[self.stringFromDateFormatter stringFromDate:_dropOffDate],
                                 @"uid":[NSString stringWithFormat:@"%i",user.uid],
                                 @"memo":@"테스트",
                                 @"price":@2000,
                                 @"dropoff_price":@2000,
                                 @"payment_method":@0,
                                 @"item":[NSMutableArray new],
                                 @"coupon":[NSMutableArray new]
                                 };
    
    //    AFJSONRequestSerializer *req = [AFJSONRequestSerializer serializerWithWritingOptions:NSJSONWritingPrettyPrinted];
        AFHTTPRequestSerializer *req = [AFHTTPRequestSerializer serializer];
    
//    manager.requestSerializer = [AFJSONRequestSerializer serializer];
    manager.requestSerializer = req;
    
    NSString *jsonString = [[NSString alloc] initWithData:[NSJSONSerialization dataWithJSONObject:parameters options:NSJSONWritingPrettyPrinted error:nil] encoding:NSUTF8StringEncoding];
//    NSLog(@"파라팔 :%@",parameters);
    
//    [manager POST:@"http://52.79.39.100:8080/member/order/add/new"
//      parameters:jsonString
//         success:^(AFHTTPRequestOperation *operation, id responseObject) {
////             operation.request
////             NSString *resString = [[NSString alloc]initWithData:responseObject encoding:NSUTF8StringEncoding];
//             NSLog(@"리스폰스 :​%@",responseObject);
//             
//         } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
//             NSLog(@"Error: %@, %@", error,error.localizedDescription);
//             [SVProgressHUD showErrorWithStatus:NSLocalizedString(@"network_error",nil)];
//         }];
    
//    
//    NSString *jsonString = [[NSString alloc] initWithData:[NSJSONSerialization dataWithJSONObject:parameters options:NSJSONWritingPrettyPrinted error:nil] encoding:NSUTF8StringEncoding];
//    
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:@"http://52.79.39.100:8080/member/order/add/new"]
                                                           cachePolicy:NSURLRequestReloadIgnoringCacheData  timeoutInterval:10];
//
    [request setHTTPMethod:@"POST"];
    [request setValue: @"application/json" forHTTPHeaderField:@"Content-Type"];
    [request setHTTPBody: [jsonString dataUsingEncoding:NSUTF8StringEncoding]];

    
    NSLog(@"[JSON STRING]\r%@", jsonString);
//
    AFHTTPRequestOperation *op = [[AFHTTPRequestOperation alloc] initWithRequest:request];
    op.responseSerializer = [AFJSONResponseSerializer serializerWithReadingOptions:NSJSONReadingAllowFragments];
    op.responseSerializer.acceptableContentTypes = [manager.responseSerializer.acceptableContentTypes setByAddingObject:@"text/html"];
//
//    
    [op setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {

        NSLog(@"JSON responseObject: %@ ",responseObject);
        NSLog(@"%@", [responseObject valueForKey:@"message"]);
        int constant = [[responseObject valueForKey:@"constant"] intValue];

        switch (constant) {
            case CBServerConstantSuccess: {
                NSLog(@"성공!");
//                [self showHudMessage:@"주문이 정상적으로 접수되었습니다."];
//                [self resetItemsCount];
//                
//          
//                
//                
//                //AppDelegate로 하여금 현재 선택된 TabBarViewController를 OrderStatusViewController로 변경
//                [[NSNotificationCenter defaultCenter] postNotificationName:@"orderComplete" object:self];
//                
//                // 2초 후 현재 화면 pop
//                [self performSelector:@selector(cancelButtonDidTouched) withObject:self afterDelay:2];
            }
                break;
            case CBServerConstantError: {
                NSLog(@"에러!");
//                [self showHudMessage:@"주문 정보 접수에 실패했습니다."];
            }
                break;
                
            case CBServerConstantsAreaUnavailable: {
//                [self showHudMessage:@"서비스 가능 지역이 아닙니다"];
            }
                break;
                
            case CBServerConstantsDateUnavailable: {
//                [self showHudMessage:@"죄송합니다. 해당 수거/배달일은 휴무입니다"];
            }
                break;
                
            case CBServerConstantSessionExpired: {
//                [self showHudMessage:@"세션이 만료되었습니다. 로그인화면으로 돌아갑니다."];
//                [self resetItemsCount];
//                [memoTextField setText:@""];
                //AppDelegate에 세션이 만료됨을 알림
                [[NSNotificationCenter defaultCenter] postNotificationName:@"sessionExpired" object:self];
            }
                break;
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        dispatch_async(dispatch_get_main_queue(), ^{
//            [self showHudMessage:@"네트워크 상태를 확인해주세요"];
            NSLog(@"Error: %@", error);
        });
        
    }];

    [op start];

}



- (void)dismissHUD{

    [SVProgressHUD dismiss];

}

- (void)priceEstimation{


    AppDelegate *delegate = [[UIApplication sharedApplication] delegate];


    [self presentViewController:(UIViewController*)delegate.estimateVC animated:YES completion:nil];


}




- (UIStatusBarStyle)preferredStatusBarStyle {
    return UIStatusBarStyleLightContent;
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}


@end
