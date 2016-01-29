//
// Created by 이상진 on 2015. 12. 8..
// Copyright (c) 2015 WashappKorea. All rights reserved.
//

#import "LoginViewController.h"
#import "WebViewController.h"
#import "AppDelegate.h"
#import "CBConstants.h"
#import "SignInViewController.h"
#import <KakaoOpenSDK/KakaoOpenSDK.h>
#import "User.h"
#import <Realm/Realm.h>
#import <AFNetworking/AFNetworking.h>

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


    NSURL *privacyUrl = [NSURL URLWithString:@"http://www.cleanbasket.co.kr/privacy"];
    NSString *privacyString = _privacyLinkLabel.text;
    NSRange privacyRange = [privacyString rangeOfString:@"개인정보 수집 및 이용에 대한 안내"];
    [_privacyLinkLabel addLinkToURL:privacyUrl withRange:privacyRange];


    NSURL *termUrl = [NSURL URLWithString:@"http://www.cleanbasket.co.kr/term-of-use"];
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

- (IBAction)loginWithKakao:(id)sender {
    
    KOSession *session = [KOSession sharedSession];
    
    if (session.isOpen) {
        [session close];
    }
    
    session.presentingViewController = self.navigationController;
    [session openWithCompletionHandler:^(NSError *error) {
        session.presentingViewController = nil;
        NSLog(@"ㅅㅂㄹㅁ!");
        
        if (!session.isOpen) {
            [[[UIAlertView alloc] initWithTitle:@"에러" message:error.description delegate:nil cancelButtonTitle:@"확인" otherButtonTitles:nil, nil] show];
        }
    }];


    
    [[KOSession sharedSession] openWithCompletionHandler:^(NSError *error) {
        if ([[KOSession sharedSession] isOpen]) {
            // login success
            NSLog(@"login succeeded.%@",[KOSession sharedSession]);
            
            UIStoryboard *sb = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
            UIViewController *mainTBC = [sb instantiateViewControllerWithIdentifier:@"MainTBC"];
            
            AppDelegate *appDelegate = [[UIApplication sharedApplication] delegate];
            
            [appDelegate.window setRootViewController:mainTBC];
            
        } else {
            // failed
            NSLog(@"login failed.");
        }
    }];
}




//로그인 체크 메서드
- (void)authCheck{
    
    
    //    RLMRealm *realm = [RLMRealm defaultRealm];
    
    RLMResults<User *> *users = [User allObjects];
    
    //유저 있으면 바로 로그인, 없으면 loginVC로 이동
    if (users.count) {
        
        User *user = [users firstObject];
        
        AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
        
        manager.responseSerializer = [AFJSONResponseSerializer serializer];
        manager.responseSerializer.acceptableContentTypes = [manager.responseSerializer.acceptableContentTypes setByAddingObject:@"text/html"];
        
        NSDictionary *parameters = @{@"email": user.email,
                                     @"password": user.password };
        
        
        [manager POST:@"http://www.cleanbasket.co.kr/auth" parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
            
            
//            NSLog(@"%@",responseObject);
            if ([responseObject[@"constant"] integerValue] != 1){
                
                AppDelegate *appDelegate = [[UIApplication sharedApplication] delegate];
                [appDelegate.window setRootViewController:appDelegate.loginVC];
                
                
            } else {
//                [self playAnimination];
            }
            
            
            
            
        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
            NSLog(@"Error: %@", error);
        }];
    }
    
    else {
        
        AppDelegate *appDelegate = [[UIApplication sharedApplication] delegate];
        [appDelegate.window setRootViewController:appDelegate.loginVC];
        
        
        
    }
    
    
    
    
}




#pragma mark - ScrollviewDelegate
- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView{
    
    CGFloat offsetX = scrollView.contentOffset.x;
    NSInteger currentPage = offsetX/_screenWidth;
    [_pageControl setCurrentPage:currentPage];
    
    //마지막 3번째 페이지 도달하면 페이지컨트롤 숨김
    [_pageControl setHidden:currentPage == 2];
    
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