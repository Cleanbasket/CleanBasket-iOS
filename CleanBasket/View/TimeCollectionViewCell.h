//
//  TimeCollectionViewCell.h
//  CleanBasket
//
//  Created by 이상진 on 2016. 1. 11..
//  Copyright © 2016년 WashappKorea. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef enum : NSUInteger {
    TimeTypeClose = 0,
    TimeTypeSale,
    TimeTypeSale2,
    TimeTypeNone = 10,
} TimeType;

@interface TimeCollectionViewCell : UICollectionViewCell


//@property (nonatomic) TimeType timeType;
//@property (nonatomic) NSDate *date;

- (void)setTextWithDate:(NSDate*)date;
//- (void)setTimeType:(TimeType)type;
//- (void)setTimeText:(NSString*)timeText;



@end
