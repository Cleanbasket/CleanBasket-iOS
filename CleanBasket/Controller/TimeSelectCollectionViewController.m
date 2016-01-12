//
//  TimeSelectCollectionViewController.m
//  CleanBasket
//
//  Created by 이상진 on 2016. 1. 11..
//  Copyright © 2016년 WashappKorea. All rights reserved.
//

#import "TimeSelectCollectionViewController.h"
#import "TimeCollectionViewCell.h"

#define CELL_HEIGHT 50.0f;

@interface TimeSelectCollectionViewController()

@property CGFloat CELL_WIDTH;
@property NSDateFormatter *firstDateFormatter;
@property NSDateFormatter *lastDateFormatter;
@property NSDate *date;

@end

@implementation TimeSelectCollectionViewController

- (void)viewDidLoad{
    [super viewDidLoad];
    
    _CELL_WIDTH = self.collectionView.frame.size.width/2.0f;
    _firstDateFormatter = [NSDateFormatter new];
    _lastDateFormatter = [NSDateFormatter new];
//    NSString *firstDateFormat = [NSString stringWithFormat:@"a %@~",NSLocalizedString(@"time_parse", nil)];
    NSString *firstDateFormat = @"a hh:mm~";
    [_firstDateFormatter setDateFormat:firstDateFormat];
//    NSString *lastDateFormat = [NSString stringWithFormat:@"%@",NSLocalizedString(@"time_parse", nil)];
    NSString *lastDateFormat = @"hh:mm";
    [_lastDateFormatter setDateFormat:lastDateFormat];




}


- (void)initWithDayInterval:(NSInteger)interval{

    NSDate *today = [NSDate date];

    NSCalendar *calendar = [NSCalendar currentCalendar];

    unsigned unitFlags = NSCalendarUnitYear | NSCalendarUnitMonth |  NSCalendarUnitDay;
    NSDateComponents *dateComponents = [calendar components:unitFlags fromDate:today];

    [dateComponents setHour:10];
    [dateComponents setMinute:0];
    [dateComponents setDay:dateComponents.day+interval];


    _date = [calendar dateFromComponents:dateComponents];

}


- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath{
    
    NSLog(@"%@",indexPath);



    NSInteger minute = 30*indexPath.item;

    NSDateComponents *components= [[NSDateComponents alloc] init];
    [components setMinute:minute];
    NSCalendar *calendar = [NSCalendar currentCalendar];
    NSDate *firstNewDate=[calendar dateByAddingComponents:components toDate:_date options:0];


    [[NSNotificationCenter defaultCenter] postNotificationName:@"didFinishPickUpDate" object:nil userInfo:@{@"date":firstNewDate}];

    [self dismissViewControllerAnimated:NO completion:nil];
    
}

- (UICollectionViewCell*)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{

    TimeCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"TimeCell" forIndexPath:indexPath];


    NSInteger minute = 30*indexPath.item;

    NSDateComponents *components= [[NSDateComponents alloc] init];
    [components setMinute:minute];
    NSCalendar *calendar = [NSCalendar currentCalendar];
    NSDate *firstNewDate=[calendar dateByAddingComponents:components toDate:_date options:0];

    [components setMinute:minute+60];
    NSDate *lastNewDate=[calendar dateByAddingComponents:components toDate:_date options:0];


    [cell setTimeText:[NSString stringWithFormat:@"%@%@",[_firstDateFormatter stringFromDate:firstNewDate],[_lastDateFormatter stringFromDate:lastNewDate]]];

//    arc4random();

    [cell setTimeType:arc4random()%4];

    return cell;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{
    return 26;
}


- (BOOL)collectionView:(UICollectionView *)collectionView shouldSelectItemAtIndexPath:(NSIndexPath *)indexPath {

    TimeCollectionViewCell *cell = [collectionView cellForItemAtIndexPath:indexPath];


    if (cell.timeType==TimeTypeClose)
        return NO;
    return YES;

}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath{
    return CGSizeMake(_CELL_WIDTH, 50);
}

@end
