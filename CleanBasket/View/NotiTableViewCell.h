//
//  NotiTableViewCell.h
//  CleanBasket
//
//  Created by 이상진 on 2015. 12. 23..
//  Copyright © 2015년 WashappKorea. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface NotiTableViewCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UIImageView *notiImageView;
@property (weak, nonatomic) IBOutlet UILabel *notiTitleLabel;
@property (weak, nonatomic) IBOutlet UILabel *notiDateLabel;



@end
