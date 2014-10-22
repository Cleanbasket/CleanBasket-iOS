//
//  TermsViewController.m
//  CleanBasket
//
//  Created by Wonhyo Yi on 2014. 10. 22..
//  Copyright (c) 2014년 WashAppKorea. All rights reserved.
//

#import "TermsViewController.h"

@interface TermsViewController () <UIWebViewDelegate>

@end

@implementation TermsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setTitle:@"약관"];
    [self.view setBackgroundColor:[UIColor whiteColor]];
    webView = [[UIWebView alloc] initWithFrame:CGRectMake(0, 64+38, DEVICE_WIDTH, DEVICE_HEIGHT-64)];
    
    UISegmentedControl *termsSegment = [[UISegmentedControl alloc] initWithItems:@[@"이용약관", @"개인정보 취급방침"]];
    [termsSegment setFrame:CGRectMake(0, 64, DEVICE_WIDTH, 38)];
    [termsSegment setTintColor:CleanBasketMint];
    [termsSegment setSelectedSegmentIndex:0];
    [termsSegment.layer setCornerRadius:0.0f];
    [termsSegment addTarget:self action:@selector(termsSegementChanged:) forControlEvents:UIControlEventValueChanged];
    
    NSURL *termsURL = [[NSURL alloc] initWithString:@"http://www.cleanbasket.co.kr/term-of-use"];
    NSURL *privacyURL = [[NSURL alloc] initWithString:@"http://www.cleanbasket.co.kr/privacy"];
    termsRequest = [NSURLRequest requestWithURL:termsURL];
    privacyReqeust = [NSURLRequest requestWithURL:privacyURL];
    
    [self.view addSubview: termsSegment];
    [self.view addSubview:webView];
    [webView loadRequest:termsRequest];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void) termsSegementChanged:(id)sender {
    UISegmentedControl *segment = (UISegmentedControl*)sender;
    switch ([segment selectedSegmentIndex]) {
        case 0:
            [webView loadRequest:termsRequest];
            break;
        case 1:
            [webView loadRequest:privacyReqeust];
            break;
            
        default:
            break;
    }
}

- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error {
    [self showHudMessage:@"인터넷 연결 상태를 확인해주세요!"];
}

- (void) showHudMessage:(NSString*)message {
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.navigationController.view animated:YES labelText:nil];
    
    // Configure for text only and offset down
    hud.mode = MBProgressHUDModeText;
    hud.labelText = message;
    [hud setLabelFont:[UIFont systemFontOfSize:14.0f]];
    hud.margin = 10.f;
    hud.removeFromSuperViewOnHide = YES;
    [hud hide:YES afterDelay:1];
    return;
}

@end
