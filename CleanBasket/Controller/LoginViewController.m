//
// Created by 이상진 on 2015. 12. 8..
// Copyright (c) 2015 WashappKorea. All rights reserved.
//

#import "LoginViewController.h"
#import "WebViewController.h"
#import "AppDelegate.h"
#import "CBConstants.h"
#import "SignInViewController.h"

@implementation LoginViewController

- (void)viewDidLoad{
    [super viewDidLoad];



    //이용약관 링크 라벨
    _privacyLinkLabel.delegate = self;

    NSMutableDictionary *mutableActiveLinkAttributes = [NSMutableDictionary dictionary];
    mutableActiveLinkAttributes[(NSString *) kCTUnderlineStyleAttributeName] = @YES;
    mutableActiveLinkAttributes[(NSString *) kCTForegroundColorAttributeName] = CleanBasketMint;
    _privacyLinkLabel.linkAttributes = [NSDictionary dictionaryWithDictionary:mutableActiveLinkAttributes];
    _privacyLinkLabel.activeLinkAttributes = [NSDictionary dictionaryWithDictionary:mutableActiveLinkAttributes];
    _privacyLinkLabel.inactiveLinkAttributes = [NSDictionary dictionaryWithDictionary:mutableActiveLinkAttributes];


//    _privacyLinkLabel.linkAttributes = linkAttr;
//    _privacyLinkLabel.activeLinkAttributes = linkAttr;
//    _privacyLinkLabel.inactiveLinkAttributes = linkAttr;

    NSURL *privacyUrl = [NSURL URLWithString:@"https://www.cleanbasket.co.kr/privacy"];
    NSString *privacyString = _privacyLinkLabel.text;
    NSRange privacyRange = [privacyString rangeOfString:@"개인정보 수집 및 이용에 대한 안내"];
    [_privacyLinkLabel addLinkToURL:privacyUrl withRange:privacyRange];


    NSURL *termUrl = [NSURL URLWithString:@"https://www.cleanbasket.co.kr/term-of-use"];
    NSString *termString = _privacyLinkLabel.text;
    NSRange termRange = [termString rangeOfString:@"이용약관"];
    [_privacyLinkLabel addLinkToURL:termUrl withRange:termRange];
    
    
}

- (void)viewWillAppear:(BOOL)animated {

    [self.navigationController setNavigationBarHidden:YES animated:NO];
}

- (IBAction)loginWithEmail:(id)sender {
    
    
    UIStoryboard *sb = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    SignInViewController *signInViewController = [sb instantiateViewControllerWithIdentifier:@"SignInVC"];

    [self presentViewController:signInViewController animated:NO completion:nil];
//
//    UIView *overlayView = [[UIView alloc] initWithFrame:self.view.frame];
//
//    overlayView.backgroundColor = [UIColor blackColor];
//    overlayView.alpha = 0.5f;
//
//    [self.view addSubview:overlayView];

}


#pragma mark - TTTAttributedLabelDelegate

- (void)attributedLabel:(__unused TTTAttributedLabel *)label
   didSelectLinkWithURL:(NSURL *)url {


    AppDelegate *appDelegate = [[UIApplication sharedApplication] delegate];
    WebViewController *webViewController = appDelegate.webVC;

    webViewController.url = url;

    [self.navigationController pushViewController:webViewController animated:YES];

}



- (void)didReceiveMemoryWarning{
    [super didReceiveMemoryWarning];
    
}


@end