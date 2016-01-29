//
//  TimeCollectionViewCell.m
//  CleanBasket
//
//  Created by 이상진 on 2016. 1. 11..
//  Copyright © 2016년 WashappKorea. All rights reserved.
//

#import "TimeCollectionViewCell.h"

@interface TimeCollectionViewCell()

@property (weak, nonatomic) IBOutlet UILabel *timeLabel;
@property (weak, nonatomic) IBOutlet UILabel *closeLabel;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *saleWidth;

@end

@implementation TimeCollectionViewCell



- (void)setTextWithDate:(NSDate *)date{
    
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
    
    
    [_timeLabel setText:[NSString stringWithFormat:@"%@%@",[firstDateFormatter stringFromDate:date],[lastDateFormatter stringFromDate:lastNewDate]]];


    
}


@end
