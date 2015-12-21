//
// Created by 이상진 on 2015. 12. 8..
// Copyright (c) 2015 WashappKorea. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "TTTAttributedLabel.h"

@interface LoginViewController : UIViewController<TTTAttributedLabelDelegate, UIScrollViewDelegate> {

}

@property (weak, nonatomic) IBOutlet TTTAttributedLabel *privacyLinkLabel;
@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;
@property (weak, nonatomic) IBOutlet UIPageControl *pageControl;

@end