//
//  TermsViewController.h
//  CleanBasket
//
//  Created by Wonhyo Yi on 2014. 10. 22..
//  Copyright (c) 2014년 WashAppKorea. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CBConstants.h"
#import "MBProgressHUD.h"

@interface TermsViewController : UIViewController {
    NSURLRequest *termsRequest;
    NSURLRequest *privacyReqeust;
    UIWebView *webView;
}

@end
