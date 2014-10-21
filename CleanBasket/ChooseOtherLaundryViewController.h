//
//  ChooseOtherLaundryViewController.h
//  CleanBasket
//
//  Created by Wonhyo Yi on 2014. 10. 19..
//  Copyright (c) 2014년 WashAppKorea. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Realm/Realm.h>
#import "CBTotalPriceView.h"
#import "CBConstants.h"
#import "CBOrderTableViewCell.h"
#import "Item.h"

@interface ChooseOtherLaundryViewController : UIViewController

@property RLMArray *itemArray;
@property int numberOfMainItems;
@end

