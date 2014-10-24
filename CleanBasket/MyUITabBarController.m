//
//  MyUITabBarController.m
//  CleanBasket
//
//  Created by Wonhyo Yi on 2014. 10. 3..
//  Copyright (c) 2014년 WashAppKorea. All rights reserved.
//

#import "MyUITabBarController.h"
#import <Realm/Realm.h>
#import "Keychain.h"
#import "DTOManager.h"
#import "CBConstants.h"
#import "OrderDetailViewController.h"
#import "OrderStatusViewController.h"
#import "Order.h"
#import "MBProgressHUD.h"
#import "AFNetworking.h"
#import "User.h"

@interface MyUITabBarController () <UINavigationControllerDelegate, UIAlertViewDelegate>
{
    UITabBarItem *currentItem;
}

@end

@implementation MyUITabBarController

- (instancetype)init {
    self = [super init];
    if (self) {
        UILabel *moreTitleView = [[UILabel alloc] init];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(NotificationReceived:) name:nil object:nil];
        [moreTitleView setText:@"더 보기"];
    }
    
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self.navigationController setNavigationBarHidden:NO];
    [self.navigationItem setTitle:@"주문하기"];
    CGRect frame = CGRectMake(0.0, 0.0, self.view.bounds.size.width, 49);
    UIView *v = [[UIView alloc] initWithFrame:frame];
    [v setBackgroundColor:UltraLightGray];
    [[self tabBar] addSubview:v];
    [v.layer setBorderWidth:0];
    
    //set the tab bar title appearance for normal state
    [[UITabBarItem appearance]
     setTitleTextAttributes:@{NSForegroundColorAttributeName:[UIColor lightGrayColor], NSFontAttributeName:[UIFont systemFontOfSize:14.0f]}
     forState:UIControlStateNormal];
    
    //set the tab bar title appearance for selected state
    [[UITabBarItem appearance]
     setTitleTextAttributes:@{ NSForegroundColorAttributeName : CleanBasketMint,
                               NSFontAttributeName:[UIFont systemFontOfSize:14.0f]}
     forState:UIControlStateSelected];
    
    [self.tabBar setTintColor:CleanBasketMint];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)tabBar:(UITabBar *)tabBar didSelectItem:(UITabBarItem *)item {
    if (item.title == nil) {
        [self.navigationController setNavigationBarHidden:YES];
        [self.moreNavigationController.navigationItem setTitle:@"더 보기"];
    } else {
        [self.navigationItem setTitle:item.title];
        [self.navigationController setNavigationBarHidden:NO];
    }
    
    if ([item.title isEqualToString:@"진행상태" ]) {
        currentItem = item;
        [self setOrderListBarButtonItem];
    } else {
        [self.navigationItem setLeftBarButtonItem:nil];
    }
    
    if ([item.title isEqualToString:@"서비스 정보"]){
        UIBarButtonItem *logoutBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"로그아웃" style:UIBarButtonItemStylePlain target:self action:@selector(logoutBarButtonDidTap)];
        UIBarButtonItem *passwordBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"비밀번호" style:UIBarButtonItemStylePlain target:self action:@selector(passwordBarButtonDidTap)];
        [self.navigationItem setRightBarButtonItem:logoutBarButtonItem];
        [self.navigationItem setLeftBarButtonItem:passwordBarButtonItem];
    } else {
        [self.navigationItem setRightBarButtonItem:nil];
    }
}

- (void)dealloc {
    NSLog(@"tabbar dealloc");
}

- (void) orderBarButtonDidTap:(id)sender{
    RLMArray *orderList = [Order allObjects];
    NSLog(@"CURRENT ORDER COUNT: %lu", (unsigned long)[orderList count]);
    if ([orderList count] == 1) {
        [self showHudMessage:@"주문내역이 없습니다!" afterDelay:1];
        return;
    }
    
    UIBarButtonItem *newBackButton =
    [[UIBarButtonItem alloc] initWithTitle:@""
                                     style:UIBarButtonItemStylePlain
                                    target:nil
                                    action:nil];
    [[self navigationItem] setBackBarButtonItem:newBackButton];
    OrderDetailViewController *orderDetailViewController = [[OrderDetailViewController alloc] init];
    [MBProgressHUD showHUDAddedTo:orderDetailViewController.view animated:YES labelText:@"주문 정보 불러오는 중:)"];
    [self.navigationController pushViewController:orderDetailViewController animated:YES];
}

- (void) logoutBarButtonDidTap {
    [[NSNotificationCenter defaultCenter] postNotificationName:@"userDidLogout" object:nil];
}

- (void) passwordBarButtonDidTap {
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"비밀번호 변경" message:@"새로운 비밀번호를 입력해주세요" delegate:self cancelButtonTitle:@"취소" otherButtonTitles:@"확인", nil];
    [alertView setAlertViewStyle:UIAlertViewStyleSecureTextInput];
    [alertView show];
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    if ([[alertView buttonTitleAtIndex:buttonIndex] isEqualToString:@"확인"]) {
        NSDictionary *parameter = @{@"password":[[alertView textFieldAtIndex:0] text]};
        
        [MBProgressHUD showHUDAddedTo:self.view animated:YES labelText:@"비밀번호 변경 중"];
        AFHTTPRequestOperationManager *afManager = [AFHTTPRequestOperationManager manager];
        afManager.requestSerializer = [AFJSONRequestSerializer serializer];
        afManager.responseSerializer = [AFJSONResponseSerializer serializer];
        
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_LOW, 0), ^{
            [afManager POST:@"http://cleanbasket.co.kr/member/password/update"  parameters:parameter success:^(AFHTTPRequestOperation *operation, id responseObject) {
                NSNumber *constant = [responseObject valueForKey:@"constant"];
                dispatch_async(dispatch_get_main_queue(), ^{
                    [MBProgressHUD hideHUDForView:self.view animated:YES];
                    
                    switch ([constant intValue]) {
                        case CBServerConstantSuccess: {
                            [self showHudMessage:@"비밀번호를 안전하게 변경했습니다!"];
                            
                            // 변경한 비밀번호로 keychain 업데이트
                            Keychain *keychain = [[Keychain alloc]initWithService:APP_NAME_STRING withGroup:nil];
                            DTOManager *dtoManager = [DTOManager defaultManager];
                            NSString *emailAsKey = [[dtoManager currentUser] email];
                            NSData *passwordAsValue = [[[alertView textFieldAtIndex:0] text] dataUsingEncoding:NSUTF8StringEncoding];
                            
                            if ([keychain update:emailAsKey :passwordAsValue]) {
                                NSLog(@"data changed to keychain: %@ %@", emailAsKey, passwordAsValue);
                            } else {
                                NSLog(@"Failed");
                                NSLog(@"%@", [keychain find:emailAsKey]);
                            }
                            
                        }
                            break;
                        case CBServerConstantError: {
                            [self showHudMessage:@"서버 오류가 발생했습니다. 나중에 다시 시도해주세요."];
                        }
                            break;
                        case CBServerConstantSessionExpired: {
                            [self showHudMessage:@"세션이 만료되었습니다. 다시 로그인해주세요."];
                            //AppDelegate에 세션이 만료됨을 알림
                            [[NSNotificationCenter defaultCenter] postNotificationName:@"sessionExpired" object:self];
                        }
                            break;
                    }
                });
                
            } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    [MBProgressHUD hideHUDForView:self.view animated:YES];
                    [self showHudMessage:@"네트워크 상태를 확인해주세요"];
                });
                NSLog(@"%@", error);
            }];
        });
    }
}

- (void) showHudMessage:(NSString*)message afterDelay:(int)delay {
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.navigationController.view animated:YES labelText:message    ];
    // Configure for text only and offset down
    hud.mode = MBProgressHUDModeText;
    [hud setLabelFont:[UIFont systemFontOfSize:14.0f]];
    hud.margin = 10.f;
    hud.removeFromSuperViewOnHide = YES;
    
    [hud hide:YES afterDelay:delay];
    return;
}

// AppDelegate로 주문이 접수됨을 알리고, OrderStatusView로 전환
- (void)NotificationReceived:(NSNotification*)noti {
    if ([[noti name] isEqualToString:@"checkCompletedOrder"]) {
        [self setOrderListBarButtonItem];
        return;
    }
}

- (void) setOrderListBarButtonItem {
    UIBarButtonItem *leftBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"주문내역" style:UIBarButtonItemStylePlain target:self action:@selector(orderBarButtonDidTap:)];
    [self.navigationItem setLeftBarButtonItem:leftBarButtonItem];
}

- (void) showHudMessage:(NSString*)message {
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.navigationController.view animated:YES labelText:nil];
    
    // Configure for text only and offset down
    hud.mode = MBProgressHUDModeText;
    hud.labelText = message;
    [hud setLabelFont:[UIFont systemFontOfSize:14.0f]];
    hud.margin = 10.f;
    hud.removeFromSuperViewOnHide = YES;
    [hud hide:YES afterDelay:1];
    return;
}

@end
