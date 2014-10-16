//
//  CBTableViewCell.m
//  CleanBasket
//
//  Created by Wonhyo Yi on 2014. 10. 12..
//  Copyright (c) 2014년 WashAppKorea. All rights reserved.
//

#import "CBTableViewCell.h"

@implementation CBTableViewCell
@synthesize priceLabel;

- (instancetype)init {
    self = [super init];
    
    if (self) {
//        NSLog(@"Cell!");
    }
    
    return self;
}

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString*)reuseIdentifier{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        priceLabel = [[UILabel alloc] initWithFrame:CGRectMake(225, 7.5, 80, 20)];
        [priceLabel setTextAlignment:NSTextAlignmentRight];
        [priceLabel setFont:[UIFont systemFontOfSize:14.0f]];
        [self.textLabel setFont:[UIFont systemFontOfSize:14.0f]];
        [self addSubview:priceLabel];
    }
    return self;
}

- (void)awakeFromNib {
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    
}

@end
