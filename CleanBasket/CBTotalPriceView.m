//
//  CBTotalPriceView.m
//  CleanBasket
//
//  Created by Wonhyo Yi on 2014. 10. 19..
//  Copyright (c) 2014년 WashAppKorea. All rights reserved.
//

#import "CBTotalPriceView.h"
#import "CBConstants.h"
#define HEIGHT_MENU 44
#define HEIGHT_BUTTON 35

@implementation CBTotalPriceView {
    UILabel *totalLabel;
}

@synthesize totalPriceLabel = totalPriceLabel;

- (instancetype)init {
    self = [super init];
    if (self) {
        [self setFrame:CGRectMake(0, DEVICE_HEIGHT - HEIGHT_MENU, DEVICE_WIDTH, HEIGHT_MENU)];
        [self setBackgroundColor:UltraLightGray];
        
        totalLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, 0, HEIGHT_MENU, HEIGHT_MENU)];
        [totalLabel setBackgroundColor:[UIColor clearColor]];
        [totalLabel setTextColor:CleanBasketMint];
        [totalLabel setText:@"합계"];
        [totalLabel setTextAlignment:NSTextAlignmentCenter];
        [totalLabel setFont:[UIFont boldSystemFontOfSize:18.0f]];
        
        totalPriceLabel = [[UILabel alloc] initWithFrame:CGRectMake(220, 0, 100, HEIGHT_MENU)];
        [totalPriceLabel setBackgroundColor:[UIColor clearColor]];
        [totalPriceLabel setText:@""];
        [totalPriceLabel setTextColor:CleanBasketMint];
        
        
        [self addSubview:totalLabel];
        [self addSubview:totalPriceLabel];
    }
    return self;
}

@end
