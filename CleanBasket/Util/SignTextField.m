//
//  SignTextField.m
//  CleanBasket
//
//  Created by 이상진 on 2015. 12. 14..
//  Copyright © 2015년 WashappKorea. All rights reserved.
//

#import "SignTextField.h"

@implementation SignTextField





// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
    [self setValue:[UIColor lightGrayColor] forKeyPath:@"_placeholderLabel.textColor"];
    [self setValue:[UIColor lightGrayColor] forKeyPath:@"_clearButton.textColor"];

    CALayer *border = [CALayer layer];
    CGFloat borderWidth = 1;
    border.borderColor = [UIColor lightGrayColor].CGColor;
    border.frame = CGRectMake(0, self.frame.size.height - borderWidth, self.frame.size.width, self.frame.size.height);
    border.borderWidth = borderWidth;
    [self.layer addSublayer:border];
    self.layer.masksToBounds = YES;

}


@end
