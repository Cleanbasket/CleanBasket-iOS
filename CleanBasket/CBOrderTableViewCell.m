//
//  CBOrderTableViewCell.m
//  CleanBasket
//
//  Created by Wonhyo Yi on 2014. 10. 19..
//  Copyright (c) 2014년 WashAppKorea. All rights reserved.
//

#import "CBOrderTableViewCell.h"

@implementation CBOrderTableViewCell {

}

@synthesize priceLabel = priceLabel, itemIndex = itemIndex, stepper = stepper, quantityLabel = quantityLabel;

- (void)awakeFromNib {
    NSLog(@"Awake From Nib");
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString*)reuseIdentifier{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        [self setSelectionStyle:UITableViewCellSelectionStyleNone];
        
        priceLabel = [[UILabel alloc] initWithFrame:CGRectMake(111, 0, 80, self.contentView.frame.size.height)];
        [priceLabel setTextAlignment:NSTextAlignmentRight];
        [priceLabel setFont:[UIFont systemFontOfSize:14.0f]];
        [self.textLabel setFont:[UIFont systemFontOfSize:14.0f]];
        [priceLabel setTextColor:CleanBasketMint];
        
        stepper = [[UIStepper alloc] initWithFrame:CGRectMake(220, 7.5, 0, 0)];

        quantityLabel = [[UILabel alloc] initWithFrame:CGRectMake(196, 0, 20, self.contentView.frame.size.height)];
        [quantityLabel setText:@"0"];
        [quantityLabel setTextColor:[UIColor lightGrayColor]];
        [quantityLabel setTextAlignment:NSTextAlignmentCenter];
        [quantityLabel setFont:[UIFont systemFontOfSize:14.0f]];
        
        [self addSubview:priceLabel];
        [self addSubview:stepper];
        [self addSubview:quantityLabel];
    }
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    [self.textLabel setTextColor:[UIColor lightGrayColor]];
    [self.textLabel setAdjustsFontSizeToFitWidth:YES];
    [self.textLabel setFrame:CGRectMake(10, 0, 113, self.contentView.frame.size.height)];
    [self.textLabel setTextAlignment:NSTextAlignmentLeft];
    [self.textLabel setNumberOfLines:2];
    [self.textLabel setLineBreakMode:NSLineBreakByWordWrapping];
}



@end
