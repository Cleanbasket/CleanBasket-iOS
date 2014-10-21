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
    
    realm = [RLMRealm defaultRealm];
    orderList = [[RLMArray alloc] initWithObjectClassName:@"Order"];
    afManager = [AFHTTPRequestOperationManager manager];
    [afManager setRequestSerializer:[AFHTTPRequestSerializer new]];
    
    // 세션 기반으로 회원의 주문 목록을 받아온다.
    [afManager POST:@"http://cleanbasket.co.kr/member/order" parameters:@{} success:^(AFHTTPRequestOperation *operation, id responseObject) {
        jsonDict =  [NSJSONSerialization JSONObjectWithData: [responseObject[@"data"] dataUsingEncoding:NSUTF8StringEncoding]
                                                    options: NSJSONReadingMutableContainers
                                                      error: nil];
        
        [realm beginWriteTransaction];
        for (NSDictionary *each in jsonDict) {
            if ([Order objectForPrimaryKey:[each valueForKey:@"oid"]])
                [realm deleteObject:[Order objectForPrimaryKey:[each valueForKey:@"oid"]]];
            Order *order = [Order createInDefaultRealmWithObject:each];
            [realm addObject:order];
            [orderList addObject:order];
            
        };
        
        NSLog(@"Orders: %@", orderList);
        [realm commitWriteTransaction];
        
        orderTableView = [[UITableView alloc] initWithFrame:CGRectMake(0, NAV_STATUS_HEIGHT, DEVICE_WIDTH, DEVICE_HEIGHT - NAV_STATUS_HEIGHT) style:UITableViewStylePlain];
        [orderTableView setDelegate:self];
        [orderTableView setDataSource:self];
        
        [self.view addSubview:orderTableView];
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        [self showHudMessage:@"주문 정보를 받아오는 데 실패하였습니다."];
        [self performSelector:@selector(popToRootViewController) withObject:self afterDelay:2];
    }];
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

#pragma mark -
#pragma mark UITableViewDelegateMethod

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *CellIdentifier = @"OrderCell";
    Order *currentOrder = [orderList objectAtIndex:[indexPath row]];
    CBOrderDetailTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    if (cell == nil) {
        
        cell = [[CBOrderDetailTableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier];
    }
    
    
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
    [cell.orderPickupValueLabel setText:[currentOrder pickup_date]];
    [cell.orderDeliverValueLabel setText:[currentOrder dropoff_date]];
    [cell.managerNameValueLabel setText:([[currentOrder pickupInfo] name]?[[currentOrder pickupInfo] name]:@"미지정")];
    return cell;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [[Order allObjects] count] - 1;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 320.0f;
}

/*
 #pragma mark - Navigation
 
 // In a storyboard-based application, you will often want to do a little preparation before navigation
 - (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
 // Get the new view controller using [segue destinationViewController].
 // Pass the selected object to the new view controller.
 }
 */

@end
