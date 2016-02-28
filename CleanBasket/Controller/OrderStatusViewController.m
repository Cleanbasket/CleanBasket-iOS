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

@interface OrderStatusViewController ()

@property (weak, nonatomic) IBOutlet UIView *emptyOrderStatusView;
@property (nonatomic) NSDateFormatter *dateformatter;
@property (nonatomic) NSDictionary *currentOrder;

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
    [self.editOrderButton setTitle:NSLocalizedString(@"order_modify", @"주문 변경/취소") forState:UIControlStateNormal];
    [self.editOrderButton addTarget:self action:@selector(editOrder) forControlEvents:UIControlEventTouchUpInside];
    
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(refresh:) name:@"SVProgressHUDDidDisappearNotification" object:nil];
    
}
- (void)viewWillAppear:(BOOL)animated{
    
    [self loadOrderStatus];
}

- (void)viewDidAppear:(BOOL)animated{
    
    [self loadOrderStatus];
}


- (IBAction)refresh:(id)sender{
    
    [self loadOrderStatus];
}

- (void)editOrder{
    MMAlertViewConfig *alertConfig = [MMAlertViewConfig globalConfig];
    alertConfig.itemHighlightColor = CleanBasketMint;
    
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
    
    MMPopupItemHandler block = ^(NSInteger index){
        switch (index) {
            case 0:
                NSLog(@"품목변경");
                break;
            case 1:
                NSLog(@"시간변경");
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
    

    
    NSArray *items = @[MMItemMake(NSLocalizedString(@"change_item", nil), MMItemTypeHighlight, block),
                       MMItemMake(NSLocalizedString(@"change_time", nil), MMItemTypeHighlight, block),
                       MMItemMake(NSLocalizedString(@"order_cancel", nil), MMItemTypeHighlight, block),
                       MMItemMake(NSLocalizedString(@"label_back", nil), MMItemTypeNormal, block)];

    [[[MMAlertView alloc]initWithTitle:NSLocalizedString(@"label_order_modify", nil) detail:nil items:items]show];
}


- (void)cancelOrder{
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    //                AFJSONResponseSerializer *responseSerializer = [AFJSONResponseSerializer serializerWithReadingOptions:NSJSONReadingAllowFragments];
    manager.requestSerializer = [AFJSONRequestSerializer serializer];
    manager.responseSerializer = [AFJSONResponseSerializer serializer];
    //                manager.responseSerializer = responseSerializer;
    manager.responseSerializer.acceptableContentTypes = [manager.responseSerializer.acceptableContentTypes setByAddingObject:@"text/html"];
    
    [manager POST:@"http://52.79.39.100:8080/member/order/del/new"
       parameters:@{@"oid":self.currentOrder[@"oid"]}
          success:^(AFHTTPRequestOperation *operation, id responseObject){
              
              NSInteger constant = [responseObject[@"constant"] integerValue];
              if (constant == CBServerConstantSuccess) {
                  
                  
                  [SVProgressHUD showSuccessWithStatus:NSLocalizedString(@"order_delete_success", nil)];
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
    
    [manager GET:@"http://52.79.39.100:8080/member/order/recent"
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
                     switch ([orderInfo[@"state"] integerValue]) {
                         case 0:
                             statusImage = [UIImage imageNamed:@"ic_order_status_timeline1"];
                             break;
                         case 1:
                             statusImage = [UIImage imageNamed:@"ic_order_status_timeline2"];
                             break;
                         case 2:
                             statusImage = [UIImage imageNamed:@"ic_order_status_timeline3"];
                             break;
                         case 3:
                             statusImage = [UIImage imageNamed:@"ic_order_status_timeline4"];
                             break;
                             
                         default:
                             break;
                     }
                     
                     
                     self.orderStatusImageView.image = statusImage;
                     NSDate *pickUpDate = [self.dateformatter dateFromString:orderInfo[@"pickup_date"]];
                     NSDate *dropOffDate = [self.dateformatter dateFromString:orderInfo[@"dropoff_date"]];
                                           
                     self.pickUpDateLabel.text = [self formatedStringFromDate:pickUpDate];
                     self.dropOffDateLabel.text = [self formatedStringFromDate:dropOffDate];
                     
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


@end