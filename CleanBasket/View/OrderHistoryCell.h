//
//  OrderHistoryCell.h
//  CleanBasket
//
//  Created by 이상진 on 2016. 2. 2..
//  Copyright © 2016년 WashappKorea. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "RoundedLabel.h"

@interface OrderHistoryCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UILabel *orderNumberLabel;
@property (weak, nonatomic) IBOutlet UILabel *orderStatusLabel;
@property (weak, nonatomic) IBOutlet UILabel *pickUpTimeLabel;
@property (weak, nonatomic) IBOutlet UILabel *dropOffTimeLabel;
@property (weak, nonatomic) IBOutlet RoundedLabel *priceLabel;
@property (weak, nonatomic) IBOutlet RoundedLabel *itemLabel;
@property (weak, nonatomic) IBOutlet RoundedLabel *paymentMethodLabel;

@end
