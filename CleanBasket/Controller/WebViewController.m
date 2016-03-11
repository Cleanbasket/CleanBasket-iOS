//
//  WebViewController.m
//  CleanBasket
//
//  Created by 이상진 on 2015. 12. 8..
//  Copyright © 2015년 WashappKorea. All rights reserved.
//

#import "WebViewController.h"

@interface WebViewController ()

@end

@implementation WebViewController




- (void)viewDidLoad {
    [super viewDidLoad];
}

- (void)awakeFromNib {

    [self.navigationItem setTitle:NSLocalizedString(@"app_name", nil)];

}


- (void)viewWillAppear:(BOOL)animated {

    [self.navigationController setNavigationBarHidden:NO animated:NO];

    if (_url){
        [_webView loadRequest:[NSURLRequest requestWithURL:_url]];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
