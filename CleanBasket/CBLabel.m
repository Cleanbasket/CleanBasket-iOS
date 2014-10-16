//
//  CBLabel.m
//  CleanBasket
//
//  Created by Wonhyo Yi on 2014. 10. 12..
//  Copyright (c) 2014년 WashAppKorea. All rights reserved.
//

#import "CBLabel.h"

@implementation CBLabel

- (void)drawRect:(CGRect)rect {
    UIEdgeInsets insets = {0, 10, 0, 5};
    return [super drawTextInRect:UIEdgeInsetsInsetRect(rect, insets)];
}

@end
