//
//  CBOrderTableViewCell.h
//  CleanBasket
//
//  Created by Wonhyo Yi on 2014. 10. 19..
//  Copyright (c) 2014년 WashAppKorea. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CBConstants.h"

@interface CBOrderTableViewCell : UITableViewCell

@property (nonatomic, strong) UILabel *priceLabel;
@property int itemIndex;
@property int itemPrice;
@property UIStepper *stepper;
@property NSIndexPath *indexPath;
@property UILabel *quantityLabel;

@end
