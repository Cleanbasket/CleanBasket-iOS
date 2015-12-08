//
//  WebViewController.h
//  CleanBasket
//
//  Created by 이상진 on 2015. 12. 8..
//  Copyright © 2015년 WashappKorea. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface WebViewController : UIViewController
@property (weak, nonatomic) IBOutlet UIWebView *webView;
@property NSURL *url;

@end
