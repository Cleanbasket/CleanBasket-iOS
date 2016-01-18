//
//  TimeSelectViewController.h
//  CleanBasket
//
//  Created by 이상진 on 2016. 1. 12..
//  Copyright © 2016년 WashappKorea. All rights reserved.
//

#import <GUITabPagerViewController/GUITabPagerViewController.h>

typedef NS_ENUM(NSUInteger, CBTimeSelectType) {
    CBTimeSelectTypePickUp = 1,
    CBTimeSelectTypeDropOff
};

@interface TimeSelectViewController : GUITabPagerViewController



@property CBTimeSelectType timeSelectType;
@property NSInteger defaultInterval;


@end
