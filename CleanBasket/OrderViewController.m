//
//  OrderViewController.m
//  CleanBasket
//
//  Created by Wonhyo Yi on 2014. 10. 3..
//  Copyright (c) 2014년 WashAppKorea. All rights reserved.
//

#import "OrderViewController.h"
#define FieldHeight 35
#define FieldWidth 300
#define CenterX (DEVICE_WIDTH - FieldWidth)/2
#define FirstElementY 70
#define Interval 38

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
    [self.navigationItem setTitle:@"수거일"];
    [self.view setBackgroundColor:[UIColor whiteColor]];
    
    dateInfoLabel = [[UILabel alloc] initWithFrame:CGRectMake(20, 84, 280, 120)];
    [dateInfoLabel setTextAlignment:NSTextAlignmentCenter];
    [dateInfoLabel setLineBreakMode:NSLineBreakByCharWrapping];
    [dateInfoLabel setText:@"현재 시간으로부터 1시간 후,\n30분 단위로 선택이 가능합니다.\n(최대 2주일)"];
    [dateInfoLabel setTextColor:[UIColor grayColor]];
    [dateInfoLabel setNumberOfLines:0];
    [dateInfoLabel.layer setBorderColor:CleanBasketMint.CGColor];
    [dateInfoLabel.layer setBorderWidth:1.0f];
    [dateInfoLabel.layer setCornerRadius:15.0f];
    
    datePicker = [[UIDatePicker alloc] initWithFrame:CGRectMake(0, 200, DEVICE_WIDTH, 200)];
    [datePicker addTarget:self action:@selector(datePickerChanged) forControlEvents:UIControlEventValueChanged];
    
    confirmButton = [[UIButton alloc] initWithFrame:CGRectMake(60, 420, 200, 30)];
    [confirmButton setBackgroundColor:CleanBasketMint];
    [confirmButton.layer setCornerRadius:15.0f];
    [confirmButton setTitle:@"확인" forState:UIControlStateNormal];
    [confirmButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [confirmButton setTitleColor:[UIColor yellowColor] forState:UIControlStateHighlighted];
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
    
    NSString *formattedDateString = [dateFormatter stringFromDate:[datePicker date]];
    //    NSLog(@"formattedDateString: %@", formattedDateString);
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
    
    dateInfoLabel = [[UILabel alloc] initWithFrame:CGRectMake(20, 84, 280, 120)];
    [dateInfoLabel setTextAlignment:NSTextAlignmentCenter];
    [dateInfoLabel setLineBreakMode:NSLineBreakByCharWrapping];
    [dateInfoLabel setText:@"현재 시간으로부터 2일 후,\n30분 단위로 선택이 가능합니다."];
    [dateInfoLabel setTextColor:[UIColor grayColor]];
    [dateInfoLabel setNumberOfLines:0];
    [dateInfoLabel.layer setBorderColor:CleanBasketMint.CGColor];
    [dateInfoLabel.layer setBorderWidth:1.0f];
    
    datePicker = [[UIDatePicker alloc] initWithFrame:CGRectMake(0, 220, DEVICE_WIDTH, 200)];
    [datePicker addTarget:self action:@selector(datePickerChanged) forControlEvents:UIControlEventValueChanged];
    
    [self refreshMinMaxDate];
    [datePicker setMinuteInterval:30];
    
    [self.view addSubview:dateInfoLabel];
    [self.view addSubview:datePicker];
}

- (void) refreshMinMaxDate {
    NSCalendar *calendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
    NSDate *currentDate = [NSDate date];
    NSDateComponents *currentDateComponents = [[NSCalendar currentCalendar] components:NSYearCalendarUnit|NSMonthCalendarUnit|NSDayCalendarUnit|NSHourCalendarUnit|NSMinuteCalendarUnit fromDate:[NSDate date]];
    
    NSDateComponents *comps = [[NSDateComponents alloc] init];
    [comps setDay:9];
    [comps setHour:24 - [currentDateComponents hour]];
    NSDate *maxDate = [calendar dateByAddingComponents:comps toDate:currentDate options:0];
    
    [comps setDay:2];
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
    
    NSString *formattedDateString = [dateFormatter stringFromDate:[datePicker date]];
    //    NSLog(@"formattedDateString: %@", formattedDateString);
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
        UIImage *tabBarImage = [UIImage imageNamed:@"tab_order.png"];
        self.tabBarItem = [self.tabBarItem initWithTitle:@"주문하기" image:tabBarImage selectedImage:tabBarImage];
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(didReceiveNotification:)
                                                     name:@"didCreateUser"
                                                   object:nil];
    }
    
    return self;
}

- (void) didReceiveNotification:(NSNotification*)noti {
    if ([[noti name] isEqualToString:@"didCreateUser"]) {
        realm = [RLMRealm defaultRealm];
        User *currentUser = [User objectForPrimaryKey:[[noti userInfo] valueForKey:@"uid"]];
        NSLog(@"CurrentUser@OrderViewController: %@", currentUser);
        RLMArray<Address> *address = [currentUser valueForKey:@"address"];
        [contactTextField setText:[currentUser valueForKey:@"phone"]];
        [inputAddressLabel setText:[[address objectAtIndex:0] fullAddress]];
    }
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
    [pickupLabel setFrame:[self makeRect:pickupLabel]];
    [pickupLabel setText:@"수거일"];
    [pickupLabel setTextColor:CleanBasketMint];
    
    UITapGestureRecognizer *pickupTapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(pickupTap)];
    CBLabel *pickupDateLabel = [[CBLabel alloc] init];
    [pickupDateLabel setTag:1];
    [pickupDateLabel setFrame:[self makeRect:pickupDateLabel]];
    [pickupDateLabel setText:@"원하는 날짜를 선택해주세요"];
    [pickupDateLabel addGestureRecognizer:pickupTapGesture];
    [pickupDateLabel setUserInteractionEnabled:YES];
    [pickupDateLabel setBackgroundColor:UltraLightGray];
    [pickupDateLabel.layer setCornerRadius:15.0f];
    [pickupDateLabel setTextColor:[UIColor grayColor]];
    
    CBLabel *deliverLabel = [[CBLabel alloc] init];
    [deliverLabel setTag:2];
    [deliverLabel setFrame:[self makeRect:deliverLabel]];
    [deliverLabel setText:@"배달일"];
    [deliverLabel setTextColor:CleanBasketMint];
    
    UITapGestureRecognizer *deliverTapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(deliverTap)];
    CBLabel *deliverDateLabel = [[CBLabel alloc] init];
    [deliverDateLabel setTag:3];
    [deliverDateLabel setFrame:[self makeRect:deliverDateLabel]];
    [deliverDateLabel setText:@"원하는 날짜를 선택해주세요"];
    [deliverDateLabel addGestureRecognizer:deliverTapGesture];
    [deliverDateLabel setUserInteractionEnabled:YES];
    [deliverDateLabel setBackgroundColor:UltraLightGray];
    [deliverDateLabel.layer setCornerRadius:15.0f];
    [deliverDateLabel setTextColor:[UIColor grayColor]];
    
    CBLabel *addressLabel = [[CBLabel alloc] init];
    [addressLabel setTag:4];
    [addressLabel setFrame:[self makeRect:addressLabel]];
    [addressLabel setText:@"주소"];
    [addressLabel setTextColor:CleanBasketMint];
    CGRect addressLabelFrame = CGRectMake(addressLabel.frame.origin.x, addressLabel.frame.origin.y, addressLabel.frame.size.width, addressLabel.frame.size.height);
    UIButton *firstAddrButton = [[UIButton alloc] initWithFrame:addressLabelFrame];
    [firstAddrButton setTag:0];
    
    inputAddressLabel = [[CBLabel alloc] init];
    [inputAddressLabel setTag:5];
    [inputAddressLabel setFrame:[self makeRect:inputAddressLabel]];
    [inputAddressLabel setTextColor:[UIColor grayColor]];
    [inputAddressLabel setBackgroundColor:UltraLightGray];
    [inputAddressLabel setText:@"새로운 주소 입력하기"];
    [inputAddressLabel.layer setCornerRadius:15.0f];
    [inputAddressLabel setAdjustsFontSizeToFitWidth:YES];
    
    CBLabel *contactLabel = [[CBLabel alloc] init];
    [contactLabel setTag:6];
    [contactLabel setFrame:[self makeRect:contactLabel]];
    [contactLabel setTextColor:CleanBasketMint];
    [contactLabel setText:@"연락처"];
    
    contactTextField = [[UITextField alloc] init];
    [contactTextField setTag:7];
    [contactTextField setFrame:[self makeRect:contactTextField]];
    [contactTextField.layer setCornerRadius:15.0f];
    [contactTextField setBackgroundColor:UltraLightGray];
    [contactTextField setTextColor:[UIColor grayColor]];
    UIView *contactTextFieldPaddingView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 10, 20)];
    [contactTextField setLeftView:contactTextFieldPaddingView];
    [contactTextField setLeftViewMode:UITextFieldViewModeAlways];
    
    UIButton* orderButton = [[UIButton alloc] initWithFrame:CGRectMake((DEVICE_WIDTH - 160)/2, DEVICE_HEIGHT - 97, 160, FieldHeight)];
    [orderButton setTitle:@"주문하기!" forState:UIControlStateNormal];
    [orderButton setTitleColor:CleanBasketRed forState:UIControlStateHighlighted];
    [orderButton.layer setCornerRadius:15.0f];
    [orderButton setBackgroundColor:CleanBasketMint];
    [orderButton addTarget:self action:@selector(orderButtonDidTouched) forControlEvents:UIControlEventTouchUpInside];
    
    [self.view addSubview:pickupLabel];
    [self.view addSubview:pickupDateLabel];
    [self.view addSubview:deliverLabel];
    [self.view addSubview:deliverDateLabel];
    [self.view addSubview:addressLabel];
    [self.view addSubview:contactLabel];
    [self.view addSubview:inputAddressLabel];
    [self.view addSubview:contactTextField];
    [self.view addSubview:orderButton];
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event{
    [self.view endEditing:YES];
    [super touchesBegan:touches withEvent:event];
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
    return CGRectMake(CenterX, FirstElementY + Interval * [view tag], FieldWidth, FieldHeight);
}

- (void) orderButtonDidTouched {
    ChooseLaundryViewController *chooseLaundry = [[ChooseLaundryViewController alloc] init];
    UINavigationController *navController = [[UINavigationController alloc] initWithRootViewController:chooseLaundry];
    [self.navigationController presentViewController:navController animated:YES completion:^{
        
    }];
}

@end
