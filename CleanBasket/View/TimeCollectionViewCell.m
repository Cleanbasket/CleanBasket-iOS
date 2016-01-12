//
//  TimeCollectionViewCell.m
//  CleanBasket
//
//  Created by 이상진 on 2016. 1. 11..
//  Copyright © 2016년 WashappKorea. All rights reserved.
//

#import "TimeCollectionViewCell.h"

@interface TimeCollectionViewCell()

@property (weak, nonatomic) IBOutlet UILabel *timeLabel;
@property (weak, nonatomic) IBOutlet UILabel *closeLabel;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *saleWidth;

@end

@implementation TimeCollectionViewCell


- (void)awakeFromNib{
//    NSLog(@"!!");
}

- (void)setTimeType:(TimeType)type{
    _timeType = type;
    
    switch (_timeType) {
        case TimeTypeClose:
            [_closeLabel setHidden:NO];
            break;
        case TimeTypeSale:
        case TimeTypeSale2:
//            [_closeLabel setHidden:YES];
            [_saleWidth setConstant:40.0f];
            break;
            
        default:
            [_closeLabel setHidden:YES];
            [_saleWidth setConstant:00.0f];
//            NSLog(@"bb");
            break;
    }
    
    [self layoutIfNeeded];
    
}


- (void)setTimeText:(NSString*)timeText{
    [_timeLabel setText:timeText];
}


@end
