//
//  OrderStatusViewController.m
//  CleanBasket
//
//  Created by Wonhyo Yi on 2014. 10. 3..
//  Copyright (c) 2014년 WashAppKorea. All rights reserved.
//

#import "OrderStatusViewController.h"
#import <Realm/Realm.h>
#import "AFNetworking.h"
#import "CBConstants.h"
#import "Order.h"
#import "MBProgressHUD.h"
#import "NSString+CBString.h"

@interface OrderStatusViewController (){
    int processIndex;
    UIImageView *processImageView;
    NSArray *processImages;
    UIButton *orderListButton;
    RLMRealm *realm;
    AFHTTPRequestOperationManager *afManager;
    UIImageView *profileView;
    
    UILabel *managerNameLabel;
    UILabel *visitDateLabel;
    UILabel *visitTimeLabel;
    Order *firstOrder;
}
@end

@implementation OrderStatusViewController
@synthesize dataArray = dataArray;

- (instancetype)init {
    self = [super init];
    if (self) {
        UIImage *tabBarImage = [UIImage imageNamed:@"ic_menu_progress_01.png"];
        UIImage *selectedTabBarImage = [UIImage imageNamed:@"ic_menu_progress_02.png"];
        self.tabBarItem = [self.tabBarItem initWithTitle:@"진행상태" image:tabBarImage selectedImage:selectedTabBarImage];
        processIndex = 0;
    }
    
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self.view setBackgroundColor:[UIColor whiteColor]];
    
    UIImage *managerPhotoImage = [UIImage imageNamed:@"process_profile.png"];
    profileView = [[UIImageView alloc] initWithImage:managerPhotoImage];
    [profileView setFrame:CGRectMake(DEVICE_WIDTH - 80, (DEVICE_HEIGHT - 80)/2, 80, 80)];
    [profileView setContentMode:UIViewContentModeScaleToFill];
    [profileView.layer setMasksToBounds:YES];
    
    managerNameLabel = [[UILabel alloc] initWithFrame:CGRectMake(DEVICE_WIDTH - 80, (DEVICE_HEIGHT-80)/2 + 80, 80, 30)];
    [managerNameLabel setText:@"배달자"];
    [managerNameLabel setTextColor:[UIColor grayColor]];
    [managerNameLabel setTextAlignment:NSTextAlignmentCenter];
    [managerNameLabel setAdjustsFontSizeToFitWidth:YES];
    [managerNameLabel setFont:[UIFont systemFontOfSize:14.0f]];
    
    visitDateLabel = [[UILabel alloc] initWithFrame:CGRectMake(DEVICE_WIDTH - 130, (DEVICE_HEIGHT-80)/2 + 97, 120, 30)];
    [visitDateLabel setTextColor:[UIColor grayColor]];
    [visitDateLabel setTextAlignment:NSTextAlignmentRight];
    [visitDateLabel setAdjustsFontSizeToFitWidth:YES];
    [visitDateLabel setFont:[UIFont systemFontOfSize:14.0]];
    
    visitTimeLabel = [[UILabel alloc] initWithFrame:CGRectMake(DEVICE_WIDTH - 130, (DEVICE_HEIGHT-80)/2 + 112, 120, 30)];
    [visitTimeLabel setTextColor:[UIColor grayColor]];
    [visitTimeLabel setTextAlignment:NSTextAlignmentRight];
    [visitTimeLabel setAdjustsFontSizeToFitWidth:YES];
    [visitTimeLabel setFont:[UIFont systemFontOfSize:14.0]];
    
    UIImage *process0 = [UIImage imageNamed:@"process_0.png"];
    UIImage *process1 = [UIImage imageNamed:@"process_1.png"];
    UIImage *process2 = [UIImage imageNamed:@"process_2.png"];
    UIImage *process3 = [UIImage imageNamed:@"process_3.png"];
    UIImage *process4 = [UIImage imageNamed:@"process_4.png"];
    UIImage *process5 = [UIImage imageNamed:@"process_5.png"];
    UIImage *process6 = [UIImage imageNamed:@"process_6.png"];
    
    processImages = [NSArray arrayWithObjects:process0, process1, process2, process3, process4, process5, process6, nil];
    
    processImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"process_empty.png"]];
    [processImageView setUserInteractionEnabled:YES];
    
    if (isiPhone5) {
        [processImageView setFrame:CGRectMake(0, 64, DEVICE_WIDTH, DEVICE_HEIGHT - NAV_STATUS_HEIGHT - TAPBAR_HEIGHT)];
    } else {
        [processImageView setFrame:CGRectMake(60, 64, 260, DEVICE_HEIGHT - NAV_STATUS_HEIGHT - TAPBAR_HEIGHT)];
    }
    [processImageView setContentMode:UIViewContentModeScaleAspectFill];
    
    [self.view addSubview:processImageView];
    [self.view addSubview:profileView];
    [self.view addSubview:managerNameLabel];
    [self.view addSubview:visitDateLabel];
    [self.view addSubview:visitTimeLabel];
    
}

- (void) viewWillAppear:(BOOL)animated {
    [MBProgressHUD showHUDAddedTo:self.view animated:YES labelText:@"주문을 불러오는 중:)"];
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_LOW, 0), ^{
        afManager = [AFHTTPRequestOperationManager manager];
        [afManager setRequestSerializer:[AFHTTPRequestSerializer new]];
        // 세션 기반으로 회원의 주문 목록을 받아온다.
        [afManager POST:@"https://www.cleanbasket.co.kr/member/order" parameters:@{} success:^(AFHTTPRequestOperation *operation, id responseObject) {
            dataArray =  [NSJSONSerialization JSONObjectWithData: [responseObject[@"data"] dataUsingEncoding:NSUTF8StringEncoding]
                                                         options: NSJSONReadingMutableContainers
                                                           error: nil];
            realm = [RLMRealm defaultRealm];
            
            // 로컬에 주문 존재 시, 업데이트를 위해 제거
            if ([dataArray count] > 0 && [Order objectForPrimaryKey:[NSNumber numberWithInt:[[[dataArray objectAtIndex:0] valueForKey:@"oid"] intValue]]]) {
                [realm beginWriteTransaction];
                [realm deleteObject:[Order objectForPrimaryKey:[NSNumber numberWithInt:[[[dataArray objectAtIndex:0] valueForKey:@"oid"] intValue]]]];
                [realm commitWriteTransaction];
            }
            
            // 주문이 없을 경우 팝업 메세지 후 리턴
            else if ([dataArray count] == 0) {
                [MBProgressHUD hideHUDForView:self.view animated:YES];
                [processImageView setImage:[UIImage imageNamed:@"process_empty.png"]];
                [profileView setImage:[UIImage imageNamed:@"process_profile.png"]];
                [profileView.layer setCornerRadius:0];
                [managerNameLabel setText:@"배달자"];
                [visitDateLabel setText:@""];
                [visitTimeLabel setText:@""];
                [self showHudMessage:@"주문이 없습니다!"];
                return;
            }
            
            // 주문들이 있을 경우, 로컬에 삽입 후 첫번째 주문 정보를 뷰에 업데이트한다.
            [realm beginWriteTransaction];
            firstOrder = [Order createInDefaultRealmWithObject:[dataArray objectAtIndex:0]];
            Coupon *firstCoupon;
            // 주문에 존재하는 쿠폰은 이미 사용한 것이므로, 로컬에서 제거
            if ([[firstOrder coupon] count] > 0) {
                firstCoupon = [[firstOrder coupon] objectAtIndex:0];
                [realm deleteObject:[Coupon objectForPrimaryKey:[NSNumber numberWithInt:[firstCoupon cpid]]]];
                NSLog(@"Deleting used coupon");
            }
            [realm commitWriteTransaction];
            
            if ([[firstOrder pickupInfo] img]) {
                NSString *filePath = [NSString stringWithFormat:@"https://www.cleanbasket.co.kr/%@", [[firstOrder pickupInfo] img]];
                UIImage *managerPhotoImage = [UIImage imageWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:filePath]]];
                [profileView setImage:managerPhotoImage];
                [profileView.layer setCornerRadius:40.0f];
            }
            
            [managerNameLabel setText:([[firstOrder pickupInfo] name]?[[firstOrder pickupInfo] name]:@"미지정")];
            [visitDateLabel setText:@""];
            [visitTimeLabel setText:@""];
            
            // 수거해야 할 주문인 경우
            if ([firstOrder pickup_date] && [firstOrder state] < 2) {
                NSString *trimmedString = [NSString trimDateString:[firstOrder pickup_date]];
                NSString *dateString = [trimmedString substringToIndex:10];
                NSString *timeString = [trimmedString substringWithRange:NSMakeRange(11, 13)];
                [visitDateLabel setText:dateString];
                [visitTimeLabel setText:timeString];
            }
            
            // 배달해야 할 주문인 경우
            if ([firstOrder dropoff_date] && [firstOrder state] > 1) {
                NSString *trimmedString = [NSString trimDateString:[firstOrder dropoff_date]];
                NSString *dateString = [trimmedString substringToIndex:10];
                NSString *timeString = [trimmedString substringWithRange:NSMakeRange(11, 13)];
                [visitDateLabel setText:dateString];
                [visitTimeLabel setText:timeString];
            }
            
            // 현재 주문 상태에 알맞은 그림 선택
            [processImageView setImage:[processImages objectAtIndex:[firstOrder state]]];
            
            dispatch_async(dispatch_get_main_queue(), ^{
                [MBProgressHUD hideHUDForView:self.view animated:YES];
            });
        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
            dispatch_async(dispatch_get_main_queue(), ^{
                [MBProgressHUD hideHUDForView:self.view animated:YES];
            });
            [self showHudMessage:@"네트워크 상태를 확인해주세요."];
        }];
    });
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void) showHudMessage:(NSString*)message {
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.navigationController.view animated:YES labelText:message    ];
    
    // Configure for text only and offset down
    hud.mode = MBProgressHUDModeText;
    [hud setLabelFont:[UIFont systemFontOfSize:14.0f]];
    hud.margin = 10.f;
    hud.removeFromSuperViewOnHide = YES;
    
    [hud hide:YES afterDelay:1];
    return;
}

@end
