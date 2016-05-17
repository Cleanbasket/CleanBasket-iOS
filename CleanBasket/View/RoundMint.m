//
//  RoundMint.m
//  CleanBasket
//
//  Created by ChaTheodore on 2016. 5. 12..
//  Copyright © 2016년 WashappKorea. All rights reserved.
//

#import "RoundMint.h"

@implementation RoundMint

// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
    
    self.layer.cornerRadius = 5;
    self.layer.borderWidth = 1;
    self.layer.borderColor = [UIColor whiteColor].CGColor;
    [self setClipsToBounds:YES];
    
}


@end
