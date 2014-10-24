//
//  ChooseOtherLaundryViewController.m
//  CleanBasket
//
//  Created by Wonhyo Yi on 2014. 10. 19..
//  Copyright (c) 2014년 WashAppKorea. All rights reserved.
//

#import "ChooseOtherLaundryViewController.h"
#import <Realm/Realm.h>
#import "CBTotalPriceView.h"
#import "CBConstants.h"
#import "CBOrderTableViewCell.h"
#import "Item.h"
#import "UIView+CBView.h"

#define X_FIRST 10
#define X_SECOND 80
#define X_CENTER_DEVICE (DEVICE_WIDTH - WIDTH_REGULAR)/2
#define Y_FIRST 89
#define WIDTH_REGULAR 300
#define WIDTH_SMALL 60
#define WIDTH_LARGE 230
#define WIDTH_FULL 300
#define HEIGHT_REGULAR 35
#define MARGIN_REGULAR 60

@interface ChooseOtherLaundryViewController () <UITableViewDataSource, UITableViewDelegate> {
    int cellItemIndex;
    CBTotalPriceView *totalPriceView;
    RLMRealm *realm;
    UITableView *laundryTableView;
    int totalPrice;
}

@end

@implementation ChooseOtherLaundryViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    cellItemIndex = 6;
    [self.view setBackgroundColor:[UIColor whiteColor]];
    [self setTitle:@"세탁품목선택(기타)"];
    
    totalPriceView = [[CBTotalPriceView alloc] init];
    
    laundryTableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, DEVICE_WIDTH, DEVICE_HEIGHT - totalPriceView.frame.size.height) style:UITableViewStylePlain];
    [laundryTableView setDelegate:self];
    [laundryTableView setDataSource:self];
    
    [self calculateTotalPrice];
    NSNumberFormatter *numberFormatter = [[NSNumberFormatter alloc] init];
    [numberFormatter setNumberStyle: NSNumberFormatterCurrencyStyle];
    NSString *priceAsString = [numberFormatter stringFromNumber:[NSNumber numberWithInt:totalPrice]];
    [totalPriceView.totalPriceLabel setText:priceAsString];
    
    [self.view addSubview:laundryTableView];
    [self.view addSubview:totalPriceView];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    NSLog(@"%lu", (unsigned long)[self.itemArray count]);
    return [self.itemArray count] - 6;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *CellIdentifier = @"PriceCell";
    int itemIndex = (int)[indexPath row] + 6;
    Item *currentItem = [self.itemArray objectAtIndex:itemIndex];
    
    CBOrderTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    if (cell == nil) {
        
        cell = [[CBOrderTableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier];
    }
    
    // Configure the cell...
    NSNumberFormatter *numberFormatter = [[NSNumberFormatter alloc] init];
    [numberFormatter setNumberStyle: NSNumberFormatterCurrencyStyle];
    NSString *priceAsString = [numberFormatter stringFromNumber:[NSNumber numberWithInt:[currentItem price]]];
    [cell.priceLabel setText:priceAsString];
    
    [cell setItemPrice:[currentItem price]];
    [cell.textLabel setText:[currentItem name]];
    
    [cell.stepper setTintColor:CleanBasketMint];
    [cell.stepper addTarget:self action:@selector(stepperDidTap:) forControlEvents:UIControlEventValueChanged];
    [cell.stepper setValue:[currentItem count]];
    [cell.stepper setMinimumValue:0];
    [cell.stepper setMaximumValue:99];
    [cell.stepper setStepValue:1];
    
    [cell.quantityLabel setText:[NSString stringWithFormat:@"%d", [currentItem count]]];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
}

- (void) stepperDidTap:(id)sender {
    // stepper를 통해 수량을 변경한 경우 ChooseOtherLaundryItemViewController에 노티 전송
    UIStepper *stepper = (UIStepper*)sender;
//    UITableViewCell *cell = (UITableViewCell*)[stepper superview];
    UITableViewCell *cell = (UITableViewCell*)[stepper findSuperViewWithClass:[UITableViewCell class]];
    NSIndexPath *indexPath = [laundryTableView indexPathForCell:cell];
    CBOrderTableViewCell *currentCell = (CBOrderTableViewCell*)[laundryTableView cellForRowAtIndexPath:indexPath];
    NSLog(@"currentCell: %@", currentCell);
    
    realm = [RLMRealm defaultRealm];
    [realm beginWriteTransaction];
    Item *currentItem = [self.itemArray objectAtIndex:[indexPath row] + self.numberOfMainItems];
    [currentItem setCount:[stepper value]];
    NSLog(@"%@ quantity changed to %d!", [currentItem name], [currentItem count]);
    [totalPriceView.totalPriceLabel setText:[[NSUUID UUID] UUIDString]];
    
    [currentCell.quantityLabel setText:[NSString stringWithFormat:@"%d", [currentItem count]]];
    [realm commitWriteTransaction];
    
    [self calculateTotalPrice];
    NSNumberFormatter *numberFormatter = [[NSNumberFormatter alloc] init];
    [numberFormatter setNumberStyle: NSNumberFormatterCurrencyStyle];
    NSString *priceAsString = [numberFormatter stringFromNumber:[NSNumber numberWithInt:totalPrice]];
    [totalPriceView.totalPriceLabel setText:priceAsString];
}

- (void) calculateTotalPrice {
    totalPrice = 0;
    for ( int i = self.numberOfMainItems; i < [self.itemArray count]; ++i) {
        Item *each = [self.itemArray objectAtIndex:i];
        totalPrice += [each count] * [each price];
    }
}

@end
