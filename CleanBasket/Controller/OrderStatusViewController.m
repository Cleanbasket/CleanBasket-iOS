//
//  OrderStatusViewController.m
//  CleanBasket
//
//  Created by 이상진 on 2016. 2. 2..
//  Copyright © 2016년 WashappKorea. All rights reserved.
//

#import "OrderStatusViewController.h"

#import <AFNetworking/AFNetworking.h>

@interface OrderStatusViewController ()

@property (weak, nonatomic) IBOutlet UIView *emptyOrderStatusView;
@property (nonatomic) NSDateFormatter *dateformatter;

@end


@implementation OrderStatusViewController

- (void)viewDidLoad{
    [self setTitle:NSLocalizedString(@"menu_label_delivery", nil)];
    
    
    self.currentOrderViewContainer.hidden = TRUE;
    self.emptyOrderStatusView.hidden = TRUE;
    
    self.dateformatter = [NSDateFormatter new];
    self.dateformatter.dateFormat = @"yyyy-MM-dd HH:mm:ss.s";
    
    [self.orderHistoryBarBtn setTitle:NSLocalizedString(@"label_order_history", @"주문내역")];
    
    [self.deliverNameLabel setText:NSLocalizedString(@"pd_name_default", @"pd기본이름")];
    [self.callButton setHidden:TRUE];
    [self.callButton setTitle:NSLocalizedString(@"pd_call", @"pd에게 전화하기") forState:UIControlStateNormal];
    [self.editOrderButton setTitle:NSLocalizedString(@"order_modify", @"주문 변경/취소") forState:UIControlStateNormal];
    [self loadOrderStatus];
    
    
    
}

- (void)loadOrderStatus{
    
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
                     NSLog(@"진행 :%@",data);
                     NSDictionary *orderInfo = data.firstObject;
                     
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
                     
                     [self.itemButton setTitle:[NSString stringWithFormat:@"%@ %zi%@",NSLocalizedString(@"label_item", @"품목"),[orderInfo[@"item"] count],NSLocalizedString(@"item_unit", @"개")] forState:UIControlStateNormal];
                     
                     [self.priceLabel setTitle:[NSString stringWithFormat:@"%@ %zi%@",NSLocalizedString(@"label_total", @"총계"),[orderInfo[@"price"] integerValue],NSLocalizedString(@"monetary_unit", @"원")] forState:UIControlStateNormal];
                     
                     self.currentOrderViewContainer.hidden = FALSE;
                     self.emptyOrderStatusView.hidden = TRUE;
                     
                     
                 }
                 else{
                     self.currentOrderViewContainer.hidden = TRUE;
                     self.emptyOrderStatusView.hidden = FALSE;
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