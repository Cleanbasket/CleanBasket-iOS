//
//  PriceViewController.m
//  CleanBasket
//
//  Created by Wonhyo Yi on 2014. 10. 3..
//  Copyright (c) 2014년 WashAppKorea. All rights reserved.
//

#import "PriceViewController.h"
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
    
    itemArray = @[@"와이셔츠", @"정장(한벌)", @"바지/스커트", @"블라우스", @"원피스", @"코트", @"정장(상의)", @"정장(하의)", @"점퍼", @"자켓", @"스웨터", @"교복(한벌)", @"가죽점퍼(Short)", @"가죽점퍼(Long)", @"아웃도어&골프웨어", @"가디건/조끼", @"한복", @"넥타이/스카프/목도리", @"티셔츠", @"추가비용(실크,마,울,캐시미어)",];
    priceArray = @[@"2,000원", @"6,000원", @"3,000원", @"4,000원", @"7,000원", @"8,000원", @"3,500원", @"3,500원", @"7,000원", @"4,000원", @"4,000원", @"5,000원", @"30,000원", @"40,000원", @"10,000원", @"4,000원", @"15,000원", @"1,000원", @"3,000원", @"2,000원"];
    
    CBLabel *titleLabel = [[CBLabel alloc] initWithFrame:CGRectMake(0, 64, 320, 64)];
    [titleLabel setText:@"최소주문: 10,000원\n배달비: 2,000원(단, 20,000원 이상 주문시 무료)\n*특수재질은 추가비용 2,000원이 발생할 수 있습니다."];
    [titleLabel setNumberOfLines:0];
    [titleLabel setFont:[UIFont systemFontOfSize:14.0f]];
    [titleLabel setTextColor:CleanBasketMint];
    [titleLabel setBackgroundColor:UltraLightGray];
    
    UITableView *priceTableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 128, 320, 303) style:UITableViewStylePlain];
    [priceTableView.layer setBorderColor:[UIColor redColor].CGColor];
    [priceTableView.layer setBorderWidth:1.0f];
    [priceTableView setDataSource:self];
    [priceTableView setDelegate:self];
    
    [self.view addSubview:priceTableView];
    [self.view addSubview:titleLabel];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *CellIdentifier = @"PriceCell";
    
    CBTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    if (cell == nil) {
        
        cell = [[CBTableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier];
    }
    
    // Configure the cell...
    cell.textLabel.text = [itemArray objectAtIndex:indexPath.row];
    [cell.priceLabel setText:[priceArray objectAtIndex:indexPath.row]];
    [cell.textLabel setTextColor:[UIColor grayColor]];
    [cell.priceLabel setTextColor:CleanBasketMint];
    
    return cell;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 20;
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
