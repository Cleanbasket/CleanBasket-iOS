//
//  PriceViewController.m
//  CleanBasket
//
//  Created by Wonhyo Yi on 2014. 10. 3..
//  Copyright (c) 2014년 WashAppKorea. All rights reserved.
//

#import "PriceViewController.h"
#import "Item_code.h"
#import "Item.h"
#define FieldHeight 35
#define FieldWidth 300
#define CenterX (DEVICE_WIDTH - FieldWidth)/2
#define FirstElementY 74
#define Interval 40

@interface PriceViewController () <UITableViewDataSource, UITableViewDelegate>

@end

@implementation PriceViewController

- (instancetype)init {
    self = [super init];
    if (self) {
        UIImage *tabBarImage = [UIImage imageNamed:@"ic_menu_pricelist_01.png"];
        UIImage *selectedTabBarImage = [UIImage imageNamed:@"ic_menu_pricelist_02.png"];
        self.tabBarItem = [self.tabBarItem initWithTitle:@"가격표" image:tabBarImage selectedImage:selectedTabBarImage];
    }
    
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self.view setBackgroundColor:[UIColor whiteColor]];
    
    CBLabel *titleLabel = [[CBLabel alloc] initWithFrame:CGRectMake(0, 64, DEVICE_WIDTH, 64)];
    [titleLabel setText:@"최소주문: 10,000원\n배달비: 2,000원(단, 20,000원 이상 주문시 무료)\n*특수재질은 추가비용 2,000원이 발생할 수 있습니다."];
    [titleLabel setNumberOfLines:0];
    [titleLabel setFont:[UIFont systemFontOfSize:14.0f]];
    [titleLabel setTextColor:CleanBasketMint];
    [titleLabel setBackgroundColor:UltraLightGray];
    
    _itemArray = [Item_code allObjects];
    
    priceTableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 128, DEVICE_WIDTH, DEVICE_HEIGHT - NAV_STATUS_HEIGHT - TAPBAR_HEIGHT - titleLabel.frame.size.height) style:UITableViewStylePlain];
    [priceTableView setDataSource:self];
    [priceTableView setDelegate:self];
    
    [self.view addSubview:priceTableView];
    [self.view addSubview:titleLabel];
}

- (void)viewWillAppear:(BOOL)animated {
    [self.navigationController setNavigationBarHidden:NO];
    [self.navigationController.navigationBar setTranslucent:YES];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *CellIdentifier = @"PriceCell";
    
    CBTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    if (cell == nil) {
        
        cell = [[CBTableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier];
    }
    
    // Configure the cell...
    Item *currentItem = [_itemArray objectAtIndex:indexPath.row];
    
    NSNumberFormatter *numberFormatter = [[NSNumberFormatter alloc] init];
    [numberFormatter setNumberStyle: NSNumberFormatterCurrencyStyle];
    [numberFormatter setMaximumFractionDigits:0];
    [numberFormatter setCurrencySymbol:@"₩"];
    NSString *priceAsString = [numberFormatter stringFromNumber:[NSNumber numberWithInt:[currentItem price]]];
    
    cell.textLabel.text = [currentItem name];
    [cell.priceLabel setText:priceAsString];
    [cell.textLabel setTextColor:[UIColor grayColor]];
    [cell.priceLabel setTextColor:CleanBasketMint];
    
    return cell;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return _itemArray.count;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 35.0f;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
