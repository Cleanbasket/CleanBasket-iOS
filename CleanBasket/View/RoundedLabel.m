//
//  RoundedLabel.m
//  CleanBasket
//
//  Created by 이상진 on 2016. 2. 2..
//  Copyright © 2016년 WashappKorea. All rights reserved.
//

#import "RoundedLabel.h"

@implementation RoundedLabel

//- (void)drawTextInRect:(CGRect)rect{
//    UIEdgeInsets insets = {0, 5, 0, 5};
//    [super drawTextInRect:UIEdgeInsetsInsetRect(rect, insets)];
//}


- (void)drawRect:(CGRect)rect{
    self.textColor = [UIColor whiteColor];
    self.layer.cornerRadius = 5;
    self.clipsToBounds = YES;
    
    UIEdgeInsets insets = {0, 5, 0, 5};
    [super drawTextInRect:UIEdgeInsetsInsetRect(rect, insets)];
}

@end
