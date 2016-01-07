//
//  ItemCategoryCollectionViewCell.h
//  CleanBasket
//
//  Created by 이상진 on 2016. 1. 7..
//  Copyright © 2016년 WashappKorea. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ItemCategoryCollectionViewCell : UICollectionViewCell
@property (weak, nonatomic) IBOutlet UILabel *categoryNameLabel;
@property (weak, nonatomic) IBOutlet UIView *bottomLine;

- (void)selected;
- (void)unselected;

@end
