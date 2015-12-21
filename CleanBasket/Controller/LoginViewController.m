//
// Created by 이상진 on 2015. 12. 8..
// Copyright (c) 2015 WashappKorea. All rights reserved.
//

#import "LoginViewController.h"
#import "WebViewController.h"
#import "AppDelegate.h"
#import "CBConstants.h"
#import "SignInViewController.h"

@interface LoginViewController()

@property CGFloat screenWidth;

@end

@implementation LoginViewController


- (void)viewDidLoad{
    [super viewDidLoad];

    _scrollView.delegate = self;
    
    //이용약관 링크 라벨
    _privacyLinkLabel.delegate = self;

    NSMutableDictionary *mutableActiveLinkAttributes = [NSMutableDictionary dictionary];
    mutableActiveLinkAttributes[(NSString *) kCTUnderlineStyleAttributeName] = @YES;
    mutableActiveLinkAttributes[(NSString *) kCTForegroundColorAttributeName] = CleanBasketMint;
    _privacyLinkLabel.linkAttributes = [NSDictionary dictionaryWithDictionary:mutableActiveLinkAttributes];
    _privacyLinkLabel.activeLinkAttributes = [NSDictionary dictionaryWithDictionary:mutableActiveLinkAttributes];
    _privacyLinkLabel.inactiveLinkAttributes = [NSDictionary dictionaryWithDictionary:mutableActiveLinkAttributes];


    NSURL *privacyUrl = [NSURL URLWithString:@"https://www.cleanbasket.co.kr/privacy"];
    NSString *privacyString = _privacyLinkLabel.text;
    NSRange privacyRange = [privacyString rangeOfString:@"개인정보 수집 및 이용에 대한 안내"];
    [_privacyLinkLabel addLinkToURL:privacyUrl withRange:privacyRange];


    NSURL *termUrl = [NSURL URLWithString:@"https://www.cleanbasket.co.kr/term-of-use"];
    NSString *termString = _privacyLinkLabel.text;
    NSRange termRange = [termString rangeOfString:@"이용약관"];
    [_privacyLinkLabel addLinkToURL:termUrl withRange:termRange];
    
    
}


- (void)awakeFromNib{
    
    self.automaticallyAdjustsScrollViewInsets = NO;
}

- (void)viewDidLayoutSubviews{
    
    _screenWidth = _scrollView.frame.size.width;
    [_scrollView setContentSize:CGSizeMake(_screenWidth*3, _scrollView.frame.size.height)];

}



- (void)viewWillAppear:(BOOL)animated {

    [self.navigationController setNavigationBarHidden:YES animated:NO];
}

- (IBAction)loginWithEmail:(id)sender {
    
    
    UIStoryboard *sb = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    SignInViewController *signInViewController = [sb instantiateViewControllerWithIdentifier:@"SignInVC"];

    if ([UIDevice currentDevice].systemVersion.integerValue >= 7)
        [self setModalPresentationStyle:UIModalPresentationCurrentContext];

    [self presentViewController:signInViewController animated:YES completion:nil];


}


#pragma mark - ScrollviewDelegate
- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView{
    
    CGFloat offsetX = scrollView.contentOffset.x;
    NSInteger currentPage = offsetX/_screenWidth;
    [_pageControl setCurrentPage:currentPage];
    
    //마지막 3번째 페이지 도달하면 페이지컨트롤 숨김
    if (currentPage == 2) {
        [_pageControl setHidden:YES];
    } else {
        [_pageControl setHidden:NO];
    }
    
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