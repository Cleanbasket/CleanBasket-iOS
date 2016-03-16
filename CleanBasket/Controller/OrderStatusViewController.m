//
//  OrderStatusViewController.m
//  CleanBasket
//
//  Created by 이상진 on 2016. 2. 2..
//  Copyright © 2016년 WashappKorea. All rights reserved.
//

#import "OrderStatusViewController.h"

#import <AFNetworking/AFNetworking.h>
#import <MMPopupView/MMAlertView.h>
#import "CBConstants.h"
#import "SVProgressHUD.h"
#import "ItemListViewController.h"
#import "TimeSelectViewController.h"
#import <Realm/Realm.h>
#import "AddedItem.h"
#import "CBNotificationManager.h"
#import "UIImageView+AFNetworking.h"

@interface OrderStatusViewController (){
    NSNumber *_dropOffInterval;
    RLMRealm *_realm;
    BOOL _isItemChange;
    NSNumber *_deliverPhoneNumber;
}

@property (weak, nonatomic) IBOutlet UIView *emptyOrderStatusView;
@property (nonatomic) NSDateFormatter *dateformatter;
@property (nonatomic) NSDictionary *currentOrder;
@property (strong, nonatomic) NSDate *pickUpDate,*dropOffDate;

@end


@implementation OrderStatusViewController

- (void)viewDidLoad{
    [self setTitle:NSLocalizedString(@"menu_label_delivery", nil)];
    
    self.dateformatter = [NSDateFormatter new];
    self.dateformatter.dateFormat = @"yyyy-MM-dd HH:mm:ss.s";
    
    [self.orderHistoryBarBtn setTitle:NSLocalizedString(@"label_order_history", @"주문내역")];
    
    [self.deliverNameLabel setText:NSLocalizedString(@"pd_name_default", @"pd기본이름")];
    [self.callButton setHidden:YES];
    [self.callButton setTitle:NSLocalizedString(@"pd_call", @"pd에게 전화하기") forState:UIControlStateNormal];
    [self.callButton addTarget:self action:@selector(tapCallBtn:) forControlEvents:UIControlEventTouchUpInside];
    [self.editOrderButton setTitle:NSLocalizedString(@"order_modify", @"주문 변경/취소") forState:UIControlStateNormal];
    [self.editOrderButton addTarget:self action:@selector(editOrder) forControlEvents:UIControlEventTouchUpInside];
    [self requestDropOffInterval];
    
    _realm = [RLMRealm defaultRealm];
    
    _isItemChange = NO;
    
    [self.itemButton addTarget:self action:@selector(showItems) forControlEvents:UIControlEventTouchUpInside];
//    [self.priceLabel addTarget:self action:@selector(showPriceInfo) forControlEvents:UIControlEventTouchUpInside];

    
    [self addNotification];
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(refresh:) name:@"SVProgressHUDDidDisappearNotification" object:nil];
    
}

- (id)initWithCoder:(NSCoder *)decoder
{
    self = [super initWithCoder:decoder];
    if (self) {
        self.tabBarItem.title = NSLocalizedString(@"menu_label_delivery", nil);
    }
    return self;
}

- (void)viewWillAppear:(BOOL)animated{
    [self loadOrderStatus];
}

- (void)viewDidAppear:(BOOL)animated{
    
    if (_isItemChange) {
        [self requestItemChange];
    }
    
    [self loadOrderStatus];
}


- (IBAction)refresh:(id)sender{
    
    [self loadOrderStatus];
}

- (void)tapCallBtn:(id)sender{
    NSString *phoneString = [NSString stringWithFormat:@"%@%zd",@"telprompt://",[_deliverPhoneNumber integerValue]];
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:phoneString]];
}



- (void)showItems{

  UIStoryboard *sb = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
  ItemListViewController *itemListViewController = [sb instantiateViewControllerWithIdentifier:@"ItemListViewController"];
    
    itemListViewController.items = _currentOrder[@"item"];
    
  [self.navigationController pushViewController:itemListViewController animated:YES];

}


- (void)editOrder{
    MMAlertViewConfig *alertConfig = [MMAlertViewConfig globalConfig];
    alertConfig.itemHighlightColor = CleanBasketMint;
    
    
    
    
    //수거배달시간변경
    MMPopupItemHandler timeChangeBlock = ^(NSInteger index){
        
        
        UIStoryboard *sb = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
        
        UINavigationController *timeSelectNVC = [sb instantiateViewControllerWithIdentifier:@"TimeSelectNVC"];
        
        
        TimeSelectViewController *timeSelectViewController = [timeSelectNVC.viewControllers firstObject];
        
        timeSelectViewController.orderStatusVC = self;
        
        
        switch (index) {
            case 0:{
                if ([_currentOrder[@"state"] isEqualToNumber:@2]) {
                    [SVProgressHUD showErrorWithStatus:NSLocalizedString(@"unable_pickup_date", nil)];
                    break;
                }
                [timeSelectViewController setTimeSelectType:CBTimeSelectTypePickUp];
#warning 최소 수거시간 처리 필요
                [timeSelectViewController setStartDate:[NSDate new]];
            }
                break;
            case 1:{
                [timeSelectViewController setTimeSelectType:CBTimeSelectTypeDropOff];
                [timeSelectViewController setDefaultInterval:_dropOffInterval];
#warning 최소 수거시간 처리 필요
                [timeSelectViewController setStartDate:[NSDate new]];

            }
                break;
                
            default:
                return;
                break;
        }
        
        
        [SVProgressHUD show];
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [SVProgressHUD dismiss];
            [self presentViewController:timeSelectNVC animated:YES completion:nil];
        });
        
    };
    
    
    //주문취소
    MMPopupItemHandler orderCancelBlock = ^(NSInteger index){
        switch (index) {
            case 0:
                NSLog(@"취소");
                break;
            case 1:{
                NSLog(@"확인");
                [self cancelOrder];
            }
                break;
                
            default:
                break;
        }
        
    };
    
    
    
    MMPopupItemHandler block;
    
    if ([self.currentOrder[@"state"] integerValue]==0) {
        block = ^(NSInteger index){
            switch (index) {
                case 0:{
                    [_realm beginWriteTransaction];
                    [_realm deleteObjects:[AddedItem allObjects]];
                    
                    for (NSDictionary *item in _currentOrder[@"item"]) {
                        AddedItem *addedItem = [AddedItem new];
                        addedItem.itemCode = item[@"item_code"];
                        addedItem.itemPrice = item[@"price"];
                        addedItem.addedCount = item[@"count"];
                        [_realm addObject:addedItem];
                    }
                    
                    [_realm commitWriteTransaction];
                    NSLog(@"품목변경");
                    _isItemChange = YES;
                    
                    UIStoryboard *sb = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
                    
                    UINavigationController *estimateVC = [sb instantiateViewControllerWithIdentifier:@"EstimateVC"];
                    
                    [self presentViewController:estimateVC animated:YES completion:nil];
                
                }
                    
                    break;
                case 1:{
                    NSLog(@"시간변경");
                    NSArray *items = @[MMItemMake(NSLocalizedString(@"change_pickup_date", nil), MMItemTypeHighlight, timeChangeBlock),
                                       MMItemMake(NSLocalizedString(@"change_dropoff_date", nil), MMItemTypeHighlight, timeChangeBlock),
                                       MMItemMake(NSLocalizedString(@"label_cancel", nil), MMItemTypeNormal, timeChangeBlock)];
                    NSString *timeChangeMessage = [NSString stringWithFormat:@"%@ : %@\n%@ : %@",NSLocalizedString(@"pick_up_time_label", nil),self.pickUpDateLabel.text,NSLocalizedString(@"drop_off_time_label", nil),self.dropOffDateLabel.text];
                    
                    [[[MMAlertView alloc]initWithTitle:NSLocalizedString(@"change_date", nil) detail:timeChangeMessage items:items]show];
                    
                    
                }
                    break;
                case 2:{
                    NSLog(@"주문취소");
                    
                    NSArray *items = @[MMItemMake(NSLocalizedString(@"label_cancel", nil), MMItemTypeNormal, orderCancelBlock),
                                       MMItemMake(NSLocalizedString(@"label_confirm", nil), MMItemTypeHighlight, orderCancelBlock)];
                    [[[MMAlertView alloc]initWithTitle:NSLocalizedString(@"order_cancel_confirm", nil) detail:nil items:items]show];
                    
                }
                    break;
                case 3:
                    NSLog(@"뒤로");
                    break;
                    
                default:
                    break;
            }
        };
    }
    else if([self.currentOrder[@"state"] integerValue]==1){
        block = ^(NSInteger index){
            switch (index) {
                case 0:{
                    NSArray *items = @[MMItemMake(NSLocalizedString(@"change_pickup_date", nil), MMItemTypeHighlight, timeChangeBlock),
                                       MMItemMake(NSLocalizedString(@"change_dropoff_date", nil), MMItemTypeHighlight, timeChangeBlock),
                                       MMItemMake(NSLocalizedString(@"label_cancel", nil), MMItemTypeNormal, timeChangeBlock)];
                    NSString *timeChangeMessage = [NSString stringWithFormat:@"%@ : %@\n%@ : %@",NSLocalizedString(@"pick_up_time_label", nil),self.pickUpDateLabel.text,NSLocalizedString(@"drop_off_time_label", nil),self.dropOffDateLabel.text];
                    
                    [[[MMAlertView alloc]initWithTitle:NSLocalizedString(@"change_date", nil) detail:timeChangeMessage items:items]show];
                    
                }
                    break;
                case 1:
                    NSLog(@"뒤로");
                    break;
                    
                default:
                    break;
            }
        };
        
    }
    else {
        block = ^(NSInteger index){
            switch (index) {
                case 0:{
                    
                    NSArray *items = @[MMItemMake(NSLocalizedString(@"change_pickup_date", nil), MMItemTypeHighlight, timeChangeBlock),
                                       MMItemMake(NSLocalizedString(@"change_dropoff_date", nil), MMItemTypeHighlight, timeChangeBlock),
                                       MMItemMake(NSLocalizedString(@"label_cancel", nil), MMItemTypeNormal, timeChangeBlock)];
                    NSString *timeChangeMessage = [NSString stringWithFormat:@"%@ : %@\n%@ : %@",NSLocalizedString(@"pick_up_time_label", nil),self.pickUpDateLabel.text,NSLocalizedString(@"drop_off_time_label", nil),self.dropOffDateLabel.text];
                    
                    [[[MMAlertView alloc]initWithTitle:NSLocalizedString(@"change_date", nil) detail:timeChangeMessage items:items]show];
                    
                }
                    break;
                case 1:
                    NSLog(@"뒤로");
                    break;
                    
                default:
                    break;
            }
        };
        
    }
    
    
    NSArray *items;

    switch ([self.currentOrder[@"state"] integerValue]) {
        case 0:
            items = @[MMItemMake(NSLocalizedString(@"change_item", nil), MMItemTypeHighlight, block),
                      MMItemMake(NSLocalizedString(@"change_time", nil), MMItemTypeHighlight, block),
                      MMItemMake(NSLocalizedString(@"order_cancel", nil), MMItemTypeHighlight, block),
                      MMItemMake(NSLocalizedString(@"label_back", nil), MMItemTypeNormal, block)];
            break;
            
        case 1:
            items = @[MMItemMake(NSLocalizedString(@"change_time", nil), MMItemTypeHighlight, block),
                      MMItemMake(NSLocalizedString(@"label_back", nil), MMItemTypeNormal, block)];
            break;
            
        case 2:
        case 3:
            items = @[MMItemMake(NSLocalizedString(@"change_time", nil), MMItemTypeHighlight, block),
                      MMItemMake(NSLocalizedString(@"label_back", nil), MMItemTypeNormal, block)];
            break;
            
            
        default:
            break;
    }
    

    [[[MMAlertView alloc]initWithTitle:NSLocalizedString(@"label_order_modify", nil) detail:nil items:items]show];
}


- (void)cancelOrder{
    NSString *oid = self.currentOrder[@"oid"];
    
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    //                AFJSONResponseSerializer *responseSerializer = [AFJSONResponseSerializer serializerWithReadingOptions:NSJSONReadingAllowFragments];
    manager.requestSerializer = [AFJSONRequestSerializer serializer];
    manager.responseSerializer = [AFJSONResponseSerializer serializer];
    //                manager.responseSerializer = responseSerializer;
    manager.responseSerializer.acceptableContentTypes = [manager.responseSerializer.acceptableContentTypes setByAddingObject:@"text/html"];
    
    NSString *urlString = [NSString stringWithFormat:@"%@%@",CB_SERVER_URL,@"member/order/del/new"];
    [manager POST:urlString
       parameters:@{@"oid":oid}
          success:^(AFHTTPRequestOperation *operation, id responseObject){
              
              NSInteger constant = [responseObject[@"constant"] integerValue];
              if (constant == CBServerConstantSuccess) {
                  [SVProgressHUD showSuccessWithStatus:NSLocalizedString(@"order_delete_success", nil)];
                  //취소 성공시 노티 삭제
                  [[CBNotificationManager sharedManager] removeNotiByOid:oid];
              }
              else if (constant == CBServerConstantsImpossible){
                  
                  [SVProgressHUD showErrorWithStatus:NSLocalizedString(@"delete_impossible", nil)];
              }
              
          } failure:^(AFHTTPRequestOperation *operation, NSError *error){
              NSLog(@"주문 취소 에러 : %@",error.localizedDescription);
          }];

}



- (void)loadOrderStatus{
    
    self.currentOrderViewContainer.hidden = YES;
    self.emptyOrderStatusView.hidden = YES;
    
    self.currentOrder = nil;
    
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    AFJSONResponseSerializer *responseSerializer = [AFJSONResponseSerializer serializerWithReadingOptions:NSJSONReadingAllowFragments];
    //    manager.responseSerializer = [AFJSONResponseSerializer serializer];
    manager.responseSerializer = responseSerializer;
    manager.responseSerializer.acceptableContentTypes = [manager.responseSerializer.acceptableContentTypes setByAddingObject:@"text/html"];
    
    NSString *urlString = [NSString stringWithFormat:@"%@%@",CB_SERVER_URL,@"member/order/recent"];
    [manager GET:urlString
      parameters:nil
         success:^(AFHTTPRequestOperation *operation, id responseObject){
         
             if (responseObject[@"constant"]) {
                 
                 NSError *jsonError;
                 NSData *objectData = [responseObject[@"data"] dataUsingEncoding:NSUTF8StringEncoding];
                 NSArray *data = [NSJSONSerialization JSONObjectWithData:objectData
                                                                         options:NSJSONReadingMutableContainers
                                                                           error:&jsonError];
                 
                 
                 if (data.count) {
                     NSDictionary *orderInfo = data.firstObject;
                     self.currentOrder = orderInfo;
                     
                     UIImage *statusImage = nil;
                     switch ([self.currentOrder[@"state"] integerValue]) {
                         case 0:
                             statusImage = [UIImage imageNamed:@"ic_order_status_timeline0"];
                             break;
                         case 1:
                             statusImage = [UIImage imageNamed:@"ic_order_status_timeline1"];
                             break;
                         case 2:
                             statusImage = [UIImage imageNamed:@"ic_order_status_timeline2"];
                             break;
                         case 3:
                             statusImage = [UIImage imageNamed:@"ic_order_status_timeline3"];
                             break;
                         case 4:
                             statusImage = [UIImage imageNamed:@"ic_order_status_timeline4"];
                             break;
                             
                         default:
                             break;
                     }
                     
                     
                     self.orderStatusImageView.image = statusImage;
                     _pickUpDate = [self.dateformatter dateFromString:orderInfo[@"pickup_date"]];
                     _dropOffDate = [self.dateformatter dateFromString:orderInfo[@"dropoff_date"]];
                     
                     _callButton.hidden = YES;
                     [_deliverImageView setImage:[UIImage imageNamed:@"ic_launcher"]];
                     
                     NSNumberFormatter *numberFormatter = [NSNumberFormatter new];
                     numberFormatter.numberStyle = NSNumberFormatterDecimalStyle;
                     NSString *imageUrlString = @"";
                     
                     switch ([self.currentOrder[@"state"] integerValue]) {
                         case 0:
                             [_deliverImageView setImage:[UIImage imageNamed:@"ic_launcher"]];
                             _deliverNameLabel.text = @"";
                             break;
                         case 1:
                             imageUrlString = [NSString stringWithFormat:@"%@%@",CB_SERVER_URL,_currentOrder[@"pickupInfo"][@"img"]];
                             
                             _callButton.hidden = NO;
                             _deliverNameLabel.text = _currentOrder[@"pickupInfo"][@"name"];
                             [_deliverImageView setImageWithURL:[NSURL URLWithString:imageUrlString]];
                             _deliverPhoneNumber = [numberFormatter numberFromString:_currentOrder[@"pickupInfo"][@"phone"]];
                             break;
                         case 2:
                             [_deliverImageView setImage:[UIImage imageNamed:@"ic_launcher"]];
                             _deliverNameLabel.text = @"";
                             break;
                         case 3:
                             imageUrlString = [NSString stringWithFormat:@"%@%@",CB_SERVER_URL,_currentOrder[@"dropoffInfo"][@"img"]];
                             
                             
                             _callButton.hidden = NO;
                             _deliverNameLabel.text = _currentOrder[@"dropoffInfo"][@"name"];
                             [_deliverImageView setImageWithURL:[NSURL URLWithString:imageUrlString]];
                             _deliverPhoneNumber = [numberFormatter numberFromString:_currentOrder[@"dropOffInfo"][@"phone"]];
                             break;
                         case 4:
                             [_deliverImageView setImage:[UIImage imageNamed:@"ic_launcher"]];
                             _deliverNameLabel.text = @"";
                             break;
                             
                         default:
                             break;
                     }
                     
                     self.pickUpDateLabel.text = [self formatedStringFromDate:_pickUpDate];
                     self.dropOffDateLabel.text = [self formatedStringFromDate:_dropOffDate];
                     
                     NSInteger itemCount = 0;
                     for (NSDictionary *item in orderInfo[@"item"]) {
                         itemCount += [item[@"count"] integerValue];
                     }
                     
                     [self.itemButton setTitle:[NSString stringWithFormat:@"%@ %zi%@",NSLocalizedString(@"label_item", @"품목"),itemCount,NSLocalizedString(@"item_unit", @"개")] forState:UIControlStateNormal];
                     
                     [self.priceLabel setTitle:[NSString stringWithFormat:@"%@ %zi%@",NSLocalizedString(@"label_total", @"총계"),[orderInfo[@"price"] integerValue],NSLocalizedString(@"monetary_unit", @"원")] forState:UIControlStateNormal];
                     
                     self.currentOrderViewContainer.hidden = NO;
                     self.emptyOrderStatusView.hidden = YES;
                     
                     
                 }
                 else{
                     self.currentOrderViewContainer.hidden = YES;
                     self.emptyOrderStatusView.hidden = NO;
                 }
                 
             }
             
         } failure:^(AFHTTPRequestOperation *operation, NSError *error){
             NSLog(@"현재 주문 가져오기 실패 : %@",error.localizedDescription);
         }];
    
}



#pragma mark - NOtification
- (void)addNotification{
    
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(finishedPickUpDate:)
                                                 name:@"didFinishPickUpDateChange"
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(finishedDropOffDate:)
                                                 name:@"didFinishDropOffDateChange"
                                               object:nil];
}

- (void)removeNotification{
    
    
//    [[NSNotificationCenter defaultCenter] removeObserver:self
//                                                    name:@"didFinishPickUpDate"
//                                                  object:nil];
//    
//    [[NSNotificationCenter defaultCenter] removeObserver:self
//                                                    name:@"didFinishDropOffDate"
//                                                  object:nil];
}


- (void)finishedPickUpDate:(NSNotification *)noti{
    _pickUpDate = [noti userInfo][@"date"];
    
    NSString *pickUpTimeString = [self getStringFromDate:_pickUpDate];
    [_pickUpDateLabel setText:pickUpTimeString];
    
    
    
    //최소 배달시간 = 수거시간+48 설정.
    NSDate *minDate = [_pickUpDate dateByAddingTimeInterval:60*60*24*2];
    
    if ([minDate compare:_dropOffDate] == NSOrderedDescending) {
        _dropOffDate = [_pickUpDate dateByAddingTimeInterval:60*60*24*3];
        NSString *dropOffTimeString = [self getStringFromDate:_dropOffDate];
        NSString *dropOffTimeLabelString = [NSString stringWithFormat:@"%@%@",dropOffTimeString,NSLocalizedString(@"dropoff_datetime_c",nil)];
        [_dropOffDateLabel setText:dropOffTimeLabelString];
    }
    
    
    [self requestTimeChange];
}


- (void)finishedDropOffDate:(NSNotification *)noti{
    
    _dropOffDate = [noti userInfo][@"date"];
    NSString *dropOffTimeString = [self getStringFromDate:_dropOffDate];
    
    NSString *dropOffTimeLabelString = [NSString stringWithFormat:@"%@%@",dropOffTimeString,NSLocalizedString(@"dropoff_datetime_c",nil)];
    
    [_dropOffDateLabel setText:dropOffTimeLabelString];
    
    [self requestTimeChange];
}

#pragma mark -
- (NSString*)formatedStringFromDate:(NSDate *)date{
    NSString *string = nil;
    
    
    NSDateFormatter *dayFormatter = [NSDateFormatter new];
    [dayFormatter setDateFormat:NSLocalizedStringFromTable(@"datetime_parse",@"Localizable",nil)];
    
    NSDateFormatter *firstDateFormatter = [NSDateFormatter new];
    NSDateFormatter *lastDateFormatter = [NSDateFormatter new];
    //    NSString *firstDateFormat = [NSString stringWithFormat:@"a %@~",NSLocalizedString(@"time_parse", nil)];
    NSString *firstDateFormat = @"a hh:mm~";
    [firstDateFormatter setDateFormat:firstDateFormat];
    //    NSString *lastDateFormat = [NSString stringWithFormat:@"%@",NSLocalizedString(@"time_parse", nil)];
    NSString *lastDateFormat = @"hh:mm";
    [lastDateFormatter setDateFormat:lastDateFormat];
    //    NSDateComponents *components = [NSDateComponents new];
    NSCalendar *calendar = [NSCalendar currentCalendar];
    NSDateComponents *components = [calendar components:NSCalendarUnitYear|NSCalendarUnitMonth|NSCalendarUnitDay|NSCalendarUnitHour|NSCalendarUnitMinute fromDate:date];
    
    [components setMinute:components.minute+60];
    NSDate *lastNewDate=[calendar dateFromComponents:components];
    
    
    string = [NSString stringWithFormat:@"%@\n%@%@",[dayFormatter stringFromDate:date],[firstDateFormatter stringFromDate:date],[lastDateFormatter stringFromDate:lastNewDate]];
    
    return string;
    
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



#pragma mark - network
- (void)requestDropOffInterval{
    
    AFHTTPRequestOperationManager *_manager = [AFHTTPRequestOperationManager manager];
    
    _manager.responseSerializer = [AFJSONResponseSerializer serializer];
    _manager.responseSerializer.acceptableContentTypes = [_manager.responseSerializer.acceptableContentTypes setByAddingObject:@"text/html"];
    
    NSString *urlString = [NSString stringWithFormat:@"%@%@",CB_SERVER_URL,@"member/dropoff/dropoff_datetime"];
    [_manager GET:urlString
       parameters:nil
          success:^(AFHTTPRequestOperation *operation, id responseObject) {
              
              _dropOffInterval = responseObject[@"data"];
              
          } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
              NSLog(@"Error: %@", error);
          }];
}

- (void)requestTimeChange{
    
    
    
    
    AFHTTPRequestOperationManager *_manager = [AFHTTPRequestOperationManager manager];
    
    _manager.requestSerializer = [AFJSONRequestSerializer serializer];
    _manager.responseSerializer = [AFJSONResponseSerializer serializer];
    _manager.responseSerializer.acceptableContentTypes = [_manager.responseSerializer.acceptableContentTypes setByAddingObject:@"text/html"];
    
    
    
    NSDateFormatter *stringFromDateFormatter = [NSDateFormatter new];
    stringFromDateFormatter.dateFormat = @"yyyy-MM-dd HH:mm:ss.s";
    
    NSDictionary *parameters = @{@"oid":_currentOrder[@"oid"],@"pickup_date":[stringFromDateFormatter stringFromDate:_pickUpDate],@"dropoff_date":[stringFromDateFormatter stringFromDate:_dropOffDate]};
    
    NSString *urlString = [NSString stringWithFormat:@"%@%@",CB_SERVER_URL,@"member/order/date"];
    [_manager POST:urlString
        parameters:parameters
          success:^(AFHTTPRequestOperation *operation, id responseObject) {
              
              if ([responseObject[@"constant"] isEqualToNumber:@1]) {
                  [SVProgressHUD showSuccessWithStatus:NSLocalizedString(@"order_modify_success", @"주문수정성공")];
              }
              
          } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
              NSLog(@"Error: %@", error);
          }];
}

- (void)requestItemChange{
    
    AFHTTPRequestOperationManager *_manager = [AFHTTPRequestOperationManager manager];
    
    _manager.requestSerializer = [AFJSONRequestSerializer serializer];
    _manager.responseSerializer = [AFJSONResponseSerializer serializer];
    _manager.responseSerializer.acceptableContentTypes = [_manager.responseSerializer.acceptableContentTypes setByAddingObject:@"text/html"];
    
    //가격 로직
    NSNumber *price;
    NSNumber *dropoffPrice;
    
    RLMResults *addedItems = [AddedItem allObjects];
    NSInteger estimatePrice = 0;
    for (AddedItem *item in addedItems) {
        estimatePrice += item.itemPrice.integerValue*item.addedCount.integerValue;
    }

    if (estimatePrice >= 20000) {
        price = @(estimatePrice);
        dropoffPrice = @0;
    }
    else{
        dropoffPrice = @2000;
        price = @(estimatePrice + dropoffPrice.integerValue);
    }
    
    //아이템
    NSMutableArray *items = [NSMutableArray new];
    
    
    for (AddedItem *item in addedItems) {
        [items addObject:@{@"item_code":item.itemCode,
                           @"count":item.addedCount
                           }];
    }
    
    

    
    NSDateFormatter *stringFromDateFormatter = [NSDateFormatter new];
    stringFromDateFormatter.dateFormat = @"yyyy-MM-dd HH:mm:ss.s";
    
    
    
    NSDictionary *parameters = @{@"oid":_currentOrder[@"oid"],
                                 @"dropoff_date":[stringFromDateFormatter stringFromDate:_dropOffDate],
                                 @"state":_currentOrder[@"state"],
                                 @"price":price,
                                 @"dropoff_price":dropoffPrice,
                                 @"item":items
                                 };
    
    NSString *urlString = [NSString stringWithFormat:@"%@%@",CB_SERVER_URL,@"member/order/modify"];
    [_manager POST:urlString
        parameters:parameters
           success:^(AFHTTPRequestOperation *operation, id responseObject) {
               
               
               NSLog(@"[RES] %@",responseObject);
               
               if ([responseObject[@"constant"] isEqualToNumber:@1]) {
                   [SVProgressHUD showSuccessWithStatus:NSLocalizedString(@"order_modify_success", @"주문수정성공")];
               }
               _isItemChange = NO;
               
           } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
               NSLog(@"Error: %@", error);
           }];
}



@end