//
//  OrderDetailViewController.m
//  CleanBasket
//
//  Created by Wonhyo Yi on 2014. 10. 21..
//  Copyright (c) 2014년 WashAppKorea. All rights reserved.
//

#import "OrderDetailViewController.h"
#import <Realm/Realm.h>
#import "AFNetworking.h"
#import "Order.h"
#import "MBProgressHUD.h"
#import "CBOrderDetailTableViewCell.h"
#import "NSString+CBString.h"


@interface OrderDetailViewController () <UITableViewDataSource, UITableViewDelegate, UIGestureRecognizerDelegate>{
    AFHTTPRequestOperationManager *afManager;
    UITableView *orderTableView;
    RLMArray *orderList;
    NSArray *orderStateName;
}

@end

@implementation OrderDetailViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setTitle:@"주문 상세보기"];
    [self.view setBackgroundColor:[UIColor whiteColor]];
    
    orderStateName = @[@"주문완료", @"수거준비", @"수거완료/세탁중", @"배달준비", @"배달완료"];
    
//    [MBProgressHUD showHUDAddedTo:self.view animated:YES labelText:@"주문 정보 불러오는 중:)"];
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_LOW, 0), ^{
        afManager = [AFHTTPRequestOperationManager manager];
        [afManager setRequestSerializer:[AFHTTPRequestSerializer new]];
        
        // 세션 기반으로 회원의 주문 목록을 받아온다.
        [afManager POST:@"http://cleanbasket.co.kr/member/order" parameters:@{} success:^(AFHTTPRequestOperation *operation, id responseObject) {
            NSArray *jsonDict =  [NSJSONSerialization JSONObjectWithData: [responseObject[@"data"] dataUsingEncoding:NSUTF8StringEncoding]
                                                                 options: NSJSONReadingMutableContainers
                                                                   error: nil];
            NSLog(@"%@", jsonDict);
            RLMRealm *realm = [RLMRealm defaultRealm];
            orderList = [[RLMArray alloc] initWithObjectClassName:@"Order"];
            [realm beginWriteTransaction];
            for (NSDictionary *each in jsonDict) {
                if ([Order objectForPrimaryKey:[each valueForKey:@"oid"]])
                    [realm deleteObject:[Order objectForPrimaryKey:[each valueForKey:@"oid"]]];
                Order *order = [Order createInDefaultRealmWithObject:each];
                RLMArray *items = [each valueForKey:@"item"];
                for (NSDictionary *each in items) {
                    if ([Item objectForPrimaryKey:[each valueForKey:@"itid"]]) {
                        [realm deleteObject:[Item objectForPrimaryKey:[each valueForKey:@"itid"]]];
                    }
                    Item *newItem = [Item createInDefaultRealmWithObject:each];
                    [[order Item] addObject:newItem];
                }
                [realm addObject:order];
                [orderList addObject:order];
                
            };
            [realm commitWriteTransaction];
            
            orderTableView = [[UITableView alloc] initWithFrame:CGRectMake(0, NAV_STATUS_HEIGHT, DEVICE_WIDTH, DEVICE_HEIGHT - NAV_STATUS_HEIGHT) style:UITableViewStylePlain];
            [orderTableView setDelegate:self];
            [orderTableView setDataSource:self];
            [orderTableView setSeparatorColor:[UIColor clearColor]];
            [self.view addSubview:orderTableView];
            dispatch_async(dispatch_get_main_queue(), ^{
                [MBProgressHUD hideHUDForView:self.view animated:YES];
            });
            
        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
            dispatch_async(dispatch_get_main_queue(), ^{
                [MBProgressHUD hideHUDForView:self.view animated:YES];
            });
            [self showHudMessage:@"주문 정보를 받아오는 데 실패하였습니다." afterDelay:2];
            [self performSelector:@selector(popToRootViewController) withObject:self afterDelay:2];
        }];
        
    });
    
}

- (void) popToRootViewController {
    [self.navigationController popToRootViewControllerAnimated:YES];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewWillDisappear:(BOOL)animated {
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

#pragma mark -
#pragma mark UITableViewDelegateMethod

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *CellIdentifier = @"OrderCell";
    CBOrderDetailTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    if (cell == nil) {
        cell = [[CBOrderDetailTableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier];
    }
    
    Order *currentOrder = [orderList objectAtIndex:[indexPath row]];
    
    if ([currentOrder pickupInfo]) {
        NSLog(@"create for %@", currentOrder);
        NSString *filePath = [NSString stringWithFormat:@"http://cleanbasket.co.kr/%@", [[currentOrder pickupInfo] img]];
        UIImage *managerPhoto = [UIImage imageWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:filePath]]];
        [cell.managerPhotoView setImage:managerPhoto];
        [cell.managerPhotoView.layer setCornerRadius:cell.managerPhotoView.frame.size.width / 2];
    } else {
        UIImage *defaultPhoto = [UIImage imageNamed:@"ic_profile_no.png"];
        [cell.managerPhotoView setImage:defaultPhoto];
        [cell.managerPhotoView.layer setCornerRadius:0];
    }
    
    [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
    [cell.orderNumberValueLabel setText:[currentOrder order_number]];
    [cell.orderPriceValueLabel setText:[NSString stringWithCurrencyFormat:[currentOrder price]]];
    [cell.orderItemsValueLabel setText:[self orderedItemString:currentOrder]];
    [cell.orderItemsValueLargeLabel setText:[self orderedItemString:currentOrder]];
    [cell.orderStatusValueLabel setText:[orderStateName objectAtIndex:[currentOrder state]]];
    [cell.orderPickupValueLabel setText:[NSString trimDateString:[currentOrder pickup_date]]];
    [cell.orderDeliverValueLabel setText:[NSString trimDateString:[currentOrder dropoff_date]]];
    [cell.managerNameValueLabel setText:([[currentOrder pickupInfo] name]?[[currentOrder pickupInfo] name]:@"미지정")];
    [cell.orderStatusValueLabel setText:[orderStateName objectAtIndex:[currentOrder state]]];
    [cell.orderCancelButton addTarget:self action:@selector(orderCancelButtonDidTap:) forControlEvents:UIControlEventTouchUpInside];
    
    return cell;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [orderList count];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return DEVICE_WIDTH;
}

- (NSString*)orderedItemString:(Order*)currentOrder {
    NSString *resultString = @"";
    RLMArray *items = [currentOrder Item];
    for (Item *each in items) {
        NSString *itemName = [each name];
        NSString *itemQuantity = [NSString stringWithFormat:@"%d", [each count]];
        NSString *nameAndQuantity = [NSString stringWithFormat:@"%@(%@) ", itemName, itemQuantity];
        resultString = [resultString stringByAppendingString:nameAndQuantity];
    }
    NSLog(@"result: %@", resultString);
    
    return resultString;
}

- (void) orderCancelButtonDidTap:(id)sender {
    [MBProgressHUD showHUDAddedTo:self.view animated:YES labelText:@"주문 취소 요청 중"];
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_LOW, 0), ^{
        
        CGPoint hitPoint = [sender convertPoint:CGPointZero toView:orderTableView];
        NSIndexPath *hitIndex = [orderTableView indexPathForRowAtPoint:hitPoint];
        CBOrderDetailTableViewCell *selectedCell = (CBOrderDetailTableViewCell*)[orderTableView cellForRowAtIndexPath:hitIndex];
        NSString *oid = [[selectedCell.orderNumberValueLabel text] substringFromIndex:7];
        
        afManager = [AFHTTPRequestOperationManager manager];
        [afManager setRequestSerializer:[AFJSONRequestSerializer new]];
        // 세션 기반으로 회원의 주문을 취소한다.
        [afManager POST:@"http://cleanbasket.co.kr/member/order/del" parameters:@{@"oid":[NSNumber numberWithInt:[oid intValue]]} success:^(AFHTTPRequestOperation *operation, id responseObject) {
            
            int constant = [[responseObject valueForKey:@"constant"] intValue];
            
            dispatch_async(dispatch_get_main_queue(), ^{
                [MBProgressHUD hideHUDForView:self.view animated:YES];
            });
            
            switch (constant) {
                case CBServerConstantSuccess: {
                    NSLog(@"%d", constant);
                    RLMRealm *realm = [RLMRealm defaultRealm];
                    Order *selectedOrder = [orderList objectAtIndex:[hitIndex row]];
                    [realm beginWriteTransaction];
                    if ([orderList objectAtIndex:[hitIndex row]])
                        [orderList removeObjectAtIndex:[hitIndex row]];
                    RLMArray *items = [selectedOrder Item];
                    [realm deleteObjects:items];
                    [realm deleteObject:selectedOrder];
                    [realm commitWriteTransaction];
                    [orderTableView reloadData];
                    break;
                }
                case CBServerConstantError: {
                    [self showHudMessage:@"서버 오류가 발생했습니다." afterDelay:2];
                    break;
                }
                case CBServerConstantsImpossible: {
                    UIAlertView *impossible = [[UIAlertView alloc] initWithTitle:@"주문 취소 불가" message:@"수거 한 주문은 취소할 수 없습니다.\n매니저에게 연락 부탁드립니다." delegate:self cancelButtonTitle:@"닫기" otherButtonTitles:nil, nil];
                    [impossible show];
                    break;
                }
                case CBServerConstantSessionExpired: {
                    [self showHudMessage:@"세션이 만료되었습니다. 다시 로그인해주세요." afterDelay:2];
                    //AppDelegate에 세션이 만료됨을 알림
                    [[NSNotificationCenter defaultCenter] postNotificationName:@"sessionExpired" object:self];
                    break;
                }
            }
            
            
            
        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
            dispatch_async(dispatch_get_main_queue(), ^{
                [MBProgressHUD hideHUDForView:self.view animated:YES];
            });
            [self showHudMessage:@"네트워크 상태를 확인해주세요!" afterDelay:1];
        }];
        
    });
    
    
}

@end
