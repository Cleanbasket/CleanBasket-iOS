//
//  PriceViewController.h
//  CleanBasket
//
//  Created by Wonhyo Yi on 2014. 10. 3..
//  Copyright (c) 2014년 WashAppKorea. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CBConstants.h"
#import "CBLabel.h"
#import "CBTableViewCell.h"

@interface PriceViewController : UIViewController {
    NSArray *itemArray;
    NSArray *priceArray;
    UITableView *priceTableView;
}

@end
