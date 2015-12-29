//
//  CouponTableViewCell.h
//  CleanBasket
//
//  Created by 이상진 on 2015. 12. 26..
//  Copyright © 2015년 WashappKorea. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CouponTableViewCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UILabel *priceLabel;
@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
@property (weak, nonatomic) IBOutlet UILabel *dateLabel;

@end
