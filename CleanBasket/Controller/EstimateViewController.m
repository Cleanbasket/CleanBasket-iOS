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
#import "AddedItem.h"
#import <Realm/Realm.h>

@interface EstimateViewController () {
    NSInteger categoryIndex;
    NSArray *_receivedItems;
}

@property NSArray *categories;
@property NSMutableArray *items;
//@property NSMutableArray *selectedItems;
//@property NSMutableDictionary *selectedItemsCounts;
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UICollectionView *collectionView;
@property NSNumberFormatter *numberFormatter;
@property (weak, nonatomic) IBOutlet UILabel *totalCountLabel;
@property (weak, nonatomic) IBOutlet UILabel *totalPriceLabel;

@property (strong, nonatomic) RLMRealm *realm;
@property (strong, nonatomic) RLMResults *itemsFromRealm;


@end

@implementation EstimateViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self getItems];
    
    _categories = [NSArray new];
    _items = [NSMutableArray new];
//    _selectedItems = [NSMutableArray new];
//    _selectedItemsCounts = [NSMutableDictionary new];

    _numberFormatter = [NSNumberFormatter new];
    [_numberFormatter setNumberStyle:NSNumberFormatterDecimalStyle];

    categoryIndex = 0;
//    totalPrice = 0;
//    [_tableView setScrollsToTop:YES];


    _realm = [RLMRealm defaultRealm];

//    if (_receivedItems == nil) {
        _itemsFromRealm = [AddedItem allObjects];
//    }
    [self calculateTotal];
    
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

             [self settingReceivedItems];

         } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                NSLog(@"Error: %@", error);
            }];
}


- (void)settingReceivedItems{
    
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];

}


#pragma mark -
#pragma mark TableViewDelegate

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {

    return [(NSArray*)_items[section] count];
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

//    NSString *indexString = [NSString stringWithFormat:@"%zd,%zd",indexPath.section,indexPath.row];
   
    AddedItem *addedItem = [[_itemsFromRealm objectsWhere:@"itemCode == %@", item[@"item_code"]] firstObject];
    
    if (addedItem != nil){
        [cell.itemCountLabel setText:[addedItem.addedCount stringValue]];

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

    
//    NSString *indexString = [NSString stringWithFormat:@"%li,%li",(long)clickedButtonIndexPath.section,(long)clickedButtonIndexPath.row];
//
//    if ([[_selectedItemsCounts objectForKey:indexString] integerValue]){
//        NSInteger number = [[_selectedItemsCounts objectForKey:indexString] integerValue];
//        number+=1;
//        _selectedItemsCounts[indexString] = @(number);
//    } else {
//        _selectedItemsCounts[indexString] = @1;
//    }

    AddedItem *item = [[AddedItem objectsWhere:@"itemCode == %@", _items[clickedButtonIndexPath.section][clickedButtonIndexPath.row][@"item_code"]] firstObject];
    
    if (item == nil) {
        [_realm transactionWithBlock:^{
            AddedItem *item = [AddedItem new];
            item.itemCode = _items[clickedButtonIndexPath.section][clickedButtonIndexPath.row][@"item_code"];
            item.itemPrice = _items[clickedButtonIndexPath.section][clickedButtonIndexPath.row][@"price"];
            item.addedCount = @1;
            [_realm addObject:item];
        }];
    }
    else {
        [_realm transactionWithBlock:^{
            item.addedCount = [NSNumber numberWithInteger:item.addedCount.integerValue+1];
        }];
    
    }
    
//    _itemsFromRealm = []
    
    
    
//    [_selectedItems addObject:_items[clickedButtonIndexPath.section][clickedButtonIndexPath.row]];


    [_tableView reloadRowsAtIndexPaths:@[clickedButtonIndexPath] withRowAnimation:UITableViewRowAnimationNone];
    [self calculateTotal];
}

-(void)removeItem:(UIButton*) sender
{

    CGPoint touchPoint = [sender convertPoint:CGPointZero toView:_tableView];
    NSIndexPath *clickedButtonIndexPath = [_tableView indexPathForRowAtPoint:touchPoint];

    
//    NSString *indexString = [NSString stringWithFormat:@"%zd,%zd",clickedButtonIndexPath.section,clickedButtonIndexPath.row];
//    
//    if ([[_selectedItemsCounts objectForKey:indexString] integerValue]){
//        NSInteger number = [[_selectedItemsCounts objectForKey:indexString] integerValue];
//        number-=1;
//        _selectedItemsCounts[indexString] = @(number);
//        
//        
//    } else {
//        _selectedItemsCounts[indexString] = @0;
//    }
//    
//    
//    NSDictionary *item = _items[clickedButtonIndexPath.section][clickedButtonIndexPath.row];
//    
////
//    NSInteger indexOfname = [_selectedItems indexOfObject:item];
//    
//    if(indexOfname != NSNotFound){
//        
//
//        [_selectedItems removeObjectAtIndex:[_selectedItems indexOfObject:item]];
//    }
    AddedItem *item = [[AddedItem objectsWhere:@"itemCode == %@", _items[clickedButtonIndexPath.section][clickedButtonIndexPath.row][@"item_code"]] firstObject];
    
    if ([item.addedCount isEqualToNumber:@1]) {
        [_realm beginWriteTransaction];
        [_realm deleteObject:item];
        [_realm commitWriteTransaction];
    }
    else {
        
        [_realm beginWriteTransaction];
        item.addedCount = [NSNumber numberWithInteger:item.addedCount.integerValue-1];
        [_realm commitWriteTransaction];
    }


    [_tableView reloadRowsAtIndexPaths:@[clickedButtonIndexPath] withRowAnimation:UITableViewRowAnimationNone];
    [self calculateTotal];

}

- (void)calculateTotal{

//    NSString *totalCountString = [NSString stringWithFormat:@"%@%@", [_numberFormatter stringFromNumber:@(_selectedItems.count)], NSLocalizedString(@"item_unit",@"개")];
//    [_totalCountLabel setText:totalCountString];
//
//    totalPrice = 0;
//    for(NSDictionary *item in _selectedItems){
//        totalPrice += [item[@"price"] integerValue];
//    }
//
//    NSString *totalPriceString = [NSString stringWithFormat:@"%@%@",[_numberFormatter stringFromNumber:@(totalPrice)],NSLocalizedString(@"monetary_unit",@"원")];
//    [_totalPriceLabel setText:totalPriceString];
    
    
    if (_itemsFromRealm != nil) {
        NSInteger totalPrice = 0;
        NSInteger totalItemCount = 0;
        for (AddedItem *item in _itemsFromRealm) {
            totalPrice += item.itemPrice.integerValue*item.addedCount.integerValue;
            totalItemCount += item.addedCount.integerValue;
        }
        _totalPriceLabel.text = [@(totalPrice) stringValue];
        _totalCountLabel.text = [NSString stringWithFormat:@"%@%@", [_numberFormatter stringFromNumber:@(totalItemCount)], NSLocalizedString(@"item_unit",@"개")];
    }


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
    
    [_realm transactionWithBlock:^{
        [_realm deleteObjects:[AddedItem allObjects]];
    }];
    [self dismissViewControllerAnimated:YES completion:nil];
}
- (IBAction)confirm:(id)sender {

    
//    NSMutableDictionary *items = [NSMutableDictionary new];
//    //{"item_code":@Count}
//
//    for (NSDictionary *item in self.selectedItems) {
//        
//        //아이템코드 스트링
//        NSString *itemCode = [item[@"item_code"] stringValue];
//        
//        
//        if (items[itemCode] != nil) {
//            items[itemCode] = @([items[itemCode] integerValue] +1);
//        }
//        else
//            [items setValue:@1 forKey:[item[@"item_code"] stringValue]];
//    }
//    
//    
//    
//    [[NSNotificationCenter defaultCenter] postNotificationName:@"didFinishEstimate"
//                                                        object:nil
//                                                      userInfo:@{@"totalPrice":@(totalPrice),
//                                                                 @"items":items}];
    
    [self dismissViewControllerAnimated:YES completion:nil];
//    [self close:nil];
}

@end
