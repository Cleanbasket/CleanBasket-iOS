//
//  OrderStatusViewController.m
//  CleanBasket
//
//  Created by Wonhyo Yi on 2014. 10. 3..
//  Copyright (c) 2014년 WashAppKorea. All rights reserved.
//

#import "OrderStatusViewController.h"

@interface OrderStatusViewController ()
@end

@implementation OrderStatusViewController

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
    
    managerPhotoImage = [UIImage imageNamed:@"process_profile.png"];
    profileView = [[UIImageView alloc] initWithImage:managerPhotoImage];
    [profileView setFrame:CGRectMake(DEVICE_WIDTH - 80, (DEVICE_HEIGHT - 80)/2, 80, 80)];
    [profileView setContentMode:UIViewContentModeScaleToFill];
    [profileView.layer setCornerRadius:40];
    [profileView.layer setMasksToBounds:YES];
    
    managerNameLabel = [[UILabel alloc] initWithFrame:CGRectMake(DEVICE_WIDTH - 80, (DEVICE_HEIGHT-80)/2 + 80, 80, 30)];
    [managerNameLabel setText:([[firstOrder pickupInfo] name]?[[firstOrder pickupInfo] name]:@"미지정")];
    [managerNameLabel setTextColor:[UIColor grayColor]];
    [managerNameLabel setTextAlignment:NSTextAlignmentCenter];
    [managerNameLabel setAdjustsFontSizeToFitWidth:YES];
    [managerNameLabel setFont:[UIFont systemFontOfSize:14.0f]];
    
    visitDateLabel = [[UILabel alloc] initWithFrame:CGRectMake(DEVICE_WIDTH - 120, (DEVICE_HEIGHT-80)/2 + 97, 120, 30)];
    [visitDateLabel setTextColor:[UIColor grayColor]];
    [visitDateLabel setTextAlignment:NSTextAlignmentCenter];
    [visitDateLabel setText:([firstOrder pickup_date]?[firstOrder pickup_date]:@"")];
    [visitDateLabel setAdjustsFontSizeToFitWidth:YES];
    
    UIImage *processEmpty = [UIImage imageNamed:@"process_empty.png"];
    UIImage *process0 = [UIImage imageNamed:@"process_0.png"];
    UIImage *process1 = [UIImage imageNamed:@"process_1.png"];
    UIImage *process2 = [UIImage imageNamed:@"process_2.png"];
    UIImage *process3 = [UIImage imageNamed:@"process_3.png"];
    UIImage *process4 = [UIImage imageNamed:@"process_4.png"];
    UIImage *process5 = [UIImage imageNamed:@"process_5.png"];
    UIImage *process6 = [UIImage imageNamed:@"process_6.png"];
    
    processImages = [NSArray arrayWithObjects:processEmpty, process0, process1, process2, process3, process4, process5, process6, nil];
    
    UITapGestureRecognizer *processImageViewTapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(processImageViewDidTap)];
    processImageView = [[UIImageView alloc] initWithImage:[processImages objectAtIndex:processIndex]];
    [processImageView addGestureRecognizer:processImageViewTapGesture];
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
    
}

- (void) viewWillAppear:(BOOL)animated {
    [MBProgressHUD showHUDAddedTo:self.view animated:YES labelText:@"주문을 불러오는 중:)"];
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_LOW, 0), ^{
        afManager = [AFHTTPRequestOperationManager manager];
        [afManager setRequestSerializer:[AFHTTPRequestSerializer new]];
        // 세션 기반으로 회원의 주문 목록을 받아온다.
        [afManager POST:@"http://cleanbasket.co.kr/member/order" parameters:@{} success:^(AFHTTPRequestOperation *operation, id responseObject) {
            dataArray =  [NSJSONSerialization JSONObjectWithData: [responseObject[@"data"] dataUsingEncoding:NSUTF8StringEncoding]
                                                         options: NSJSONReadingMutableContainers
                                                           error: nil];
            realm = [RLMRealm defaultRealm];
            
            if ([dataArray count] > 0 && [Order objectForPrimaryKey:[NSNumber numberWithInt:[[[dataArray objectAtIndex:0] valueForKey:@"oid"] intValue]]]) {
                [realm beginWriteTransaction];
                [realm deleteObject:[Order objectForPrimaryKey:[NSNumber numberWithInt:[[[dataArray objectAtIndex:0] valueForKey:@"oid"] intValue]]]];
                [realm commitWriteTransaction];
            } else if ([dataArray count] == 0) {
                [MBProgressHUD hideHUDForView:self.view animated:YES];
                [self showHudMessage:@"주문이 없습니다!"];
                return;
            }
            
            [realm beginWriteTransaction];
            firstOrder = [Order createInDefaultRealmWithObject:[dataArray objectAtIndex:0]];
            [realm commitWriteTransaction];
            
            if ([[firstOrder pickupInfo] img]) {
                NSString *filePath = [NSString stringWithFormat:@"http://cleanbasket.co.kr/%@", [[firstOrder pickupInfo] img]];
                managerPhotoImage = [UIImage imageWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:filePath]]];
            }
            
            [profileView setImage:managerPhotoImage];
            
            [managerNameLabel setText:([[firstOrder pickupInfo] name]?[[firstOrder pickupInfo] name]:@"미지정")];
            [visitDateLabel setText:([firstOrder pickup_date]?[firstOrder pickup_date]:@"")];
            
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

- (void) processImageViewDidTap {
    ++processIndex;
    if ( processIndex > 7) {
        processIndex = 0;
    }
    NSLog(@"%d taptaptap", processIndex);
    [processImageView setImage:[processImages objectAtIndex:processIndex]];
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
