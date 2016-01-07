//
//  AuthCheckViewController.m
//  CleanBasket
//
//  Created by 이상진 on 2015. 12. 7..
//  Copyright © 2015년 WashappKorea. All rights reserved.
//

#import "AuthCheckViewController.h"
#import "LoginViewController.h"
#import "AppDelegate.h"
#import <AFNetworking/AFNetworking.h>
#import <Realm/Realm.h>
#import "User.h"


@interface AuthCheckViewController ()
@property (weak, nonatomic) IBOutlet UIImageView *logoImageView;
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UILabel *descLabel;

@end

@implementation AuthCheckViewController


- (void)viewDidLoad {
//    [self init];
    [super viewDidLoad];

    [self authCheck];


    

}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
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
        
        [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
        
        [manager POST:@"http://www.cleanbasket.co.kr/auth" parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
            
            [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
            [UIView animateWithDuration:0.5f
                                  delay:0.3f
                                options:UIViewAnimationOptionCurveEaseInOut
                             animations:^{
                                 [_logoImageView setAlpha:0.0f];
                                 
                             }
                             completion:^(BOOL finished){
                                 

                                 
                                 UIStoryboard *sb = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
                                 UIViewController *mainTBC = [sb instantiateViewControllerWithIdentifier:@"MainTBC"];
                                 AppDelegate *appDelegate = [[UIApplication sharedApplication] delegate];
                                 [appDelegate.window setRootViewController:mainTBC];

            
            }];
 
            [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
            [UIView animateWithDuration:0.5f
                                  delay:0.0f
                                options:UIViewAnimationOptionCurveEaseInOut
                             animations:^{
                                 CGRect frame = _titleLabel.frame;
                                 frame.origin.y += frame.size.height;
                                 [_titleLabel setFrame:frame];
                                 
                             }
                             completion:^(BOOL finished){
                                 
                                 
                             }];
            [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
            [UIView animateWithDuration:0.5f
                                  delay:0.15f
                                options:UIViewAnimationOptionCurveEaseInOut
                             animations:^{
                                 
                                 CGRect frame = _descLabel.frame;
                                 frame.origin.y = 370.0f;
                                 [_descLabel setFrame:frame];
                                 
                             }
                             completion:^(BOOL finished){
                                 
                                 
                             }];
            
            
            
            
            
        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
            [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
            NSLog(@"Error: %@", error);
        }];
    }
    
    else {
        
        AppDelegate *appDelegate = [[UIApplication sharedApplication] delegate];
        [appDelegate.window setRootViewController:appDelegate.loginVC];

        
        
    }




}


@end
