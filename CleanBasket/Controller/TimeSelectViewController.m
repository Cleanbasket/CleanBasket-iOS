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
}

@end


@implementation TimeSelectViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setDataSource:self];
    [self setDelegate:self];

    _timeSelectCVCs = [NSMutableArray new];

    if (_timeSelectType == CBTimeSelectTypePickUp){
        [self setTitle:NSLocalizedString(@"pick_up_time_label",nil)];
    }
    else if (_timeSelectType == CBTimeSelectTypeDropOff){
        [self setTitle:NSLocalizedString(@"drop_off_time_label",nil)];
    }


    UIStoryboard *sb = [UIStoryboard storyboardWithName:@"Main" bundle:nil];


    for (int i = 0; i < 5; ++i) {

        TimeSelectCollectionViewController *timeSelectCollectionViewController = [sb instantiateViewControllerWithIdentifier:@"TimeSelectCVC"];

        [timeSelectCollectionViewController initWithDayInterval:i+_defaultInterval andType:_timeSelectType];
        timeSelectCollectionViewController.orderStatusViewController = _orderStatusVC;
        
        [_timeSelectCVCs addObject:timeSelectCollectionViewController];
        
    }

    [_timeSelectCVCs[0] setStartDate:_startDate];

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


    NSDate *date = [NSDate date];

    NSDateComponents *components= [[NSDateComponents alloc] init];
    [components setDay:index+_defaultInterval];
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
