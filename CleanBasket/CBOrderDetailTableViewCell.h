//
//  CBOrderDetailTableViewCell.h
//  CleanBasket
//
//  Created by Wonhyo Yi on 2014. 10. 21..
//  Copyright (c) 2014년 WashAppKorea. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CBConstants.h"

@interface CBOrderDetailTableViewCell : UITableViewCell
@property UILabel *orderNumberLabel;
@property UILabel *orderNumberValueLabel;

@property UILabel *orderPriceLabel;
@property UILabel *orderPriceValueLabel;

@property UILabel *orderItemsLabel;
@property UILabel *orderItemsValueLabel;

@property UILabel *orderStatusLabel;
@property UILabel *orderStatusValueLabel;

@property UILabel *orderPickupLabel;
@property UILabel *orderPickupValueLabel;

@property UILabel *orderDeliverLabel;
@property UILabel *orderDeliverValueLabel;

@property UIImageView *managerPhotoView;
@property UILabel *managerNameLabel;
@property UILabel *managerNameValueLabel;

@property UIButton *orderCancelButton;
@end
