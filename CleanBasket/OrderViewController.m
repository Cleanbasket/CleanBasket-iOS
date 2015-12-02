//
//  OrderViewController.m
//  CleanBasket
//
//  Created by Wonhyo Yi on 2014. 10. 3..
//  Copyright (c) 2014년 WashAppKorea. All rights reserved.
//

#import "OrderViewController.h"
#import <Realm/Realm.h>
#import "PickupDatePickerViewController.h"
#import "DeliverDatePickerViewController.h"
#import "CBConstants.h"
#import "CBLabel.h"
#import "AFNetworking.h"
#import "DTOManager.h"
#import "User.h"
#import "Address.h"
#import "Order.h"
#import "ChooseLaundryViewController.h"
#import "AddressInputViewController.h"
#import "MBProgressHUD.h"
#import "NSString+CBString.h"

#define X_FIRST 10
#define X_SECOND 80
#define X_CENTER_DEVICE (DEVICE_WIDTH - WIDTH_REGULAR)/2
#define Y_FIRST 89
#define WIDTH_REGULAR 300
#define WIDTH_SMALL 60
#define WIDTH_LARGE 230
#define WIDTH_FULL 300
#define HEIGHT_REGULAR 38
#define MARGIN_REGULAR ((isiPhone5) ? 75 : 60)

@interface OrderViewController () <UITabBarControllerDelegate, UITabBarDelegate, UIGestureRecognizerDelegate> {
    AFHTTPRequestOperationManager *AFManager;
    RLMRealm *realm;
    UITextField *contactTextField;
    CBLabel *inputAddressLabel;
    DTOManager *dtoManager;
    Order *currentOrder;
    CBLabel *pickupDateLabel;
    CBLabel *deliverDateLabel;
    UIScrollView *scrollView;
    UISegmentedControl *addressControl;
    Address *currentAddress;
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
    
    dtoManager = [DTOManager defaultManager];
    AFManager = [AFHTTPRequestOperationManager manager];
    
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
    [contactTextField setKeyboardType:UIKeyboardTypePhonePad];
    UIView *contactTextFieldPaddingView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 10, 20)];
    [contactTextField setLeftView:contactTextFieldPaddingView];
    [contactTextField setLeftViewMode:UITextFieldViewModeAlways];
    [contactTextField setReturnKeyType:UIReturnKeyDone];
    [contactTextField addTarget:self action:@selector(contactTextFieldEditingDidBegin) forControlEvents:UIControlEventEditingDidBegin];
    [contactTextField addTarget:self action:@selector(contactTextFieldEditingDidEnd) forControlEvents:UIControlEventEditingDidEnd];
    
    UIButton* orderButton = [[UIButton alloc] initWithFrame:CGRectMake((DEVICE_WIDTH - 160)/2, DEVICE_HEIGHT - 107, 160, HEIGHT_REGULAR)];
    [orderButton setTitle:@"품목선택" forState:UIControlStateNormal];
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

- (void) sayHelloToUser {
    NSString *accountString = @"안녕하세요, ";
    accountString = [accountString stringByAppendingString:[dtoManager.currentUser email]];
    accountString = [accountString stringByAppendingString:@" 님:)"];
    [self showHudMessage:accountString delay:2];
}

- (void) contactTextFieldEditingDidBegin {
    [scrollView scrollRectToVisible:CGRectMake(0, 180, DEVICE_WIDTH, DEVICE_HEIGHT) animated:YES];
}

- (void) contactTextFieldEditingDidEnd {
    [scrollView scrollRectToVisible:CGRectMake(0, 0, DEVICE_WIDTH, DEVICE_HEIGHT) animated:YES];
    NSLog(@"%@", [contactTextField text]);
    
    if([[contactTextField text] length] > 15) {
        [self showHudMessage:@"올바르지 않은 연락처입니다." delay:1];
        [contactTextField setText:@""];
        return;
    }
    
    NSDictionary *parameter = @{@"phone":[contactTextField text]};
    
    [MBProgressHUD showHUDAddedTo:self.view animated:YES labelText:@"연락처 업데이트 중"];
    AFHTTPRequestOperationManager *afManager = [AFHTTPRequestOperationManager manager];
    afManager.requestSerializer = [AFJSONRequestSerializer serializer];
    afManager.responseSerializer = [AFJSONResponseSerializer serializer];
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_LOW, 0), ^{
        [afManager POST:@"https://www.cleanbasket.co.kr/member/phone/update"  parameters:parameter success:^(AFHTTPRequestOperation *operation, id responseObject) {
            NSNumber *constant = [responseObject valueForKey:@"constant"];
            dispatch_async(dispatch_get_main_queue(), ^{
                [MBProgressHUD hideHUDForView:self.view animated:YES];
                switch ([constant intValue]) {
                    case CBServerConstantSuccess: {
                        [self showHudMessage:@"연락처를 업데이트했습니다." delay:1];
                    }
                        break;
                    case CBServerConstantError: {
                        [self showHudMessage:@"서버 오류가 발생했습니다. 나중에 시도해주세요." delay:1];
                    }
                        break;
                    case CBServerConstantSessionExpired: {
                        [self showHudMessage:@"세션이 만료되었습니다. 다시 로그인해주세요." delay:2];
                        //AppDelegate에 세션이 만료됨을 알림
                        [[NSNotificationCenter defaultCenter] postNotificationName:@"sessionExpired" object:self];
                    }
                        break;
                }
            });
            
        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
            dispatch_async(dispatch_get_main_queue(), ^{
                [MBProgressHUD hideHUDForView:self.view animated:YES];
                [self showHudMessage:@"네트워크 상태를 확인해주세요" delay:2];
            });
            NSLog(@"%@", error);
        }];
    });
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
        
        [realm beginWriteTransaction];
        if ([Order objectForPrimaryKey:[NSNumber numberWithInt:NEW_INDEX]]) {
            [realm deleteObject:[Order objectForPrimaryKey:[NSNumber numberWithInt:NEW_INDEX]]];
        }
        currentOrder = [[Order alloc] init];
        [currentOrder setOid:NEW_INDEX];
        [realm addObject:currentOrder];
        [realm commitWriteTransaction];
        NSLog(@"NEW ORDER HAVING PRIMARY KEY 9999 CREATED");
        [self sayHelloToUser];
    }
    
    // 사용자가 픽업 날짜를 선택하고 확인을 누른 경우, NEW_INDEX==9999의 Order 객체 이용
    if ([[noti name] isEqualToString:@"setPickupDate"]) {
        if ([Order objectForPrimaryKey:[NSNumber numberWithInt:NEW_INDEX]])
        {
            currentOrder = [Order objectForPrimaryKey:[NSNumber numberWithInt:NEW_INDEX]];
            [pickupDateLabel setText:[NSString trimDateString:[currentOrder pickup_date]]];
        }
    }
    
    // 사용자가 배달 날짜를 선택하고 확인을 누른 경우, NEW_INDEX==9999의 Order 객체 이용
    if ([[noti name] isEqualToString:@"setDeliveryDate"]) {
        if ([Order objectForPrimaryKey:[NSNumber numberWithInt:NEW_INDEX]])
        {
            currentOrder = [Order objectForPrimaryKey:[NSNumber numberWithInt:NEW_INDEX]];
            [deliverDateLabel setText:[NSString trimDateString:[currentOrder dropoff_date]]];
        }
    }
    // 주문이 완료된 경우, 수거일과 배달일 초기화
    if ([[noti name] isEqualToString:@"checkCompletedOrder"] || [[noti name] isEqualToString:@"userDidLogout"]) {
        [pickupDateLabel setText:@"원하시는 날짜를 선택해주세요"];
        [deliverDateLabel setText:@"원하시는 날짜를 선택해주세요"];
        return;
    }
}

- (void) setInputAddressLabel {
    
}


- (void) userDidChangeAddress:(id)sender {
    UISegmentedControl *control = (UISegmentedControl*)sender;
    NSLog(@"%d", (int)[control selectedSegmentIndex]);
    realm = [RLMRealm defaultRealm];
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
    PickupDatePickerViewController *pickupDatePickerViewController = [[PickupDatePickerViewController alloc] init];
    [pickupDatePickerViewController setCurrentOrder:currentOrder];
    [realm beginWriteTransaction];
    [currentOrder setDropoff_date:nil];
    [realm commitWriteTransaction];
    [deliverDateLabel setText:@"원하시는 날짜를 선택해주세요"];
    [self.navigationController pushViewController:pickupDatePickerViewController animated:YES];
}

- (void) deliverTap {
    if ([currentOrder.pickup_date length] < 5) {
        [self showHudMessage:@"수거일을 먼저 설정해주세요:)" delay:1];
        return;
    }
    DeliverDatePickerViewController *deliverDatePickerViewController = [[DeliverDatePickerViewController alloc] init];
    [deliverDatePickerViewController setCurrentOrder:currentOrder];
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
    if (currentOrder) {
        realm = [RLMRealm defaultRealm];
        [realm beginWriteTransaction];
        [currentOrder setPhone:[contactTextField text]];
        [currentOrder setAddress:[currentAddress address]];
        [currentOrder setAddr_number:[currentAddress addr_number]];
        [currentOrder setAddr_building:[currentAddress addr_building]];
        [currentOrder setAddr_remainder:[currentAddress addr_remainder]];
        [realm commitWriteTransaction];
        
        if ([[pickupDateLabel text] isEqualToString:@"원하시는 날짜를 선택해주세요"] ||
            [[deliverDateLabel text] isEqualToString:@"원하시는 날짜를 선택해주세요"]) {
            [self showHudMessage:@"수거일 및 배달일을 설정해주세요." delay:1];
            return;
        }
        
        if ([[inputAddressLabel text] isEqualToString:@"주소가 없습니다"] ||
            [[inputAddressLabel text] isEqualToString:@"새로운 주소 입력하기"]) {
            [self showHudMessage:@"유효한 주소를 입력해주세요." delay:1];
            return;
        }
        
        if ([[contactTextField text] length] < 10) {
            [self showHudMessage:@"유효한 주소를 입력해주세요." delay:1];
            return;
        }
        
        ChooseLaundryViewController *chooseLaundry = [[ChooseLaundryViewController alloc] init];
        [chooseLaundry setCurrentOrder:currentOrder];
        [chooseLaundry setCurrentAddress:currentAddress];
        UINavigationController *navController = [[UINavigationController alloc] initWithRootViewController:chooseLaundry];
        [self.navigationController presentViewController:navController animated:YES completion:^{
        }];
    }
    
    else {
        [self showHudMessage:@"주문 정보 생성에 실패했습니다. 다시 로그인해주세요." delay:2];
    }
}

- (void) showHudMessage:(NSString*)message delay:(int)delay_{
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.navigationController.view animated:YES labelText:message    ];
    
    // Configure for text only and offset down
    hud.mode = MBProgressHUDModeText;
    [hud setLabelFont:[UIFont systemFontOfSize:14.0f]];
    hud.margin = 10.f;
    hud.removeFromSuperViewOnHide = YES;
    
    [hud hide:YES afterDelay:delay_];
    return;
}

@end