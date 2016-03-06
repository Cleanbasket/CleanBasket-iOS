//
//  ItemListTableViewCell.h
//  CleanBasket
//
//  Created by 이상진 on 2016. 3. 6..
//  Copyright © 2016년 WashappKorea. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ItemListTableViewCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UILabel *itemNameLabel;
@property (weak, nonatomic) IBOutlet UILabel *itemPriceLabel;
@property (weak, nonatomic) IBOutlet UILabel *itemCountLabel;

@end
