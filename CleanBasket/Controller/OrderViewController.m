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
#import "AddedItem.h"
#import "CBConstants.h"
#import "UIAlertView+Blocks.h"
#import "CBNotificationManager.h"
#import "EstimateViewController.h"

typedef enum : NSUInteger {
    CBPaymentMethodCard=1,
    CBPaymentMethodCash,
    CBPaymentMethodInApp,
    CBPaymentMethodNone = 10,
} CBPaymentMethod;

@interface OrderViewController () <UIActionSheetDelegate> {

    NSDate *_pickUpDate, *_dropOffDate, *_startPickupDate;
    NSNumber *_dropOffInterval;
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


@property (strong, nonatomic) RLMRealm *realm;
@property (strong, nonatomic) RLMResults *items;

@end


@implementation OrderViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self addNotification];
    
    _numberFormatter = [NSNumberFormatter new];
    [_numberFormatter setNumberStyle:NSNumberFormatterDecimalStyle];
    
    _realm = [RLMRealm defaultRealm];

    
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







    _addressString = [NSString string];
    [_addressLabel setText:_addressString];


    [self getAddress];

    [self setNeedsStatusBarAppearanceUpdate];

    [self initOrder];
    
    self.stringFromDateFormatter = [NSDateFormatter new];
    self.stringFromDateFormatter.dateFormat = @"yyyy-MM-dd HH:mm:ss.s";
}


- (void)initOrder{
    
    //시간들 초기화
    _pickUpDate = nil;
    _dropOffDate = nil;

    NSCalendar *calendar = [NSCalendar autoupdatingCurrentCalendar];
    NSDate *today = [NSDate date];
    NSDateComponents *dateComponents= [calendar components:NSCalendarUnitYear|NSCalendarUnitMonth|NSCalendarUnitDay|NSCalendarUnitHour|NSCalendarUnitMinute fromDate:today];


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
    //밤 12시 이후
    else if(dateComponents.hour>=24){
        dateComponents.day += 1;
        dateComponents.hour = 10;
        dateComponents.minute = 0;
    }
    
    
    _pickUpDate = [calendar dateFromComponents:dateComponents];
    [_pickUpTimeLabel setText:[self getStringFromDate:_pickUpDate]];
    
    //배달시간 48시간 이후로 설정.
    _dropOffDate = [_pickUpDate dateByAddingTimeInterval:60*60*24*2];
    NSString *dropOffTimeString = [self getStringFromDate:_dropOffDate];
    NSString *dropOffTimeLabelString = [NSString stringWithFormat:@"%@%@",dropOffTimeString,NSLocalizedString(@"dropoff_datetime_c",nil)];
    [_dropOffTimeLabel setText:dropOffTimeLabelString];
    _startPickupDate = _pickUpDate;



    //결제수단 초기화
    _paymentMethod = CBPaymentMethodNone;
    [_paymentMethodLabel setHidden:YES];
    
    
    //아이템 초기화
    [_realm transactionWithBlock:^{
        [_realm deleteObjects:[AddedItem allObjects]];
    }];
    
}



- (void)finishedPickUpDate:(NSNotification *)noti{
    _pickUpDate = [noti userInfo][@"date"];
    NSString *pickUpTimeString = [self getStringFromDate:_pickUpDate];
    [_pickUpTimeLabel setText:pickUpTimeString];

    
    //배달시간 48시간 이후로 설정.
    _dropOffDate = [_pickUpDate dateByAddingTimeInterval:60*60*24*2];
    NSString *dropOffTimeString = [self getStringFromDate:_dropOffDate];
    NSString *dropOffTimeLabelString = [NSString stringWithFormat:@"%@%@",dropOffTimeString,NSLocalizedString(@"dropoff_datetime_c",nil)];
    [_dropOffTimeLabel setText:dropOffTimeLabelString];
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





- (void)configureEstimateLabel {
    
    if (_estimatePrice.integerValue){
        [_estimatePriceLabel setHidden:NO];
        NSLog(@"[estimate] %@",_estimatePrice);
        NSString *totalPriceString = [NSString stringWithFormat:@"%@%@",[_numberFormatter stringFromNumber:_estimatePrice],NSLocalizedString(@"monetary_unit",@"원")];
        _estimatePriceLabel.text = totalPriceString;
    }
    else {
        [_estimatePriceLabel setHidden:YES];
    }
}


- (void)viewWillAppear:(BOOL)animated{
    _dropOffLabelWidthConstraint.constant = _timeSelectView.frame.size.width-40;
}

- (void)viewDidAppear:(BOOL)animated{
    
    [super viewDidAppear:animated];
    [self beginAnimation];
    _items = [AddedItem allObjects];
    NSInteger estimatePrice = 0;
    for (AddedItem *item in _items) {
        estimatePrice += item.itemPrice.integerValue*item.addedCount.integerValue;
    }
    _estimatePrice = @(estimatePrice);
    [self configureEstimateLabel];
 
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
        [timeSelectViewController setStartDate:_pickUpDate];
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
    
    NSString *urlString = [NSString stringWithFormat:@"%@%@",CB_SERVER_URL,@"member/address"];
    [_manager GET:urlString
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
                 
                 if (data.firstObject[@"addr_building"]) {
                     self.addr_building = data.firstObject[@"addr_building"];
                 }
                 
                 _addressString = [NSString stringWithFormat:@"%@ %@",_address,_addr_building];
                 [_addressLabel setText:_addressString];
                 [self getDropOffInterval];
             }


         } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                NSLog(@"Error: %@", error);
            }];
}


- (void)getDropOffInterval{
    NSString *urlString = [NSString stringWithFormat:@"%@%@",CB_SERVER_URL,@"member/dropoff/dropoff_datetime"];
    [_manager GET:urlString
       parameters:nil
          success:^(AFHTTPRequestOperation *operation, id responseObject) {

              _dropOffInterval = responseObject[@"data"];

          } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                NSLog(@"Error: %@", error);
            }];
}



- (void)paymentMethodTap{
    UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:NSLocalizedString(@"payment_method",@"결제수단")
                                                             delegate:self
                                                    cancelButtonTitle:NSLocalizedString(@"label_cancel",@"취소")
                                               destructiveButtonTitle:nil
                                                    otherButtonTitles:NSLocalizedString(@"payment_card",nil),NSLocalizedString(@"payment_cash",nil),NSLocalizedString(@"payment_in_app_finish",nil),nil];

    [actionSheet showFromTabBar:self.tabBarController.tabBar];

}


- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {

    switch (buttonIndex+1){
        case CBPaymentMethodCard:{
            _paymentMethod = CBPaymentMethodCard;
            [_paymentMethodLabel setHidden:NO];
            [_paymentMethodLabel setText:[actionSheet buttonTitleAtIndex:buttonIndex]];
            break;
        }
        case CBPaymentMethodCash:{
            _paymentMethod = CBPaymentMethodCash;
            [_paymentMethodLabel setHidden:NO];
            [_paymentMethodLabel setText:[actionSheet buttonTitleAtIndex:buttonIndex]];
            break;
        }
        case CBPaymentMethodInApp:{
            _paymentMethod = CBPaymentMethodInApp;
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

    
    NSString *urlString = [NSString stringWithFormat:@"%@%@",CB_SERVER_URL,@"member/payment"];
    [manager GET:urlString
      parameters:nil
         success:^(AFHTTPRequestOperation *operation, id responseObject) {



             NSError *jsonError;
             NSData *objectData = [responseObject[@"data"] dataUsingEncoding:NSUTF8StringEncoding];
             NSDictionary *data = [NSJSONSerialization JSONObjectWithData:objectData
                                                             options:NSJSONReadingMutableContainers
                                                               error:&jsonError];

#warning Need LocalizedString
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
    
    if (_pickUpDate == nil) {
        [SVProgressHUD showErrorWithStatus:NSLocalizedString(@"time_dropoff_inform", nil)];
        return;
    } else if (_dropOffDate == nil) {
        [SVProgressHUD showErrorWithStatus:NSLocalizedString(@"time_dropoff_inform_after", nil)];
        return;
    } else if ( (_address == nil) || ([_addr_building isEqualToString:@""]) ){
        [SVProgressHUD showErrorWithStatus:NSLocalizedString(@"address_empty", nil)];
        [self editAddress];
        return;
    }
    
    [self showCheckAlert];
    
}


- (void)showCheckAlert{
    
    
    NSString *messageString = [NSString stringWithFormat:@"%@ : %@ %@\n%@ : %@\n%@ : %@",
                               NSLocalizedString(@"address", @"주소"), _address, _addr_building,
                               NSLocalizedString(@"pick_up_time_label", @"수거 시간"), [self getStringFromDate:_pickUpDate],
                               NSLocalizedString(@"drop_off_time_label", @"배달 시간"), [self getStringFromDate:_dropOffDate]
                               ];
    
    [UIAlertView showWithTitle:NSLocalizedString(@"주문 확인", @"주문 정보 확인")
                       message:messageString
             cancelButtonTitle:NSLocalizedString(@"label_cancel", @"취소")
             otherButtonTitles:@[NSLocalizedString(@"button_order", @"주문하기")]
                      tapBlock:^(UIAlertView *alertView, NSInteger buttonIndex){
                          if (buttonIndex == alertView.cancelButtonIndex) {
                              return;
                          }
                          else if (buttonIndex == [[alertView buttonTitleAtIndex:buttonIndex] isEqualToString:NSLocalizedString(@"button_order", @"주문하기")]){
                              [self addNewOrder];
                          }
                          
                      }];
    
}

- (void)addNewOrder{
    
    //수거-배달 최소 48시간
    NSDate *twoDaysAfterDate = [_pickUpDate dateByAddingTimeInterval:60*60*24*2];
    if ([_dropOffDate compare:twoDaysAfterDate] == NSOrderedAscending) {
        [UIAlertView showWithTitle:NSLocalizedString(@"toast_error", @"에러")
#warning Need LocalizedString
                           message:@"배달일은 수거일 2일 이후에 가능합니다."
                 cancelButtonTitle:NSLocalizedString(@"label_confirm", @"확인")
                 otherButtonTitles:nil
                          tapBlock:nil];

        return;
    }
    
    
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    
    manager.responseSerializer = [AFJSONResponseSerializer serializer];
    manager.responseSerializer.acceptableContentTypes = [manager.responseSerializer.acceptableContentTypes setByAddingObject:@"text/html"];
    
    
    //    RLMResults<User *> *users = [User allObjects];
    //    User *user = [users firstObject];
    
    //가격 로직
    NSNumber *price;
    NSNumber *dropoffPrice;
    
    if (self.estimatePrice.integerValue >= 20000) {
        price = self.estimatePrice;
        dropoffPrice = @0;
    }
    else{
        dropoffPrice = @2000;
        price = @(self.estimatePrice.integerValue + dropoffPrice.integerValue);
    }
    
    
    
    //결제수단 로직
    NSNumber *paymentMethod;
    
    if (self.paymentMethod == CBPaymentMethodInApp)
        paymentMethod = @3;
    else
        paymentMethod = @0;
    
    
    //아이템
    NSMutableArray *items = [NSMutableArray new];

    
    for (AddedItem *item in _items) {
        [items addObject:@{@"item_code":item.itemCode,
                           @"count":item.addedCount
                           }];
    }
    
    //품목 없을경우 처리
    if (items.count) {
        [items addObject:@{@"item_code":@999,@"category":@6,@"name":@"현장확인",@"descr":@"onthespot",@"price":@0,@"scope":@0,@"count":@1}];
    }
    
    
    NSDictionary *parameters = @{@"address":self.address,
                                 @"addr_building": self.addr_building,
                                 @"pickup_date":[self.stringFromDateFormatter stringFromDate:_pickUpDate],
                                 @"dropoff_date":[self.stringFromDateFormatter stringFromDate:_dropOffDate],
//                                 @"memo":@"테스트",
                                 @"price":price,
                                 @"dropoff_price":dropoffPrice,
                                 @"payment_method":paymentMethod,
                                 @"item":items,
                                 @"coupon":@[]
                                 };
    
    
    AFHTTPRequestSerializer *req = [AFHTTPRequestSerializer serializer];
    
    manager.requestSerializer = req;
    
    NSString *jsonString = [[NSString alloc] initWithData:[NSJSONSerialization dataWithJSONObject:parameters options:NSJSONWritingPrettyPrinted error:nil] encoding:NSUTF8StringEncoding];
    
    NSString *urlString = [NSString stringWithFormat:@"%@%@",CB_SERVER_URL,@"member/order/add/new"];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:urlString]
                                                           cachePolicy:NSURLRequestReloadIgnoringCacheData  timeoutInterval:10];
    
    [request setHTTPMethod:@"POST"];
    [request setValue: @"application/json" forHTTPHeaderField:@"Content-Type"];
    [request setHTTPBody: [jsonString dataUsingEncoding:NSUTF8StringEncoding]];
    
    
    AFHTTPRequestOperation *op = [[AFHTTPRequestOperation alloc] initWithRequest:request];
    op.responseSerializer = [AFJSONResponseSerializer serializerWithReadingOptions:NSJSONReadingAllowFragments];
    op.responseSerializer.acceptableContentTypes = [manager.responseSerializer.acceptableContentTypes setByAddingObject:@"text/html"];
    
    
    [op setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        int constant = [[responseObject valueForKey:@"constant"] intValue];
        
        switch (constant) {
            case CBServerConstantSuccess: {
                [SVProgressHUD showSuccessWithStatus:NSLocalizedString(@"order_success", nil)];
                [[CBNotificationManager sharedManager] addDropOffNoti:_dropOffDate oid:responseObject[@"data"]];
                [[CBNotificationManager sharedManager] addPickUpNoti:_pickUpDate oid:responseObject[@"data"]];
                [self initOrder];
                
            }
                break;
            case CBServerConstantError: {
                [SVProgressHUD showErrorWithStatus:NSLocalizedString(@"general_error", nil)];
            }
                break;
                
            case CBServerConstantsAreaUnavailable: {
                [SVProgressHUD showErrorWithStatus:NSLocalizedString(@"area_unavailable_error", nil)];
            }
                break;
                
            case CBServerConstantsDateUnavailable: {
                [SVProgressHUD showErrorWithStatus:NSLocalizedString(@"date_unavailable_error", nil)];
            }
                break;
                
            case CBServerConstantSessionExpired: {
                //                [self showHudMessage:@"세션이 만료되었습니다. 로그인화면으로 돌아갑니다."];
                //                [self resetItemsCount];
                //                [memoTextField setText:@""];
                //AppDelegate에 세션이 만료됨을 알림
                //                [[NSNotificationCenter defaultCenter] postNotificationName:@"sessionExpired" object:self];
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
    
    UIStoryboard *sb = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    
    UINavigationController *estimateVC = [sb instantiateViewControllerWithIdentifier:@"EstimateVC"];
    
    [self presentViewController:estimateVC animated:YES completion:nil];
}


#pragma mark - Animation
- (void)beginAnimation{
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


#pragma mark - Notification
- (void)addNotification{
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
}

- (void)removeNotification{
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                 name:@"didFinishAddCredit" object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                 name:@"didFinishEditAddress" object:nil];
    
    
    
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                 name:@"didFinishPickUpDate"
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                 name:@"didFinishDropOffDate"
                                               object:nil];
}


#pragma mark - ETC
- (UIStatusBarStyle)preferredStatusBarStyle {
    return UIStatusBarStyleLightContent;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}


@end
