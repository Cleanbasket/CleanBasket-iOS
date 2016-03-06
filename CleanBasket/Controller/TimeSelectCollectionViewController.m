//
//  TimeSelectCollectionViewController.m
//  CleanBasket
//
//  Created by 이상진 on 2016. 1. 11..
//  Copyright © 2016년 WashappKorea. All rights reserved.
//

#import "TimeSelectCollectionViewController.h"
#import "TimeCollectionViewCell.h"
#import <AFNetworking/AFNetworking.h>

@interface TimeSelectCollectionViewController () {
    CBTimeSelectType _type;
}

@property CGFloat CELL_WIDTH;
@property NSDateFormatter *stringFromDateFormatter;
//@property NSDateFormatter *lastDateFormatter;
@property NSDate *date;
@property (nonatomic) NSMutableArray *pickupTimes;

@end

@implementation TimeSelectCollectionViewController

- (void)viewDidLoad{
    [super viewDidLoad];
    
    _CELL_WIDTH = self.collectionView.frame.size.width/2.0f;

    [self setNeedsStatusBarAppearanceUpdate];


    self.stringFromDateFormatter = [NSDateFormatter new];
    self.stringFromDateFormatter.dateFormat = @"yyyy-MM-dd HH:mm:ss.ss";

    
    
}


- (void)initWithDayInterval:(NSInteger)interval andType:(CBTimeSelectType)type{

    
    NSDate *today = [NSDate date];

    NSCalendar *calendar = [NSCalendar currentCalendar];

    unsigned unitFlags = NSCalendarUnitYear | NSCalendarUnitMonth |  NSCalendarUnitDay;
    NSDateComponents *dateComponents = [calendar components:unitFlags fromDate:today];

    [dateComponents setHour:10];
    [dateComponents setMinute:0];
    [dateComponents setDay:dateComponents.day+interval];


    _date = [calendar dateFromComponents:dateComponents];

    _type = type;
    
    
    
    _pickupTimes = [NSMutableArray new];
    
    if (_type == CBTimeSelectTypePickUp) {
        [self getPickUpTimeTable];
    } else {
        [self initDefaultTimeData];
    }
    
}


- (void)getPickUpTimeTable{
    
    
    AFHTTPRequestOperationManager *manager =[AFHTTPRequestOperationManager manager];
    
    manager.responseSerializer = [AFJSONResponseSerializer serializer];
    manager.responseSerializer.acceptableContentTypes = [manager.responseSerializer.acceptableContentTypes setByAddingObject:@"text/html"];
    [manager GET:@"http://www.cleanbasket.co.kr/member/pickup"
      parameters:nil
         success:^(AFHTTPRequestOperation *operation, id responseObject) {
             
             if ([responseObject[@"constant"]  isEqual: @1]) {
                 
                 NSError *jsonError;
                 NSData *objectData = [responseObject[@"data"] dataUsingEncoding:NSUTF8StringEncoding];
                 NSArray *datas = [NSJSONSerialization JSONObjectWithData:objectData
                                                                  options:NSJSONReadingMutableContainers
                                                                    error:&jsonError];
                 
//                 self.pickupTimes = datas;
                 
                 
                 for (int i = 0; i< 28; i++) {
                     
                     NSMutableDictionary *pickupTime = [NSMutableDictionary new];
                     
                     NSInteger minute = 30*i;
                     
                     NSDateComponents *components= [[NSDateComponents alloc] init];
                     [components setMinute:minute];
                     NSCalendar *calendar = [NSCalendar currentCalendar];
                     NSDate *newDate=[calendar dateByAddingComponents:components toDate:_date options:0];
                     
                     [pickupTime setObject:newDate forKey:@"datetime"];
                     
                     if (datas.count) {
                         for (NSDictionary *data in datas) {
                             NSDate *typeDate = [self.stringFromDateFormatter dateFromString:data[@"datetime"]];
                             if ([newDate isEqualToDate:typeDate]) {
                                 [pickupTime setObject:data[@"type"] forKey:@"type"];
                                 break;
                             }
                             else
                                 [pickupTime setObject:@(TimeTypeNone) forKey:@"type"];
                         }
                     }
                     else
                         [pickupTime setObject:@(TimeTypeNone) forKey:@"type"];
                   
                     
                     [self.pickupTimes addObject:pickupTime];
                     [self.collectionView reloadData];
                  
                     
                 }
                 
                 
                 

             }
             
             
             
             
         } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
             NSLog(@"Error: %@", error);
         }];

}

- (void)initDefaultTimeData{
    for (int i = 0; i< 28; i++) {
        
        NSMutableDictionary *time = [NSMutableDictionary new];
        
        NSInteger minute = 30*i;
        
        NSDateComponents *components= [[NSDateComponents alloc] init];
        [components setMinute:minute];
        NSCalendar *calendar = [NSCalendar currentCalendar];
        NSDate *newDate=[calendar dateByAddingComponents:components toDate:_date options:0];
        
        [time setObject:newDate forKey:@"datetime"];
        
        [time setObject:@(TimeTypeNone) forKey:@"type"];
        
        
        [self.pickupTimes addObject:time];
        [self.collectionView reloadData];
        
        
        
    }

}


- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath{
   
    
    
    NSInteger minute = 30*indexPath.item;

    NSDateComponents *components= [[NSDateComponents alloc] init];
    [components setMinute:minute];
    NSCalendar *calendar = [NSCalendar currentCalendar];
    NSDate *firstNewDate=[calendar dateByAddingComponents:components toDate:_date options:0];


    if (_orderStatusViewController == nil) {
        NSLog(@"오리지날");
        if (_type == CBTimeSelectTypePickUp)
            [[NSNotificationCenter defaultCenter] postNotificationName:@"didFinishPickUpDate" object:nil userInfo:@{@"date":firstNewDate}];
        else if (_type == CBTimeSelectTypeDropOff)
            [[NSNotificationCenter defaultCenter] postNotificationName:@"didFinishDropOffDate" object:nil userInfo:@{@"date":firstNewDate}];
    }
    else {
        
        if (_type == CBTimeSelectTypePickUp)
            [[NSNotificationCenter defaultCenter] postNotificationName:@"didFinishPickUpDateChange" object:nil userInfo:@{@"date":firstNewDate}];
        else if (_type == CBTimeSelectTypeDropOff)
            [[NSNotificationCenter defaultCenter] postNotificationName:@"didFinishDropOffDateChange" object:nil userInfo:@{@"date":firstNewDate}];
    }
        

    [self dismissViewControllerAnimated:NO completion:nil];
    
}

- (UICollectionViewCell*)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{

    TimeCollectionViewCell *cell;
    NSDate *cellDate = self.pickupTimes[indexPath.row][@"datetime"];
    
    switch ([self.pickupTimes[indexPath.row][@"type"] integerValue]) {
        case TimeTypeNone:
            cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"TimeCell" forIndexPath:indexPath];
//            [cell setTextWithDate:self.pickupTimes[indexPath.row][@"datetime"]];
            break;
        case TimeTypeSale:
        case TimeTypeSale2:
            cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"SaleCell" forIndexPath:indexPath];
//            [cell setTextWithDate:self.pickupTimes[indexPath.row][@"datetime"]];
            break;
        case TimeTypeClose:
            cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"CloseCell" forIndexPath:indexPath];
//            [cell setTextWithDate:self.pickupTimes[indexPath.row][@"datetime"]];
            break;
            
        default:
            break;
    }
    
    if (self.startDate != nil) {
        
        if ([cellDate compare:_startDate] == NSOrderedAscending) {
            cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"CloseCell" forIndexPath:indexPath];
        }
        
    
    }
    [cell setTextWithDate:cellDate];

    [cell setNeedsLayout];
    [cell layoutIfNeeded];
    
    return cell;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{
    return self.pickupTimes.count;
}


- (BOOL)collectionView:(UICollectionView *)collectionView shouldSelectItemAtIndexPath:(NSIndexPath *)indexPath {

//    TimeCollectionViewCell *cell = (TimeCollectionViewCell*)[collectionView cellForItemAtIndexPath:indexPath];


    if ([self.pickupTimes[indexPath.row][@"type"] integerValue] == TimeTypeClose)
        return NO;
    return YES;

}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath{
    return CGSizeMake(_CELL_WIDTH, 50);
}

- (UIStatusBarStyle)preferredStatusBarStyle {
    return UIStatusBarStyleLightContent;
}
@end
