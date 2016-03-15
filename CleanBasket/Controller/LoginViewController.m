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
#import <SVProgressHUD/SVProgressHUD.h>
#import "NSString+sha1.h"

@interface LoginViewController()

@property CGFloat screenWidth;

@end

@implementation LoginViewController


- (void)viewDidLoad{
    [super viewDidLoad];

    _scrollView.delegate = self;
    
    //이용약관 링크 라벨
    _privacyLinkLabel.delegate = self;

    _privacyLinkLabel.text = [NSString stringWithFormat:@"%@ %@ %@ %@ %@",
                              NSLocalizedString(@"login_agreement_a", nil),
                              NSLocalizedString(@"Login_agreement_b", nil),
                              NSLocalizedString(@"Login_agreement_c", nil),
                              NSLocalizedString(@"Login_agreement_d", nil),
                              NSLocalizedString(@"Login_agreement_e", nil)];
    
    NSMutableDictionary *mutableActiveLinkAttributes = [NSMutableDictionary dictionary];
    mutableActiveLinkAttributes[(NSString *) kCTUnderlineStyleAttributeName] = @YES;
    mutableActiveLinkAttributes[(NSString *) kCTForegroundColorAttributeName] = CleanBasketMint;
    _privacyLinkLabel.linkAttributes = [NSDictionary dictionaryWithDictionary:mutableActiveLinkAttributes];
    _privacyLinkLabel.activeLinkAttributes = [NSDictionary dictionaryWithDictionary:mutableActiveLinkAttributes];
    _privacyLinkLabel.inactiveLinkAttributes = [NSDictionary dictionaryWithDictionary:mutableActiveLinkAttributes];

    
    NSString *privacyUrlString = [NSString stringWithFormat:@"%@%@",CB_SERVER_URL,@"privacy"];
    NSURL *privacyUrl = [NSURL URLWithString:privacyUrlString];
    NSString *privacyString = _privacyLinkLabel.text;
    NSRange privacyRange = [privacyString rangeOfString:NSLocalizedString(@"Login_agreement_b", @"개인정보 수집 및 이용에 대한 안내")];
    [_privacyLinkLabel addLinkToURL:privacyUrl withRange:privacyRange];

    
    NSString *touUrlString = [NSString stringWithFormat:@"%@%@",CB_SERVER_URL,@"term-of-use"];
    NSURL *termUrl = [NSURL URLWithString:touUrlString];
    NSString *termString = _privacyLinkLabel.text;
    NSRange termRange = [termString rangeOfString:NSLocalizedString(@"Login_agreement_d", @"이용약관")];
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
        
        if (!session.isOpen) {
#warning Need LocalizedString
            [[[UIAlertView alloc] initWithTitle:@"에러" message:error.description delegate:nil cancelButtonTitle:@"확인" otherButtonTitles:nil, nil] show];
        }
        else {
            NSLog(@"login succeeded.%@",[KOSession sharedSession]);
            [KOSessionTask meTaskWithCompletionHandler:^(KOUser* result, NSError *error) {
                if (result) {
                    // success
                    NSString *userIdString = [result.ID stringValue];
                    [SVProgressHUD show];
                    [self login:userIdString password:[userIdString sha1]];
                    
                    
                    
                } else {
                    // failed
                }
            }];

        }
    }];
    

    
}

- (void)goToMainTBC{
    
    UIStoryboard *sb = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    UIViewController *mainTBC = [sb instantiateViewControllerWithIdentifier:@"MainTBC"];
    
    AppDelegate *appDelegate = [[UIApplication sharedApplication] delegate];
    
    [appDelegate.window setRootViewController:mainTBC];

}






#pragma mark - Sign!
- (IBAction)login:(NSString*)userId password:(NSString*)pw {
    
    
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    
    
    
    manager.responseSerializer = [AFJSONResponseSerializer serializer];
    manager.responseSerializer.acceptableContentTypes = [manager.responseSerializer.acceptableContentTypes setByAddingObject:@"text/html"];
    
    NSDictionary *parameters = @{@"email": userId,
                                 @"password": pw};
    
    NSString *urlString = [NSString stringWithFormat:@"%@%@",CB_SERVER_URL,@"auth"];
    [manager POST:urlString
       parameters:parameters
          success:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        
        NSNumber *value = responseObject[@"constant"];
        switch ([value integerValue]) {
                // 회원정보 일치: 로그인 성공
            case CBServerConstantSuccess:
            {
                
                
                NSError *jsonError;
                NSData *objectData = [responseObject[@"data"] dataUsingEncoding:NSUTF8StringEncoding];
                NSDictionary *data = [NSJSONSerialization JSONObjectWithData:objectData
                                                                     options:NSJSONReadingMutableContainers
                                                                       error:&jsonError];
                
                
                
                RLMRealm *realm = [RLMRealm defaultRealm];
                User *user = [[User alloc] initWithValue:@{@"email": userId,
                                                           @"password": pw,
                                                           @"uid":data[@"uid"]}];
                
                [realm beginWriteTransaction];
                [realm deleteObjects:[User allObjects]];
                [realm addObject:user];
                [realm commitWriteTransaction];
                
                
                UIStoryboard *sb = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
                UIViewController *mainTBC = [sb instantiateViewControllerWithIdentifier:@"MainTBC"];
                AppDelegate *appDelegate = [[UIApplication sharedApplication] delegate];
                [appDelegate.window setRootViewController:mainTBC];
                
                break;
            }
                // 이메일 주소 없음
            case CBServerConstantEmailError:
            {
                dispatch_async(dispatch_get_main_queue(), ^{
                    [self signUp:userId password:pw];
                });
                break;
            }
                // 이메일 주소에 대한 비밀번호 다름
            case CBServerConstantPasswordError:
            {
                dispatch_async(dispatch_get_main_queue(), ^{
                    [self signUp:userId password:pw];
                });
                break;
            }
                // 정지 계정
            case CBServerConstantAccountDisabled :
            {
                dispatch_async(dispatch_get_main_queue(), ^{
                    #warning Need Localized
                    [SVProgressHUD showErrorWithStatus:@"해당 계정은 사용하실 수 없습니다."];
                });
                break;
            }
        }
        
        
        
        
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"Error: %@", error);
    }];
}


- (IBAction)signUp:(NSString*)userId password:(NSString*)pw {
    
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    
    manager.requestSerializer = [AFJSONRequestSerializer serializer];
    
    manager.responseSerializer = [AFJSONResponseSerializer serializer];
    manager.responseSerializer.acceptableContentTypes = [manager.responseSerializer.acceptableContentTypes setByAddingObject:@"text/html"];
    
    
    NSDictionary *parameters = @{@"email":userId ,@"password":pw};
    
    NSString *urlString = [NSString stringWithFormat:@"%@%@",CB_SERVER_URL,@"member/register"];
    [manager POST:urlString
       parameters:parameters
          success:^(AFHTTPRequestOperation *operation, id responseObject) {
              
              
              NSNumber *value = responseObject[@"constant"];
              switch ([value integerValue]) {
                  case CBServerConstantSuccess:
                  {
                      
                      [SVProgressHUD showSuccessWithStatus:NSLocalizedString(@"sign_up_success",nil)];
                      
                      [self login:userId password:pw];
                      
                  }
                      break;
                  case CBServerConstantsAccountDuplication:
                  {
                      [SVProgressHUD showErrorWithStatus:NSLocalizedString(@"email_duplication",nil)];
                      break;
                  }
              }
          } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
              [SVProgressHUD showErrorWithStatus:NSLocalizedString(@"network_error",nil)];
              NSLog(@"%@",error);
          }];
    
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