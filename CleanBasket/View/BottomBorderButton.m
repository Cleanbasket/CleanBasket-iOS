//
//  BottomBorderButton.m
//  CleanBasket
//
//  Created by 이상진 on 2015. 12. 22..
//  Copyright © 2015년 WashappKorea. All rights reserved.
//

#import "BottomBorderButton.h"

@implementation BottomBorderButton

- (void)drawRect:(CGRect)rect {
//    CALayer *border = [CALayer layer];
//    CGFloat borderWidth = 1;
//    border.borderColor = [UIColor lightGrayColor].CGColor;
//    border.frame = CGRectMake(0, self.frame.size.height - borderWidth, self.frame.size.width, self.frame.size.height);
//    border.borderWidth = borderWidth;
//    [self.layer addSublayer:border];
    
    CALayer *topBorder = [CALayer layer];
    
    CGFloat borderWidth = 0.5;
    topBorder.borderColor = [UIColor lightGrayColor].CGColor;
    topBorder.frame = CGRectMake(0, 0, self.frame.size.width, self.frame.size.height);
    topBorder.borderWidth = borderWidth;
    [self.layer addSublayer:topBorder];
    
    self.layer.masksToBounds = YES;
    
    
}


@end
