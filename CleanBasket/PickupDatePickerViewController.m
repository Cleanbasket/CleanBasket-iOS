//
//  PickupDatePickerViewController.m
//  CleanBasket
//
//  Created by Wonhyo Yi on 2014. 10. 22..
//  Copyright (c) 2014년 WashAppKorea. All rights reserved.
//

#import "PickupDatePickerViewController.h"

@interface PickupDatePickerViewController ()

@end

@implementation PickupDatePickerViewController

@synthesize currentOrder = currentOrder;

- (instancetype)init {
    self = [super init];
    if (self) {
        
    }
    return self;
}

- (void)viewDidLoad {
    [self.view setBackgroundColor:[UIColor whiteColor]];
    [self.navigationItem setTitle:@"수거일"];
    realm = [RLMRealm defaultRealm];
    
    dateInfoLabel = [[UILabel alloc] initWithFrame:CGRectMake(20, 84, 280, 120)];
    [dateInfoLabel setTextAlignment:NSTextAlignmentCenter];
    [dateInfoLabel setLineBreakMode:NSLineBreakByCharWrapping];
    [dateInfoLabel setText:@"현재 시간으로부터 1시간 후,\n30분 단위로 선택이 가능합니다.\n(최장 2주)"];
    [dateInfoLabel setTextColor:[UIColor grayColor]];
    [dateInfoLabel setNumberOfLines:0];
    [dateInfoLabel.layer setBorderColor:CleanBasketMint.CGColor];
    [dateInfoLabel.layer setBorderWidth:1.0f];
    [dateInfoLabel.layer setCornerRadius:15.0f];
    [dateInfoLabel setClipsToBounds:YES];
    
    datePicker = [[UIDatePicker alloc] initWithFrame:CGRectMake(0, 200, DEVICE_WIDTH, 200)];
    [datePicker addTarget:self action:@selector(datePickerChanged) forControlEvents:UIControlEventValueChanged];
    
    confirmButton = [[UIButton alloc] initWithFrame:CGRectMake(60, 420, 200, 35)];
    [confirmButton setBackgroundColor:CleanBasketMint];
    [confirmButton.layer setCornerRadius:15.0f];
    [confirmButton setTitle:@"확인" forState:UIControlStateNormal];
    [confirmButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [confirmButton setTitleColor:[UIColor blackColor] forState:UIControlStateHighlighted];
    [confirmButton addTarget:self action:@selector(didTouchConfirmButton) forControlEvents: UIControlEventTouchUpInside];
    
    [self refreshMinMaxDate];
    [datePicker setMinuteInterval:30];
    [self datePickerChanged];
    
    [self.view addSubview:confirmButton];
    [self.view addSubview:dateInfoLabel];
    [self.view addSubview:datePicker];
}

- (void) didTouchConfirmButton {
    if ([Order objectForPrimaryKey:[NSNumber numberWithInt:NEW_INDEX]])
    {
        NSLog(@"NEW ORDER HAVING NEW_INDEX FOUND!");
        [realm beginWriteTransaction];
        currentOrder = [Order objectForPrimaryKey:[NSNumber numberWithInt:NEW_INDEX]];
        [currentOrder setPickup_date:pickupDateString];
        [realm commitWriteTransaction];
    }
    
    else
    {
        NSLog(@"ORDER DOESN'T EXISTS!");
        [realm beginWriteTransaction];
        currentOrder = [[Order alloc] init];
        [currentOrder setOid:NEW_INDEX];
        [currentOrder setPickup_date:pickupDateString];
        [realm commitWriteTransaction];
    }
    
    [[NSNotificationCenter defaultCenter] postNotificationName:@"setPickupDate" object:nil];
    [self.navigationController popToRootViewControllerAnimated:YES];
}

- (void) refreshMinMaxDate {
    NSCalendar *calendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
    NSDate *currentDate = [NSDate date];
    NSDateComponents *currentDateComponents = [[NSCalendar currentCalendar] components:NSYearCalendarUnit|NSMonthCalendarUnit|NSDayCalendarUnit|NSHourCalendarUnit|NSMinuteCalendarUnit fromDate:[NSDate date]];
    
    NSDateComponents *comps = [[NSDateComponents alloc] init];
    [comps setDay:14];
    [comps setHour:24 - [currentDateComponents hour]];
    NSDate *maxDate = [calendar dateByAddingComponents:comps toDate:currentDate options:0];
    
    [comps setDay:0];
    [comps setHour:1];
    if ( [currentDateComponents minute] > 31 ) {
        [comps setMinute:60 - [currentDateComponents minute]];
    }
    NSDate *minDate = [calendar dateByAddingComponents:comps toDate:currentDate options:0];
    
    [datePicker setMaximumDate:maxDate];
    [datePicker setMinimumDate:minDate];
}

- (void) datePickerChanged {
    NSDateComponents *currentDateComponents = [[NSCalendar currentCalendar] components:NSYearCalendarUnit|NSMonthCalendarUnit|NSDayCalendarUnit|NSHourCalendarUnit|NSMinuteCalendarUnit fromDate:[NSDate date]];
    
    NSDateComponents *datePickerComponents = [[NSCalendar currentCalendar] components:NSYearCalendarUnit|NSMonthCalendarUnit|NSDayCalendarUnit|NSHourCalendarUnit|NSMinuteCalendarUnit fromDate:datePicker.date];
    
    if([datePickerComponents hour] < 10 && [datePickerComponents hour] > 1)
    {
        [datePickerComponents setHour:10];
        [datePickerComponents setMinute:0];
        [datePicker setDate:[[NSCalendar currentCalendar] dateFromComponents:datePickerComponents]];
    } else if ( [datePickerComponents hour] == 1) {
        [datePickerComponents setHour:0];
        [datePickerComponents setMinute:30];
        [datePicker setDate:[[NSCalendar currentCalendar] dateFromComponents:datePickerComponents]];
    }
    
    // 현재 시간보다 최소 1시간 이후로 선택할 수 있도록 만들기 위함
    if ( ([datePickerComponents day] == [currentDateComponents day]) &&
        ([datePickerComponents hour] - [currentDateComponents hour]) == 1 &&
        [datePickerComponents minute] <= [currentDateComponents minute] )
    {
        if ( [currentDateComponents minute] < 30 ) {
            [datePickerComponents setMinute:30];
            [datePicker setDate:[[NSCalendar currentCalendar] dateFromComponents:datePickerComponents]];
        }
        else {
            [datePickerComponents setHour:[currentDateComponents hour] + 1];
            [datePickerComponents setMinute:0];
            [datePicker setDate:[[NSCalendar currentCalendar] dateFromComponents:datePickerComponents]];
        }
    }
    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:00"];
    
    pickupDateString = [dateFormatter stringFromDate:[datePicker date]];
}

- (void) blinkDateInfoLabel {
    for ( int i = 0; i < 5; i++ ){
        [UIView animateWithDuration:0.01 animations:^{
            if ([[dateInfoLabel backgroundColor] isEqual:[UIColor whiteColor]]) {
                //                NSLog(@"to mint");
                [dateInfoLabel setBackgroundColor:CleanBasketMint];
            } else {
                //                NSLog(@"to white");
                [dateInfoLabel setBackgroundColor:[UIColor whiteColor]];
            }
        }];
    }
}

@end
