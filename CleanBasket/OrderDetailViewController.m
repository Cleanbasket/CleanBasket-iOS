//
//  OrderDetailViewController.m
//  CleanBasket
//
//  Created by Wonhyo Yi on 2014. 10. 21..
//  Copyright (c) 2014년 WashAppKorea. All rights reserved.
//

#import "OrderDetailViewController.h"

@interface OrderDetailViewController () <UITableViewDataSource, UITableViewDelegate>

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
            
            RLMRealm *realm = [RLMRealm defaultRealm];
            orderList = [[RLMArray alloc] initWithObjectClassName:@"Order"];
            [realm beginWriteTransaction];
            for (NSDictionary *each in jsonDict) {
                if ([Order objectForPrimaryKey:[each valueForKey:@"oid"]])
                    [realm deleteObject:[Order objectForPrimaryKey:[each valueForKey:@"oid"]]];
                Order *order = [Order createInDefaultRealmWithObject:each];
                [realm addObject:order];
                [orderList addObject:order];
                
            };
            [realm commitWriteTransaction];
            
            orderTableView = [[UITableView alloc] initWithFrame:CGRectMake(0, NAV_STATUS_HEIGHT, DEVICE_WIDTH, DEVICE_HEIGHT - NAV_STATUS_HEIGHT) style:UITableViewStylePlain];
            [orderTableView setDelegate:self];
            [orderTableView setDataSource:self];
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
    hud.yOffset = 150.f;
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
    [cell.orderItemsValueLabel setText:nil];
    [cell.orderStatusValueLabel setText:nil];
    [cell.orderPickupValueLabel setText:[[currentOrder pickup_date] substringToIndex:16]];
    [cell.orderDeliverValueLabel setText:[[currentOrder dropoff_date] substringToIndex:16]];
    [cell.managerNameValueLabel setText:([[currentOrder pickupInfo] name]?[[currentOrder pickupInfo] name]:@"미지정")];
    [cell.orderStatusValueLabel setText:[orderStateName objectAtIndex:[currentOrder state]]];
    [cell.orderCancelButton addTarget:self action:@selector(orderCancelButtonDidTap:) forControlEvents:UIControlEventTouchUpInside];
    return cell;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [orderList count];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 320.0f;
}

- (void) orderCancelButtonDidTap:(id)sender {
    [MBProgressHUD showHUDAddedTo:self.view animated:YES labelText:@"주문 취소 요청 중"];
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_LOW, 0), ^{
        
        CGPoint hitPoint = [sender convertPoint:CGPointZero toView:orderTableView];
        NSIndexPath *hitIndex = [orderTableView indexPathForRowAtPoint:hitPoint];
        CBOrderDetailTableViewCell *selectedCell = (CBOrderDetailTableViewCell*)[orderTableView cellForRowAtIndexPath:hitIndex];
        NSString *oid = [[selectedCell.orderNumberValueLabel text] substringFromIndex:7];
        NSLog(@"indexRow: %d", [hitIndex row]);
        
        afManager = [AFHTTPRequestOperationManager manager];
        [afManager setRequestSerializer:[AFJSONRequestSerializer new]];
        // 세션 기반으로 회원의 주문 목록을 받아온다.
        [afManager POST:@"http://cleanbasket.co.kr/member/order/del" parameters:@{@"oid":[NSNumber numberWithInt:[oid intValue]]} success:^(AFHTTPRequestOperation *operation, id responseObject) {
            NSLog(@"%@", responseObject);
            
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
                    [realm deleteObject:selectedOrder];
                    [realm commitWriteTransaction];
                    [orderTableView reloadData];
                    break;
                }
                case CBServerConstantError: {
                    break;
                }
                case CBServerConstantsImpossible: {
                    break;
                }
                case CBServerConstantSessionExpired: {
                    break;
                }
                default:
                    break;
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
