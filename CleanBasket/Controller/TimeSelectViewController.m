//
//  TimeSelectViewController.m
//  CleanBasket
//
//  Created by 이상진 on 2016. 1. 12..
//  Copyright © 2016년 WashappKorea. All rights reserved.
//

#import "TimeSelectViewController.h"
#import "TimeSelectCollectionViewController.h"
#import "CBConstants.h"


@interface TimeSelectViewController()<GUITabPagerDataSource,GUITabPagerDelegate>{
    NSMutableArray *_timeSelectCVCs;
    NSDateFormatter *_dateFormatter;
    NSDate *_twoDaysLater;
    NSDate *_defaultIntervarDaysLater;
}

@end


@implementation TimeSelectViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setDataSource:self];
    [self setDelegate:self];
    
    
    unsigned unitFlags = NSCalendarUnitYear | NSCalendarUnitMonth |  NSCalendarUnitDay | NSCalendarUnitHour | NSCalendarUnitMinute;
    
    //타입에 따른 설정
    if (_timeSelectType == CBTimeSelectTypePickUp)
        [self setTitle:NSLocalizedString(@"pick_up_time_label",nil)];
    
    else if (_timeSelectType == CBTimeSelectTypeDropOff){
        [self setTitle:NSLocalizedString(@"drop_off_time_label",nil)];
        
        //수거시간+24시간
        _twoDaysLater = [_startDate dateByAddingTimeInterval:60*60*24*2];
        
        
        
        //현재시간+받아온 최소배달시간
        _defaultIntervarDaysLater = [[NSDate date] dateByAddingTimeInterval:60*60*24*_defaultInterval.integerValue];
        
        //수거시간 2일 후 날짜가 더 큰 경우 defaultIntervar 변경
        if ([_twoDaysLater compare:_defaultIntervarDaysLater] == NSOrderedDescending) {
            _defaultIntervarDaysLater = _twoDaysLater;
        }
        
    }
    
        
    
    
    
    

    
    
    _timeSelectCVCs = [NSMutableArray new];
    
    UIStoryboard *sb = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    for (int i = 0; i < 5; ++i) {
        
        NSCalendar *calendar = [NSCalendar currentCalendar];
        
        NSDateComponents *dateComponents;
        
        if (_timeSelectType == CBTimeSelectTypePickUp) {
            dateComponents = [calendar components:unitFlags fromDate:_startDate];
            dateComponents.day += i;
        }
        else {
            dateComponents = [calendar components:unitFlags fromDate:_defaultIntervarDaysLater];
            dateComponents.day += i;
        }
        
        TimeSelectCollectionViewController *timeSelectCollectionViewController = [sb instantiateViewControllerWithIdentifier:@"TimeSelectCVC"];
        
        [timeSelectCollectionViewController initWithStartDate:[calendar dateFromComponents:dateComponents] andType:_timeSelectType];
        timeSelectCollectionViewController.orderStatusViewController = _orderStatusVC;
        
        [_timeSelectCVCs addObject:timeSelectCollectionViewController];
        
    }
    
    //시작시간 설정
    if (_timeSelectType == CBTimeSelectTypePickUp)
        [_timeSelectCVCs[0] setStartDate:_startDate];
    else if (_timeSelectType == CBTimeSelectTypeDropOff)
        [_timeSelectCVCs[0] setStartDate:_defaultIntervarDaysLater];

    
    


    _dateFormatter = [NSDateFormatter new];
    [_dateFormatter setDateFormat:NSLocalizedStringFromTable(@"datetime_parse",@"Localizable",nil)];
    
    
    [self setNeedsStatusBarAppearanceUpdate];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self reloadData];
}


- (UIColor*)tabColor{
    return CleanBasketMint;
}

- (UIFont *)titleFont {
    UIFont *font = [UIFont systemFontOfSize:14];

    return font;
}

- (NSInteger)numberOfViewControllers{
    return _timeSelectCVCs.count;
}

- (UIViewController *)viewControllerForIndex:(NSInteger)index{

    return _timeSelectCVCs[index];

}

- (NSString*)titleForTabAtIndex:(NSInteger)index{


    NSDate *date;
    
    if (_timeSelectType == CBTimeSelectTypePickUp) {
        date = _startDate;
    }
    else
        date = _defaultIntervarDaysLater;
    

    NSDateComponents *components= [[NSDateComponents alloc] init];
    [components setDay:index];
    NSCalendar *calendar = [NSCalendar currentCalendar];
    NSDate *addedDate=[calendar dateByAddingComponents:components toDate:date options:0];



    return [_dateFormatter stringFromDate:addedDate];
}


- (IBAction)dismissVC:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}


- (UIStatusBarStyle)preferredStatusBarStyle {
    return UIStatusBarStyleLightContent;
}

@end
