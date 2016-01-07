//
//  EstimateViewController.m
//  CleanBasket
//
//  Created by 이상진 on 2016. 1. 5..
//  Copyright © 2016년 WashappKorea. All rights reserved.
//

#import "EstimateViewController.h"
#import "ItemTableViewCell.h"
#import "CBConstants.h"
#import "ItemCategoryCollectionViewCell.h"
#import <AFNetworking/AFNetworking.h>

@interface EstimateViewController () {
    NSInteger categoryIndex, totalPrice;
}

@property NSArray *categories;
@property NSMutableArray *items;
@property NSMutableArray *selectedItems;
@property NSMutableDictionary *selectedItemsCounts;
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UICollectionView *collectionView;
@property NSNumberFormatter *numberFormatter;
@property (weak, nonatomic) IBOutlet UILabel *totalCountLabel;
@property (weak, nonatomic) IBOutlet UILabel *totalPriceLabel;

@end

@implementation EstimateViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    _categories = [NSArray new];
    _items = [NSMutableArray new];
    _selectedItems = [NSMutableArray new];
    _selectedItemsCounts = [NSMutableDictionary new];

    _numberFormatter = [NSNumberFormatter new];
    [_numberFormatter setNumberStyle:NSNumberFormatterDecimalStyle];

    categoryIndex = 0;
    totalPrice = 0;
//    [_tableView setScrollsToTop:YES];



    [self getItems];

}



- (void)getItems{
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];

    manager.responseSerializer = [AFJSONResponseSerializer serializer];
    manager.responseSerializer.acceptableContentTypes = [manager.responseSerializer.acceptableContentTypes setByAddingObject:@"text/html"];

    [manager GET:@"http://www.cleanbasket.co.kr/item"
      parameters:nil
         success:^(AFHTTPRequestOperation *operation, id responseObject) {

             NSError *jsonError;
             NSData *objectData = [responseObject[@"data"] dataUsingEncoding:NSUTF8StringEncoding];
             
             NSDictionary *data = [NSJSONSerialization JSONObjectWithData:objectData
                                                                  options:NSJSONReadingMutableContainers
                                                                    error:&jsonError];

             
             _categories = data[@"categories"];
//             _items = data[@"orderItems"];
             
             for (int i = 0 ; i<_categories.count ; i++) {
                 NSMutableArray *array = [NSMutableArray new];
                 [_items addObject:array];
             }
            
             
             for (NSDictionary *item in data[@"orderItems"]) {
                 NSInteger categoryNum = [item[@"category"] integerValue]-1;
                 
                 [_items[categoryNum] addObject:item];
             }
             
             
             [_collectionView reloadData];
             [_tableView reloadData];


         } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                NSLog(@"Error: %@", error);
            }];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];

}


#pragma mark -
#pragma mark TableViewDelegate

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {

    return [_items[section] count];
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    
    NSString *sectionName = NSLocalizedString(_categories[section][@"name"], @"카테고리명") ;
    
    
    return sectionName;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    


    ItemTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"itemCell"];

//    if (!cell){
//        [tableView registerNib:[UINib nibWithNibName:@"ItemTableViewCell" bundle:nil] forCellReuseIdentifier:@"itemCell"];
//        cell = [tableView dequeueReusableCellWithIdentifier:@"itemCell"];
//    }


    NSDictionary *item = _items[indexPath.section][indexPath.row];

    NSString *itemNameString = NSLocalizedString(item[@"descr"],@"아이템 이름");
    NSString *itemPriceString =  [NSString stringWithFormat:@"%@%@",[_numberFormatter stringFromNumber:item[@"price"]],NSLocalizedString(@"monetary_unit",@"원")];
//    NSLocalizedString(_items[indexPath.section][indexPath.row][@"price"],@"아이템 가격");

    [cell.itemNameLabel setText:itemNameString];
    [cell.itemPriceLabel setText:itemPriceString];

    [cell.increaseButton addTarget:self action:@selector(addItem:) forControlEvents:UIControlEventTouchUpInside];
    [cell.decreaseButton addTarget:self action:@selector(removeItem:) forControlEvents:UIControlEventTouchUpInside];

    NSString *indexString = [NSString stringWithFormat:@"%li,%li",indexPath.section,indexPath.row];
   

    if (_selectedItemsCounts[indexString]){
        [cell.itemCountLabel setText:[_selectedItemsCounts[indexString] stringValue]];

    } else{
        [cell.itemCountLabel setText:@"0"];
    }



    return cell;
}





- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return _categories.count;
}




- (void)scrollViewDidScroll:(UIScrollView *)scrollView {

//
//
    if (scrollView == _collectionView){
        return;
    }

    NSIndexPath *currentSectionIndexPath = [NSIndexPath indexPathForItem:[_tableView indexPathsForVisibleRows][0].section inSection:0];


    [_collectionView scrollToItemAtIndexPath:currentSectionIndexPath atScrollPosition:UICollectionViewScrollPositionCenteredHorizontally animated:NO];

    categoryIndex = [_tableView indexPathsForVisibleRows][0].section;

    for (int i = 0; i < _categories.count; ++i) {

        ItemCategoryCollectionViewCell *currentCell = (ItemCategoryCollectionViewCell*)[_collectionView cellForItemAtIndexPath:[NSIndexPath indexPathForItem:i inSection:0]];


        if (i==categoryIndex){
            [currentCell selected];
            continue;
        }


        [currentCell unselected];
    }

//
//    ItemCategoryCollectionViewCell *currentCell = [_collectionView cellForItemAtIndexPath:[NSIndexPath indexPathForItem:[_tableView indexPathsForVisibleRows][0].section inSection:0]];
//
//    [currentCell selected];


//    NSArray *visibleRows = [self.tableView indexPathsForVisibleRows];
//    NSMutableIndexSet *sections = [[NSMutableIndexSet alloc] init];
//    for (NSIndexPath *indexPath in visibleRows) {
//        [sections addIndex:indexPath.section];
//    }
//
//    NSMutableArray *headerViews = [NSMutableArray array];
//    [sections enumerateIndexesUsingBlock:^(NSUInteger idx, BOOL *stop) {
//        UIView *view = [self.tableView headerViewForSection:idx];
//        [headerViews addObject:view];
//    }];

}


-(void)addItem:(UIButton*) sender
{

    CGPoint touchPoint = [sender convertPoint:CGPointZero toView:_tableView];
    NSIndexPath *clickedButtonIndexPath = [_tableView indexPathForRowAtPoint:touchPoint];

    
    NSString *indexString = [NSString stringWithFormat:@"%li,%li",(long)clickedButtonIndexPath.section,(long)clickedButtonIndexPath.row];

    if ([[_selectedItemsCounts objectForKey:indexString] integerValue]){
        NSInteger number = [[_selectedItemsCounts objectForKey:indexString] integerValue];
        number+=1;
        _selectedItemsCounts[indexString] = @(number);
    } else {
        _selectedItemsCounts[indexString] = @1;
    }

    
    
    [_selectedItems addObject:_items[clickedButtonIndexPath.section][clickedButtonIndexPath.row]];


    [_tableView reloadRowsAtIndexPaths:@[clickedButtonIndexPath] withRowAnimation:UITableViewRowAnimationNone];
    [self calculateTotal];
    
    

}
-(void)removeItem:(UIButton*) sender
{

    CGPoint touchPoint = [sender convertPoint:CGPointZero toView:_tableView];
    NSIndexPath *clickedButtonIndexPath = [_tableView indexPathForRowAtPoint:touchPoint];

    
    NSString *indexString = [NSString stringWithFormat:@"%li,%li",clickedButtonIndexPath.section,clickedButtonIndexPath.row];
    
    if ([[_selectedItemsCounts objectForKey:indexString] integerValue]){
        NSInteger number = [[_selectedItemsCounts objectForKey:indexString] integerValue];
        number-=1;
        _selectedItemsCounts[indexString] = @(number);
        
        
    } else {
        _selectedItemsCounts[indexString] = @0;
    }
    
    
    NSDictionary *item = _items[clickedButtonIndexPath.section][clickedButtonIndexPath.row];
    
//
    NSInteger indexOfname = [_selectedItems indexOfObject:item];
    
    if(indexOfname != NSNotFound){
        NSLog(@"%ld",[_selectedItems indexOfObject:item]);

        [_selectedItems removeObjectAtIndex:[_selectedItems indexOfObject:item]];
    }



    [_tableView reloadRowsAtIndexPaths:@[clickedButtonIndexPath] withRowAnimation:UITableViewRowAnimationNone];
    [self calculateTotal];

}

- (void)calculateTotal{

    NSString *totalCountString = [NSString stringWithFormat:@"%@%@", [_numberFormatter stringFromNumber:@(_selectedItems.count)], NSLocalizedString(@"item_unit",@"개")];
    [_totalCountLabel setText:totalCountString];

    totalPrice = 0;
    for(NSDictionary *item in _selectedItems){
        totalPrice += [item[@"price"] integerValue];
    }

    NSString *totalPriceString = [NSString stringWithFormat:@"%@%@",[_numberFormatter stringFromNumber:@(totalPrice)],NSLocalizedString(@"monetary_unit",@"원")];
    [_totalPriceLabel setText:totalPriceString];



}


#pragma mark -
#pragma mark CollectionViewDelegate

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return _categories.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {


    ItemCategoryCollectionViewCell *collectionViewCell = [collectionView dequeueReusableCellWithReuseIdentifier:@"categoryCell" forIndexPath:indexPath];

    [collectionViewCell.categoryNameLabel setText:NSLocalizedString(_categories[indexPath.row][@"name"], @"카테고리명")];


    if (indexPath.row == categoryIndex){
        [collectionViewCell selected];
    } else {
        [collectionViewCell unselected];
    }

    return collectionViewCell;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {


    [_tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:indexPath.row] atScrollPosition:UITableViewScrollPositionTop animated:YES];



}

#pragma mark -
#pragma mark IBActions

- (IBAction)close:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}
- (IBAction)confirm:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

@end
