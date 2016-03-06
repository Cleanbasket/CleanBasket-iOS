//
//  TimeSelectCollectionViewController.h
//  CleanBasket
//
//  Created by 이상진 on 2016. 1. 11..
//  Copyright © 2016년 WashappKorea. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TimeSelectViewController.h"

@class OrderStatusViewController;

@interface TimeSelectCollectionViewController : UICollectionViewController<UICollectionViewDelegate,UICollectionViewDataSource,UICollectionViewDelegateFlowLayout>


@property (nonatomic) NSDate *startDate;
@property (nonatomic) OrderStatusViewController *orderStatusViewController;

- (void)initWithDayInterval:(NSInteger)interval andType:(CBTimeSelectType)type;

@end
