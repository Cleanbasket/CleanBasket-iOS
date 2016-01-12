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


    [self setTitle:NSLocalizedString(@"time_dropoff_inform",nil)];

    UIStoryboard *sb = [UIStoryboard storyboardWithName:@"Main" bundle:nil];

    TimeSelectCollectionViewController *timeSelectCollectionViewController1 = [sb instantiateViewControllerWithIdentifier:@"TimeSelectCVC"];
    TimeSelectCollectionViewController *timeSelectCollectionViewController2 = [sb instantiateViewControllerWithIdentifier:@"TimeSelectCVC"];
    TimeSelectCollectionViewController *timeSelectCollectionViewController3 = [sb instantiateViewControllerWithIdentifier:@"TimeSelectCVC"];
    TimeSelectCollectionViewController *timeSelectCollectionViewController4 = [sb instantiateViewControllerWithIdentifier:@"TimeSelectCVC"];
    TimeSelectCollectionViewController *timeSelectCollectionViewController5 = [sb instantiateViewControllerWithIdentifier:@"TimeSelectCVC"];
    
    
    [_timeSelectCVCs addObject:timeSelectCollectionViewController1];
    [_timeSelectCVCs addObject:timeSelectCollectionViewController2];
    [_timeSelectCVCs addObject:timeSelectCollectionViewController3];
    [_timeSelectCVCs addObject:timeSelectCollectionViewController4];
    [_timeSelectCVCs addObject:timeSelectCollectionViewController5];

    
    for (NSInteger i = 0; i<_timeSelectCVCs.count; i++) {
        [_timeSelectCVCs[i] initWithDayInterval:i];
    }

    _dateFormatter = [NSDateFormatter new];
    [_dateFormatter setDateFormat:NSLocalizedStringFromTable(@"datetime_parse",@"Localizable",nil)];


//    [_dateFormatter setDateFormat:NSLocalizedString(@"datetime_parse",nil)];

//    [timeSelectCollectionViewController1 initWithDayInterval:0];
//
//    [timeSelectCVCs addObject:[UIViewController new]];
//    [timeSelectCVCs addObject:[UIViewController new]];
//    [timeSelectCVCs addObject:[UIViewController new]];


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
    [components setDay:index];
    NSCalendar *calendar = [NSCalendar currentCalendar];
    NSDate *addedDate=[calendar dateByAddingComponents:components toDate:date options:0];


//    NSDateComponents *dateComponents = [NSDateComponents new];
//    [dateComponents setDay:dateComponents.day+index];





    return [_dateFormatter stringFromDate:addedDate];
}


- (IBAction)dismissVC:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

@end
