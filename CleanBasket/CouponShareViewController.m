//
//  CouponShareViewController.m
//  CleanBasket
//
//  Created by Wonhyo Yi on 2014. 10. 3..
//  Copyright (c) 2014년 WashAppKorea. All rights reserved.
//

#import "CouponShareViewController.h"
#import <Realm/Realm.h>
#import "AFNetworking.h"
#import "NSString+CBString.h"
#import "CBCouponTableViewCell.h"
#import "CBConstants.h"
#import "Coupon.h"
#import "MBProgressHUD.h"
#import <FacebookSDK/FacebookSDK.h>
#import <KakaoOpenSDK/KakaoOpenSDK.h>

static const CGFloat kIconSize = 70.0f;

@interface CouponShareViewController () <UITableViewDelegate, UITableViewDataSource, UIAlertViewDelegate> {
    UITableView *couponTableView;
    UIButton *couponInsertButton;
    NSString *couponCode;
    UIImageView *noCouponImageView;
}

@end

@implementation CouponShareViewController

- (instancetype)init {
    self = [super init];
    if (self) {
        UIImage *tabBarImage = [UIImage imageNamed:@"ic_menu_coupon_01.png"];
        UIImage *selectedTabBarImage = [UIImage imageNamed:@"ic_menu_coupon_02.png"];
        self.tabBarItem = [self.tabBarItem initWithTitle:@"쿠폰" image:tabBarImage selectedImage:selectedTabBarImage];
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self.view setBackgroundColor:[UIColor whiteColor]];
    [self setTitle:@"보유 쿠폰"];
    couponTableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 64, DEVICE_WIDTH, (iPhone5?COUPON_HEIGHT+80:COUPON_HEIGHT)) style:UITableViewStylePlain];
    [couponTableView setDelegate:self];
    [couponTableView setDataSource:self];
    [couponTableView.layer setBorderColor:CleanBasketMint.CGColor];
    [couponTableView.layer setBorderWidth:1.0f];
    [couponTableView setSeparatorColor:[UIColor clearColor]];
    
    noCouponImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"bg_coupon.png"]];
    [noCouponImageView setFrame:CGRectMake(0, 0, DEVICE_WIDTH, 162.0)];
    UILabel *couponNameLabel = [[UILabel alloc] initWithFrame:CGRectMake(20, 110, 280, 30)];
    [couponNameLabel setTextColor:[UIColor grayColor]];
    [couponNameLabel setText:@"쿠폰이 없어요ㅠㅠ"];
    [noCouponImageView addSubview:couponNameLabel];
    
    couponInsertButton = [[UIButton alloc] initWithFrame:CGRectMake(60, couponTableView.frame.origin.y + couponTableView.frame.size.height + 10, 200, 38)];
    [couponInsertButton setTitle:@"쿠폰번호 입력" forState:UIControlStateNormal];
    [couponInsertButton setBackgroundColor:UltraLightGray];
    [couponInsertButton setTitleColor:CleanBasketMint forState:UIControlStateNormal];
    [couponInsertButton setTitleColor:[UIColor whiteColor] forState:UIControlStateHighlighted];
    [couponInsertButton addTarget:self action:@selector(inputCouponButtonDidTap) forControlEvents:UIControlEventTouchUpInside];
    [couponInsertButton.layer setCornerRadius:10.0f];
    
    UIView *promoteView = [[UIView alloc] initWithFrame:CGRectMake(0, DEVICE_HEIGHT - 220, DEVICE_WIDTH, 220 - TAPBAR_HEIGHT)];
    [promoteView setBackgroundColor:[UIColor whiteColor]];
    
    UILabel *promoteLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, 10, 300, 50)];
    [promoteLabel setText:@"크린바스켓 추천하고 할인쿠폰 받자!"];
    [promoteLabel setTextColor:CleanBasketMint];
    [promoteLabel setFont:[UIFont boldSystemFontOfSize:18.0f]];
    [promoteLabel setTextAlignment:NSTextAlignmentCenter];
    [promoteLabel setAdjustsFontSizeToFitWidth:YES];
    
    UIButton *fbButton = [[UIButton alloc] initWithFrame:CGRectMake(60, 55, kIconSize, kIconSize)];
    UIButton *kaButton = [[UIButton alloc] initWithFrame:CGRectMake(200, 55, kIconSize, kIconSize)];
    [fbButton addTarget:self action:@selector(fbButtonDidTap) forControlEvents:UIControlEventTouchUpInside];
    [kaButton addTarget:self action:@selector(kaButtonDidTap) forControlEvents:UIControlEventTouchUpInside];
    [fbButton setBackgroundImage:[UIImage imageNamed:@"ic_coupon_facebook.png"] forState:UIControlStateNormal];
    [kaButton setBackgroundImage:[UIImage imageNamed:@"ic_coupon_kakao.png"] forState:UIControlStateNormal];
    
    UILabel *couponInfoLabel = [[UILabel alloc] initWithFrame:CGRectMake(20, 130, DEVICE_WIDTH - 40, 40)];
    [couponInfoLabel setText:@"추천한 사람과 추천 받은 사람 모두에게 할인쿠폰이 발급됩니다.\n(단, 추천 할인쿠폰은 1인 1매로 제한됩니다.)"];
    [couponInfoLabel setNumberOfLines:2];
    [couponInfoLabel setAdjustsFontSizeToFitWidth:YES];
    [couponInfoLabel setTextColor:[UIColor lightGrayColor]];
    [couponInfoLabel setTextAlignment:NSTextAlignmentCenter];
    
    //
    //    UIImageView *fbImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"ic_coupon_facebook.png"]];
    //    UIImageView *kaImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"ic_coupon_kakao.png"]];
    //    [fbImageView setFrame:CGRectMake(60, NAV_STATUS_HEIGHT+COUPON_HEIGHT+90, kIconSize, kIconSize)];
    //    [kaImageView setFrame:CGRectMake(200, NAV_STATUS_HEIGHT+COUPON_HEIGHT+90, kIconSize, kIconSize)];
    
    [couponTableView addSubview:noCouponImageView];
    [self.view addSubview:promoteView];
    [promoteView addSubview:fbButton];
    [promoteView addSubview:kaButton];
    [promoteView addSubview:couponInfoLabel];
    [self.view addSubview:couponTableView];
    [promoteView addSubview:promoteLabel];
    [self.view addSubview:couponInsertButton];
}

- (void) fbButtonDidTap {
    
    [MBProgressHUD showHUDAddedTo:self.view animated:YES labelText:@"서버와 통신 중"];
    AFHTTPRequestOperationManager *afManager = [AFHTTPRequestOperationManager manager];
    afManager.requestSerializer = [AFJSONRequestSerializer serializer];
    afManager.responseSerializer = [AFJSONResponseSerializer serializer];
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_LOW, 0), ^{
        [afManager POST:@"http://cleanbasket.co.kr/recommendation"  parameters:@{} success:^(AFHTTPRequestOperation *operation, id responseObject) {
            NSLog(@"%@", responseObject);
            NSNumber *constant = [responseObject valueForKey:@"constant"];
            NSString *couponUrl = @"http://cleanbasket.co.kr/";
            NSString *couponCodeAddr;
            if ([responseObject valueForKey:@"data"]) {
                couponCodeAddr = [responseObject valueForKey:@"data"];
                couponCode = [couponCodeAddr substringFromIndex:7];
                couponUrl = [couponUrl stringByAppendingString:couponCodeAddr];
            }
            
            dispatch_async(dispatch_get_main_queue(), ^{
                [MBProgressHUD hideHUDForView:self.view animated:YES];
            });
            
            switch ([constant intValue]) {
                case CBServerConstantSuccess: {
                    [self shareToFacebook:couponUrl];
                }
                    break;
                case CBServerConstantError: {
                    [self showHudMessage:@"서버 오류가 발생했습니다. 매니저에게 문의주세요."];
                }
                    break;
                case CBServerConstantsDuplication: {
                    [self shareToFacebook:couponUrl];
                }
                    break;
                case CBServerConstantSessionExpired: {
                    [self showHudMessage:@"세션이 만료되었습니다. 다시 로그인해주세요."];
                    //AppDelegate에 세션이 만료됨을 알림
                    [[NSNotificationCenter defaultCenter] postNotificationName:@"sessionExpired" object:self];
                }
                    break;
            }
            
        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
            dispatch_async(dispatch_get_main_queue(), ^{
                [MBProgressHUD hideHUDForView:self.view animated:YES];
                [self showHudMessage:@"네트워크 상태를 확인해주세요"];
            });
            NSLog(@"%@", error);
        }];
    });
}

- (void) shareToFacebook:(NSString*)link {
    // Check if the Facebook app is installed and we can present the share dialog
    FBLinkShareParams *params = [[FBLinkShareParams alloc] init];
    params.link = [NSURL URLWithString:link];
    
    // If the Facebook app is installed and we can present the share dialog
    if ([FBDialogs canPresentShareDialogWithParams:params]) {
        // Present the share dialog
        [FBDialogs presentShareDialogWithLink:params.link
                                      handler:^(FBAppCall *call, NSDictionary *results, NSError *error) {
                                          if(error) {
                                              // An error occurred, we need to handle the error
                                              // See: https://developers.facebook.com/docs/ios/errors
                                              NSLog(@"Error publishing story: %@", error.description);
                                              [self showHudMessage:@"오류가 발생했습니다. 나중에 다시 시도해주세요."];
                                          } else {
                                              // Success
                                              [self showHudMessage:@"고맙습니다! 코드가 클립보드에 복사되었습니다!"];
                                              UIPasteboard *pb = [UIPasteboard generalPasteboard];
                                              [pb setString:couponCode];
                                              NSLog(@"result %@", results);
                                          }
                                      }];
    } else {
        // Put together the dialog parameters
        NSMutableDictionary *params = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                       @"크린바스켓 할인쿠폰 for iOS", @"name",
                                       @"HTTP://CLEANBASKET.CO.KR/", @"caption",
                                       @"친구추천 2000원 할인쿠폰", @"description",
                                       link, @"link",
                                       nil];
        
        // Show the feed dialog
        [FBWebDialogs presentFeedDialogModallyWithSession:nil
                                               parameters:params
                                                  handler:^(FBWebDialogResult result, NSURL *resultURL, NSError *error) {
                                                      if (error) {
                                                          // An error occurred, we need to handle the error
                                                          // See: https://developers.facebook.com/docs/ios/errors
                                                          NSLog(@"Error publishing story: %@", error.description);
                                                          [self showHudMessage:@"오류가 발생했습니다. 나중에 다시 시도해주세요."];
                                                      } else {
                                                          if (result == FBWebDialogResultDialogNotCompleted) {
                                                              // User cancelled.
                                                              NSLog(@"User cancelled.");
                                                              [self showHudMessage:@"공유를 취소하셨습니다."];
                                                          } else {
                                                              // Handle the publish feed callback
                                                              NSDictionary *urlParams = [self parseURLParams:[resultURL query]];
                                                              
                                                              if (![urlParams valueForKey:@"post_id"]) {
                                                                  [self showHudMessage:@"공유를 취소하셨습니다."];
                                                                  NSLog(@"User cancelled.");
                                                                  
                                                              } else {
                                                                  // User clicked the Share button
                                                                  NSString *result = [NSString stringWithFormat: @"Posted story, id: %@", [urlParams valueForKey:@"post_id"]];
                                                                  NSLog(@"result %@", result);
                                                                  [self showHudMessage:@"고맙습니다! 코드가 클립보드에 복사되었습니다!"];
                                                                  UIPasteboard *pb = [UIPasteboard generalPasteboard];
                                                                  [pb setString:couponCode];
                                                              }
                                                          }
                                                      }
                                                  }];
    }
    
}

- (NSDictionary*)parseURLParams:(NSString *)query {
    NSArray *pairs = [query componentsSeparatedByString:@"&"];
    NSMutableDictionary *params = [[NSMutableDictionary alloc] init];
    for (NSString *pair in pairs) {
        NSArray *kv = [pair componentsSeparatedByString:@"="];
        NSString *val =
        [kv[1] stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
        params[kv[0]] = val;
    }
    return params;
}

- (void) kaButtonDidTap {
    [MBProgressHUD showHUDAddedTo:self.view animated:YES labelText:@"서버와 통신 중"];
    AFHTTPRequestOperationManager *afManager = [AFHTTPRequestOperationManager manager];
    afManager.requestSerializer = [AFJSONRequestSerializer serializer];
    afManager.responseSerializer = [AFJSONResponseSerializer serializer];
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_LOW, 0), ^{
        [afManager POST:@"http://cleanbasket.co.kr/recommendation"  parameters:@{} success:^(AFHTTPRequestOperation *operation, id responseObject) {
            NSLog(@"%@", responseObject);
            NSNumber *constant = [responseObject valueForKey:@"constant"];
            NSString *couponUrl = @"http://cleanbasket.co.kr/";
            NSString *couponCodeAddr;
            if ([responseObject valueForKey:@"data"]) {
                couponCodeAddr = [responseObject valueForKey:@"data"];
                couponCode = [couponCodeAddr substringFromIndex:7];
                couponUrl = [couponUrl stringByAppendingString:couponCodeAddr];
            }
            dispatch_async(dispatch_get_main_queue(), ^{
                [MBProgressHUD hideHUDForView:self.view animated:YES];
                switch ([constant intValue]) {
                    case CBServerConstantSuccess: {
                        [self shareWithKakao:couponUrl];
                    }
                        break;
                    case CBServerConstantError: {
                        
                    }
                        break;
                    case CBServerConstantsDuplication: {
                        [self shareWithKakao:couponUrl];
                    }
                        break;
                    case CBServerConstantSessionExpired: {
                        
                    }
                        break;
                }
                
            });
            
        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
            dispatch_async(dispatch_get_main_queue(), ^{
                [MBProgressHUD hideHUDForView:self.view animated:YES];
                [self showHudMessage:@"네트워크 상태를 확인해주세요"];
                NSLog(@"%@", error);
            });
        }];
    });
    
}

- (void) shareWithKakao:(NSString*)link {
    KakaoTalkLinkObject *label
    = [KakaoTalkLinkObject createLabel:@"CLEAN BASKET\n대한민국 대표 \n세탁 수거배달 서비스\n\n"];
    
    KakaoTalkLinkObject *button
    = [KakaoTalkLinkObject createWebButton:@"할인쿠폰받기"
                                       url:link];
    
    [KOAppCall openKakaoTalkAppLink:@[label, button]];
}

- (void) viewWillAppear:(BOOL)animated {
    [couponTableView reloadData];
    if ([[Coupon allObjects] count] < 1) {
        [noCouponImageView setHidden:NO];
    } else {
        [noCouponImageView setHidden:YES];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *CellIdentifier = @"couponCell";
    int couponIndex = (int)[indexPath row];
    RLMArray *couponList = [Coupon allObjects];
    Coupon *currentCoupon = [couponList objectAtIndex:couponIndex];
    
    CBCouponTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    if (cell == nil) {
        
        cell = [[CBCouponTableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier];
    }
    NSString *couponName = [currentCoupon name];
    couponName = [couponName stringByAppendingString:@" "];
    couponName = [couponName stringByAppendingString:[NSString stringWithCurrencyFormat:[currentCoupon value]]];
    couponName = [couponName stringByAppendingString:@" 할인권!"];
    [cell.couponNameLabel setText:couponName];
    
    [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
    [cell setCpid:[currentCoupon cpid]];
    return cell;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    RLMArray *couponList = [Coupon allObjects];
    return [couponList count];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 172.0f;
}

- (void) inputCouponButtonDidTap {
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"쿠폰번호입력"
                                                    message:@"발급받으신 쿠폰번호를 입력해주세요"
                                                   delegate:self
                                          cancelButtonTitle:@"취소"
                                          otherButtonTitles:@"확인", nil];
    [alert setAlertViewStyle:UIAlertViewStylePlainTextInput];
    [alert show];
    
}

-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (buttonIndex == 1) {
        NSDictionary *parameter = @{@"serial_number":[[alertView textFieldAtIndex:0] text]};
        [MBProgressHUD showHUDAddedTo:self.view animated:YES labelText:@"서버와 통신 중"];
        AFHTTPRequestOperationManager *afManager = [AFHTTPRequestOperationManager manager];
        afManager.requestSerializer = [AFJSONRequestSerializer serializer];
        afManager.responseSerializer = [AFJSONResponseSerializer serializer];
        
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_LOW, 0), ^{
            [afManager POST:@"http://cleanbasket.co.kr/member/coupon/issue"  parameters:parameter success:^(AFHTTPRequestOperation *operation, id responseObject) {
                NSNumber *constant = [responseObject valueForKey:@"constant"];
                dispatch_async(dispatch_get_main_queue(), ^{
                    [MBProgressHUD hideHUDForView:self.view animated:YES];
                    switch ([constant intValue]) {
                        case CBServerConstantSuccess: {
                            [self showHudMessage:@"성공적으로 쿠폰을 등록했습니다."];
                            [couponTableView reloadData];
                        }
                            break;
                        case CBServerConstantsDuplication: {
                            [self showHudMessage:@"이미 발급한 쿠폰입니다. 매니저에게 문의해주세요."];
                        }
                            break;
                        case CBServerConstantsInvalid: {
                            [self showHudMessage:@"올바르지 않은 쿠폰번호입니다."];
                        }
                            break;
                        case CBServerConstantError: {
                            [self showHudMessage:@"서버 오류가 발생했습니다."];
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

- (void) showHudMessage:(NSString*)message {
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.navigationController.view animated:YES labelText:nil];
    
    // Configure for text only and offset down
    hud.mode = MBProgressHUDModeText;
    hud.labelText = message;
    [hud setLabelFont:[UIFont systemFontOfSize:14.0f]];
    hud.margin = 10.f;
    hud.removeFromSuperViewOnHide = YES;
    [hud hide:YES afterDelay:2];
    return;
}

@end
