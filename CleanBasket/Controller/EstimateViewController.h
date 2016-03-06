//
//  EstimateViewController.h
//  CleanBasket
//
//  Created by 이상진 on 2016. 1. 5..
//  Copyright © 2016년 WashappKorea. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface EstimateViewController : UIViewController<UITableViewDelegate,UITableViewDataSource,UICollectionViewDataSource,UICollectionViewDelegate,UIScrollViewDelegate>

@property (nonatomic) BOOL isEditMode;

@end
