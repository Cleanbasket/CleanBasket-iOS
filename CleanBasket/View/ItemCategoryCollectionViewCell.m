//
//  ItemCategoryCollectionViewCell.m
//  CleanBasket
//
//  Created by 이상진 on 2016. 1. 7..
//  Copyright © 2016년 WashappKorea. All rights reserved.
//

#import "ItemCategoryCollectionViewCell.h"

#define CleanBasketMint [UIColor colorWithRed:(131/255.0) green:(219/255.0) blue:(209/255.0) alpha:1.0]

@implementation ItemCategoryCollectionViewCell

- (void)selected{
    _bottomLine.backgroundColor = CleanBasketMint;
    _categoryNameLabel.textColor = CleanBasketMint;
}

- (void)unselected{
    _bottomLine.backgroundColor = [UIColor whiteColor];
    _categoryNameLabel.textColor = [UIColor darkGrayColor];

}

@end
