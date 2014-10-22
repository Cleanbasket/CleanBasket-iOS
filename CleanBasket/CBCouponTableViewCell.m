//
//  CBCouponTableViewCell.m
//  CleanBasket
//
//  Created by Wonhyo Yi on 2014. 10. 21..
//  Copyright (c) 2014년 WashAppKorea. All rights reserved.
//

#import "CBCouponTableViewCell.h"

@implementation CBCouponTableViewCell

- (void)awakeFromNib {
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        _couponImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"bg_coupon.png"]];
        [_couponImageView setFrame:CGRectMake(0, 0, DEVICE_WIDTH, COUPON_HEIGHT)];
        
        _couponNameLabel = [[UILabel alloc] initWithFrame:CGRectMake(20, 110, 280, 30)];
        [_couponNameLabel setTextColor:[UIColor grayColor]];
        
        [self addSubview:_couponImageView];
        [self addSubview:_couponNameLabel];
    }
    return self;
}

@end
