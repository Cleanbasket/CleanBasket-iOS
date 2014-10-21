//
//  OrderViewController.m
//  CleanBasket
//
//  Created by Wonhyo Yi on 2014. 10. 3..
//  Copyright (c) 2014년 WashAppKorea. All rights reserved.
//

#import "OrderViewController.h"
#define X_FIRST 10
#define X_SECOND 80
#define X_CENTER_DEVICE (DEVICE_WIDTH - WIDTH_REGULAR)/2
#define Y_FIRST 89
#define WIDTH_REGULAR 300
#define WIDTH_SMALL 60
#define WIDTH_LARGE 230
#define WIDTH_FULL 300
#define HEIGHT_REGULAR 35
#define MARGIN_REGULAR 60

@interface CBPickerView : UIPickerView {
    
}

@end

@implementation CBPickerView

- (instancetype)init {
    self = [super init];
    if (self) {
        
    }
    return self;
}

@end

# pragma mark -
# pragma mark Pickup Date

@interface PickupDatePickerViewController : UIViewController {
    UIDatePicker *datePicker;
    UILabel *dateInfoLabel;
    UIButton *confirmButton;
    UIButton *cancelButton;
    NSTimer *changeDateInfoLabelBgColorTimer;
    DTOManager *dtoManager;
    RLMRealm *realm;
    Order *currentOrder;
    NSString *pickupDateString;
}

@end

@implementation PickupDatePickerViewController

- (instancetype)init {
    self = [super init];
    if (self) {
        
    }
    return self;
}

- (void)viewDidLoad {
    realm = [RLMRealm defaultRealm];
    [self.navigationItem setTitle:@"수거일"];
    [self.view setBackgroundColor:[UIColor whiteColor]];
    
    dateInfoLabel = [[UILabel alloc] initWithFrame:CGRectMake(20, 84, 280, 120)];
    [dateInfoLabel setTextAlignment:NSTextAlignmentCenter];
    [dateInfoLabel setLineBreakMode:NSLineBreakByCharWrapping];
    [dateInfoLabel setText:@"현재 시간으로부터 1시간 후,\n30분 단위로 선택이 가능합니다.\n(최장 2주)"];
    [dateInfoLabel setTextColor:[UIColor grayColor]];
    [dateInfoLabel setNumberOfLines:0];
    [dateInfoLabel.layer setBorderColor:CleanBasketMint.CGColor];
    [dateInfoLabel.layer setBorderWidth:1.0f];
    [dateInfoLabel.layer setCornerRadius:15.0f];
    
    datePicker = [[UIDatePicker alloc] initWithFrame:CGRectMake(0, 200, DEVICE_WIDTH, 200)];
    [datePicker addTarget:self action:@selector(datePickerChanged) forControlEvents:UIControlEventValueChanged];
    
    confirmButton = [[UIButton alloc] initWithFrame:CGRectMake(60, 420, 200, 35)];
    [confirmButton setBackgroundColor:CleanBasketMint];
    [confirmButton.layer setCornerRadius:15.0f];
    [confirmButton setTitle:@"확인" forState:UIControlStateNormal];
    [confirmButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [confirmButton setTitleColor:[UIColor blackColor] forState:UIControlStateHighlighted];
    [confirmButton addTarget:self action:@selector(didTouchConfirmButton) forControlEvents: UIControlEventTouchUpInside];
    
    cancelButton = [[UIButton alloc] initWithFrame:CGRectMake(170, 430, 130, 30)];
    [cancelButton setBackgroundColor:CleanBasketRed];
    [cancelButton.layer setCornerRadius:15.0f];
    
    [self refreshMinMaxDate];
    [datePicker setMinuteInterval:30];
    [self datePickerChanged];
    
    [self.view addSubview:confirmButton];
    //[self.view addSubview:cancelButton];
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

#pragma mark -
#pragma mark Deliver Date

@interface DeliverDatePickerViewController : UIViewController {
    UIDatePicker *datePicker;
    UILabel *dateInfoLabel;
    NSTimer *changeDateInfoLabelBgColorTimer;
    DTOManager *dtoManager;
    RLMRealm *realm;
    Order *currentOrder;
    NSString *deliverDateString;
    UIButton *confirmButton;
}

@end

@implementation DeliverDatePickerViewController

- (instancetype)init {
    self = [super init];
    if (self) {
        
    }
    return self;
}

- (void)viewDidLoad {
    [self.view setBackgroundColor:[UIColor whiteColor]];
    [self.navigationItem setTitle:@"배달일"];
    realm = [RLMRealm defaultRealm];
    
    dateInfoLabel = [[UILabel alloc] initWithFrame:CGRectMake(20, 84, 280, 120)];
    [dateInfoLabel setTextAlignment:NSTextAlignmentCenter];
    [dateInfoLabel setLineBreakMode:NSLineBreakByCharWrapping];
    [dateInfoLabel setText:@"주문 시간으로부터 3일 후,\n30분 단위로 선택이 가능합니다."];
    [dateInfoLabel setTextColor:[UIColor grayColor]];
    [dateInfoLabel setNumberOfLines:0];
    [dateInfoLabel.layer setBorderColor:CleanBasketMint.CGColor];
    [dateInfoLabel.layer setBorderWidth:1.0f];
    
    datePicker = [[UIDatePicker alloc] initWithFrame:CGRectMake(0, 200, DEVICE_WIDTH, 200)];
    [datePicker addTarget:self action:@selector(datePickerChanged) forControlEvents:UIControlEventValueChanged];
    
    [self refreshMinMaxDate];
    [datePicker setMinuteInterval:30];
    
    confirmButton = [[UIButton alloc] initWithFrame:CGRectMake(60, 420, 200, 35)];
    [confirmButton setBackgroundColor:CleanBasketMint];
    [confirmButton.layer setCornerRadius:15.0f];
    [confirmButton setTitle:@"확인" forState:UIControlStateNormal];
    [confirmButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [confirmButton setTitleColor:[UIColor blackColor] forState:UIControlStateHighlighted];
    [confirmButton addTarget:self action:@selector(didTouchConfirmButton) forControlEvents: UIControlEventTouchUpInside];
    
    [self.view addSubview:dateInfoLabel];
    [self.view addSubview:datePicker];
    [self.view addSubview:confirmButton];
}

- (void) didTouchConfirmButton {
    if ([Order objectForPrimaryKey:[NSNumber numberWithInt:NEW_INDEX]])
    {
        NSLog(@"NEW ORDER HAVING NEW_INDEX FOUND!");
        [realm beginWriteTransaction];
        currentOrder = [Order objectForPrimaryKey:[NSNumber numberWithInt:NEW_INDEX]];
        [currentOrder setDropoff_date:deliverDateString];
        [realm commitWriteTransaction];
    }
    
    else
    {
        NSLog(@"ORDER DOESN'T EXISTS!");
        [realm beginWriteTransaction];
        currentOrder = [[Order alloc] init];
        [currentOrder setOid:NEW_INDEX];
        [currentOrder setDropoff_date:deliverDateString];
        [realm commitWriteTransaction];
    }
    
    [[NSNotificationCenter defaultCenter] postNotificationName:@"setDeliveryDate" object:nil];
    [self.navigationController popToRootViewControllerAnimated:YES];
}

- (void) refreshMinMaxDate {
    NSCalendar *calendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
    NSDate *currentDate = [NSDate date];
    NSDateComponents *currentDateComponents = [[NSCalendar currentCalendar] components:NSYearCalendarUnit|NSMonthCalendarUnit|NSDayCalendarUnit|NSHourCalendarUnit|NSMinuteCalendarUnit fromDate:[NSDate date]];
    
    NSDateComponents *comps = [[NSDateComponents alloc] init];
    [comps setDay:10];
    [comps setHour:24 - [currentDateComponents hour]];
    NSDate *maxDate = [calendar dateByAddingComponents:comps toDate:currentDate options:0];
    
    [comps setDay:3];
    [comps setHour:1];
    if ( [currentDateComponents minute] > 31 ) {
        [comps setMinute:60 - [currentDateComponents minute]];
    }
    //    NSLog(@"%@", comps);
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
            [datePickerComponents setMinute:0];
            [datePicker setDate:[[NSCalendar currentCalendar] dateFromComponents:datePickerComponents]];
        }
    }
    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:00"];
    
    deliverDateString = [dateFormatter stringFromDate:[datePicker date]];
    
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

#pragma mark -
#pragma mark OrderViewController

@interface OrderViewController () <UITabBarControllerDelegate, UITabBarDelegate, UIGestureRecognizerDelegate> {
    PickupDatePickerViewController *pickupDatePickerViewController;
    DeliverDatePickerViewController *deliverDatePickerViewController;
}

@end

@implementation OrderViewController

- (instancetype)init {
    self = [super init];
    if (self) {
        UIImage *tabBarImage = [UIImage imageNamed:@"ic_menu_order_02.png"];
        UIImage *selectedTabBarImage = [UIImage imageNamed:@"ic_menu_order_01.png"];
        self.tabBarItem = [self.tabBarItem initWithTitle:@"주문하기" image:tabBarImage selectedImage:selectedTabBarImage];
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(didReceiveNotification:)
                                                     name:nil
                                                   object:nil];
    }
    
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self.view setBackgroundColor:[UIColor whiteColor]];
    [self.navigationItem setTitle:@"주문하기"];
    
    AFManager = [AFHTTPRequestOperationManager manager];
    
    pickupDatePickerViewController = [[PickupDatePickerViewController alloc] init];
    deliverDatePickerViewController = [[DeliverDatePickerViewController alloc] init];
    
    CBLabel *pickupLabel = [[CBLabel alloc] init];
    [pickupLabel setTag:0];
    [pickupLabel setFrame:CGRectMake(X_FIRST, Y_FIRST + MARGIN_REGULAR * [pickupLabel tag], WIDTH_SMALL, HEIGHT_REGULAR)];
    [pickupLabel setText:@"수거일"];
    [pickupLabel setTextColor:[UIColor whiteColor]];
    [pickupLabel setBackgroundColor:CleanBasketMint];
    [pickupLabel setTextAlignment:NSTextAlignmentCenter];
    [pickupLabel setAdjustsFontSizeToFitWidth:YES];
    [pickupLabel.layer setCornerRadius:5.0f];
    [pickupLabel setClipsToBounds:YES];
    
    UITapGestureRecognizer *pickupTapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(pickupTap)];
    
    pickupDateLabel = [[CBLabel alloc] init];
    [pickupDateLabel setTag:0];
    [pickupDateLabel setFrame:CGRectMake(X_SECOND, Y_FIRST + MARGIN_REGULAR * [pickupDateLabel tag], WIDTH_LARGE, HEIGHT_REGULAR)];
    [pickupDateLabel setText:@"원하시는 날짜를 선택해주세요"];
    [pickupDateLabel addGestureRecognizer:pickupTapGesture];
    [pickupDateLabel setUserInteractionEnabled:YES];
    [pickupDateLabel setBackgroundColor:UltraLightGray];
    [pickupDateLabel.layer setCornerRadius:5.0f];
    [pickupDateLabel setClipsToBounds:YES];
    [pickupDateLabel setTextColor:[UIColor grayColor]];
    [pickupDateLabel setTextAlignment:NSTextAlignmentCenter];
    
    CBLabel *deliverLabel = [[CBLabel alloc] init];
    [deliverLabel setTag:1];
    [deliverLabel setFrame:CGRectMake(X_FIRST, Y_FIRST + MARGIN_REGULAR * [deliverLabel tag], WIDTH_SMALL, HEIGHT_REGULAR)];
    [deliverLabel setText:@"배달일"];
    [deliverLabel setTextColor:[UIColor whiteColor]];
    [deliverLabel setBackgroundColor:CleanBasketMint];
    [deliverLabel.layer setCornerRadius:5.0f];
    [deliverLabel setClipsToBounds:YES];
    [deliverLabel setTextAlignment:NSTextAlignmentCenter];
    [deliverLabel setAdjustsFontSizeToFitWidth:YES];
    
    UITapGestureRecognizer *deliverTapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(deliverTap)];
    deliverDateLabel = [[CBLabel alloc] init];
    [deliverDateLabel setTag:1];
    [deliverDateLabel setFrame:CGRectMake(X_SECOND, Y_FIRST + MARGIN_REGULAR * [deliverDateLabel tag], WIDTH_LARGE, HEIGHT_REGULAR)];
    [deliverDateLabel setText:@"원하시는 날짜를 선택해주세요"];
    [deliverDateLabel addGestureRecognizer:deliverTapGesture];
    [deliverDateLabel setUserInteractionEnabled:YES];
    [deliverDateLabel setBackgroundColor:UltraLightGray];
    [deliverDateLabel setClipsToBounds:YES];
    [deliverDateLabel.layer setCornerRadius:5.0f];
    [deliverDateLabel setTextColor:[UIColor grayColor]];
    [deliverDateLabel setTextAlignment:NSTextAlignmentCenter];
    
    CBLabel *addressLabel = [[CBLabel alloc] init];
    [addressLabel setTag:2];
    [addressLabel setFrame:CGRectMake(X_FIRST, Y_FIRST + MARGIN_REGULAR * [addressLabel tag], WIDTH_SMALL, HEIGHT_REGULAR)];
    [addressLabel setText:@"주소"];
    [addressLabel setTextColor:[UIColor whiteColor]];
    [addressLabel setBackgroundColor:CleanBasketMint];
    [addressLabel.layer setCornerRadius:5.0f];
    [addressLabel setClipsToBounds:YES];
    [addressLabel setTextAlignment:NSTextAlignmentCenter];
    
    UITapGestureRecognizer *addressTapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(addressLabelDidTap)];
    
    inputAddressLabel = [[CBLabel alloc] init];
    [inputAddressLabel setTag:2];
    [inputAddressLabel setFrame:CGRectMake(X_FIRST, Y_FIRST + MARGIN_REGULAR * [inputAddressLabel tag] + HEIGHT_REGULAR + 10, WIDTH_FULL, HEIGHT_REGULAR)];
    [inputAddressLabel setTextColor:[UIColor grayColor]];
    [inputAddressLabel setBackgroundColor:UltraLightGray];
    [inputAddressLabel setText:@"새로운 주소 입력하기"];
    [inputAddressLabel.layer setCornerRadius:5.0f];
    [inputAddressLabel setClipsToBounds:YES];
    [inputAddressLabel setAdjustsFontSizeToFitWidth:YES];
    [inputAddressLabel setTextAlignment:NSTextAlignmentCenter];
    [inputAddressLabel addGestureRecognizer:addressTapGesture];
    [inputAddressLabel setUserInteractionEnabled:YES];
    
    CBLabel *contactLabel = [[CBLabel alloc] init];
    [contactLabel setTag:4];
    [contactLabel setFrame:CGRectMake(X_FIRST, inputAddressLabel.frame.origin.y + MARGIN_REGULAR, WIDTH_SMALL, HEIGHT_REGULAR)];
    [contactLabel setTextColor:[UIColor whiteColor]];
    [contactLabel setText:@"연락처"];
    [contactLabel setBackgroundColor:CleanBasketMint];
    [contactLabel setClipsToBounds:YES];
    [contactLabel setAdjustsFontSizeToFitWidth:YES];
    [contactLabel.layer setCornerRadius:5.0f];
    
    contactTextField = [[UITextField alloc] init];
    [contactTextField setTag:7];
    [contactTextField setFrame:CGRectMake(X_SECOND, inputAddressLabel.frame.origin.y + MARGIN_REGULAR, WIDTH_LARGE, HEIGHT_REGULAR)];
    [contactTextField.layer setCornerRadius:5.0f];
    [contactTextField setBackgroundColor:UltraLightGray];
    [contactTextField setTextColor:[UIColor grayColor]];
    UIView *contactTextFieldPaddingView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 10, 20)];
    [contactTextField setLeftView:contactTextFieldPaddingView];
    [contactTextField setLeftViewMode:UITextFieldViewModeAlways];
    [contactTextField addTarget:self action:@selector(contactTextFieldEditingDidBegin) forControlEvents:UIControlEventEditingDidBegin];
    [contactTextField addTarget:self action:@selector(contactTextFieldEditingDidEnd) forControlEvents:UIControlEventEditingDidEnd];
    
    UIButton* orderButton = [[UIButton alloc] initWithFrame:CGRectMake((DEVICE_WIDTH - 160)/2, DEVICE_HEIGHT - 107, 160, HEIGHT_REGULAR)];
    [orderButton setTitle:@"품목선택하기" forState:UIControlStateNormal];
    [orderButton setTitleColor:[UIColor blackColor] forState:UIControlStateHighlighted];
    [orderButton.layer setCornerRadius:15.0f];
    [orderButton setBackgroundColor:CleanBasketMint];
    [orderButton addTarget:self action:@selector(orderButtonDidTouched) forControlEvents:UIControlEventTouchUpInside];
    
    NSArray *addressName = [NSArray arrayWithObjects:@"집", @"회사", @"1", @"2", @"3", nil];
    addressControl = [[UISegmentedControl alloc] initWithItems:addressName];
    [addressControl setFrame:CGRectMake(addressLabel.frame.origin.x + WIDTH_SMALL + 10, Y_FIRST + MARGIN_REGULAR * [addressLabel tag], WIDTH_LARGE, HEIGHT_REGULAR)];
    [addressControl setTintColor:CleanBasketMint];
    [addressControl setSelectedSegmentIndex:0];
    [addressControl addTarget:self action:@selector(userDidChangeAddress:) forControlEvents:UIControlEventValueChanged];
    
    UITapGestureRecognizer *scrollViewTapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(scrollViewDidTap)];
    
    scrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 0, DEVICE_WIDTH, DEVICE_HEIGHT)];
    [scrollView setContentSize:CGSizeMake(DEVICE_WIDTH, DEVICE_HEIGHT * 1.5)];
    [scrollView setScrollEnabled:NO];
    [scrollView addGestureRecognizer:scrollViewTapGesture];
    
    [self.view addSubview:scrollView];
    [scrollView addSubview:pickupLabel];
    [scrollView addSubview:pickupDateLabel];
    [scrollView addSubview:deliverLabel];
    [scrollView addSubview:deliverDateLabel];
    [scrollView addSubview:addressLabel];
    [scrollView addSubview:contactLabel];
    [scrollView addSubview:inputAddressLabel];
    [scrollView addSubview:contactTextField];
    [scrollView addSubview:orderButton];
    [scrollView addSubview:addressControl];
}

- (void) contactTextFieldEditingDidBegin {
    [scrollView scrollRectToVisible:CGRectMake(0, 180, DEVICE_WIDTH, DEVICE_HEIGHT) animated:YES];
}

- (void) contactTextFieldEditingDidEnd {
    [scrollView scrollRectToVisible:CGRectMake(0, 0, DEVICE_WIDTH, DEVICE_HEIGHT) animated:YES];
}

- (void) scrollViewDidTap {
    [self.view endEditing:YES];
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event{
    [self.view endEditing:YES];
    [super touchesBegan:touches withEvent:event];
}

-(void)viewWillAppear:(BOOL)animated {
    [inputAddressLabel setText:[currentAddress fullAddress]];
}

- (void) didReceiveNotification:(NSNotification*)noti {
    // 사용자가 로그인 후, 서버로부터 유저 정보를 받은 후 로컬 디비에 유저 정보 생성 시,
    if ([[noti name] isEqualToString:@"didCreateUser"]) {
        realm = [RLMRealm defaultRealm];
        
        User *currentUser = [User objectForPrimaryKey:[[noti userInfo] valueForKey:@"uid"]];
        
        RLMArray<Address> *address = [currentUser valueForKey:@"address"];
        [contactTextField setText:[currentUser valueForKey:@"phone"]];
        currentAddress = [address objectAtIndex:[addressControl selectedSegmentIndex]];
        [inputAddressLabel setText:[currentAddress fullAddress]];
        
        currentOrder = [[Order alloc] init];
        [currentOrder setOid:NEW_INDEX];
        [realm beginWriteTransaction];
        [realm addObject:currentOrder];
        [realm commitWriteTransaction];
    }
    
    // 사용자가 픽업 날짜를 선택하고 확인을 누른 경우, NEW_INDEX==9999의 Order 객체 이용
    if ([[noti name] isEqualToString:@"setPickupDate"]) {
        if ([Order objectForPrimaryKey:[NSNumber numberWithInt:NEW_INDEX]])
        {
            currentOrder = [Order objectForPrimaryKey:[NSNumber numberWithInt:NEW_INDEX]];
            [pickupDateLabel setText:[currentOrder pickup_date]];
        }
    }
    
    // 사용자가 배달 날짜를 선택하고 확인을 누른 경우, NEW_INDEX==9999의 Order 객체 이용
    if ([[noti name] isEqualToString:@"setDeliveryDate"]) {
        if ([Order objectForPrimaryKey:[NSNumber numberWithInt:NEW_INDEX]])
        {
            currentOrder = [Order objectForPrimaryKey:[NSNumber numberWithInt:NEW_INDEX]];
            [deliverDateLabel setText:[currentOrder dropoff_date]];
            NSLog(@"%@", currentOrder);
        }
    }
}

- (void) setInputAddressLabel {
    
}


- (void) userDidChangeAddress:(id)sender {
    UISegmentedControl *control = (UISegmentedControl*)sender;
    NSLog(@"%d", [control selectedSegmentIndex]);
    realm = [RLMRealm defaultRealm];
    dtoManager = [DTOManager defaultManager];
    NSLog(@"%d", [dtoManager currentUid]);
    
    User *currentUser = [User objectForPrimaryKey:[NSNumber numberWithInt:[dtoManager currentUid]]];
    RLMArray<Address> *address = [currentUser address];
    NSLog(@"%@", address);
    currentAddress = [address objectAtIndex:[control selectedSegmentIndex]];
    [inputAddressLabel setText:[currentAddress fullAddress]];
}

- (void) addressLabelDidTap {
    AddressInputViewController *addressInputViewController = [[AddressInputViewController alloc] init];
    [addressInputViewController setCurrentAddress:currentAddress];
    [addressInputViewController setUpdateAddress:YES];
    [self.navigationController pushViewController:addressInputViewController animated:YES];
}

- (void) pickupTap {
    [self.navigationController pushViewController:pickupDatePickerViewController animated:YES];
}

- (void) deliverTap {
    [self.navigationController pushViewController:deliverDatePickerViewController animated:YES];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (CGRect) makeRect: (UIView*)view {
    return CGRectMake(X_CENTER_DEVICE, Y_FIRST + MARGIN_REGULAR * [view tag], WIDTH_REGULAR, HEIGHT_REGULAR);
}

- (void) orderButtonDidTouched {
        if ([[pickupDateLabel text] isEqualToString:@"원하시는 날짜를 선택해주세요"] ||
            [[deliverDateLabel text] isEqualToString:@"원하시는 날짜를 선택해주세요"]) {
            [self showHudMessage:@"수거일 및 배달일을 설정해주세요."];
            return;
        }
    
        if ([[inputAddressLabel text] isEqualToString:@"주소가 없습니다"] ||
            [[inputAddressLabel text] isEqualToString:@"새로운 주소 입력하기"]) {
            [self showHudMessage:@"유효한 주소를 입력해주세요."];
            return;
        }
    
        if ([[contactTextField text] length] < 10) {
            [self showHudMessage:@"유효한 주소를 입력해주세요."];
            return;
        }
    
    if (currentOrder) {
        
        realm = [RLMRealm defaultRealm];
        [realm beginWriteTransaction];
        [currentOrder setPhone:[contactTextField text]];
        [currentOrder setAddress:[currentAddress address]];
        [currentOrder setAddr_number:[currentAddress addr_number]];
        [currentOrder setAddr_building:[currentAddress addr_building]];
        [currentOrder setAddr_remainder:[currentAddress addr_remainder]];
        [realm commitWriteTransaction];
    }
    else {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:nil
                                                            message:@"주문이 제대로 생성되지 않았습니다.\n다시 로그인해주세요."
                                                           delegate:self
                                                  cancelButtonTitle:@"닫기"
                                                  otherButtonTitles:nil, nil];
        [alertView show];
    }
    
    ChooseLaundryViewController *chooseLaundry = [[ChooseLaundryViewController alloc] init];
    [chooseLaundry setCurrentOrder:currentOrder];
    [chooseLaundry setCurrentAddress:currentAddress];
    UINavigationController *navController = [[UINavigationController alloc] initWithRootViewController:chooseLaundry];
    [self.navigationController presentViewController:navController animated:YES completion:^{
    }];
    
    NSLog(@"[CURRENT ORDER]\r%@", currentOrder);
}

- (void) showHudMessage:(NSString*)message {
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.navigationController.view animated:YES labelText:message    ];
    
    // Configure for text only and offset down
    hud.mode = MBProgressHUDModeText;
    [hud setLabelFont:[UIFont systemFontOfSize:14.0f]];
    hud.margin = 10.f;
    hud.yOffset = 150.f;
    hud.removeFromSuperViewOnHide = YES;
    
    [hud hide:YES afterDelay:2];
    return;
}

@end
