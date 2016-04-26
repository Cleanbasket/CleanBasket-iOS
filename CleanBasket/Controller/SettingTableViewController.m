//
//  SettingTableViewController.m
//  CleanBasket
//
//  Created by 이상진 on 2015. 12. 23..
//  Copyright © 2015년 WashappKorea. All rights reserved.
//

#import "SettingTableViewController.h"
#import <Realm/Realm.h>
#import "User.h"
#import "AppDelegate.h"
#import "ChangePasswordViewController.h"
#import <AFNetworking/AFNetworking.h>
#import "UIAlertView+Blocks.h"
#import "CBConstants.h"

@interface SettingTableViewController ()
@property (weak, nonatomic) IBOutlet UISwitch *eventNotiSwitch;
@property (weak, nonatomic) IBOutlet UISwitch *orderNotiSwitch;

@end

@implementation SettingTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    [self setTitle:NSLocalizedString(@"setting", @"설정")];
    self.tableView.tableFooterView = [UIView new];
    
    [_eventNotiSwitch setOn:[[NSUserDefaults standardUserDefaults] boolForKey:@"isGetEventNoti"]];
    [_orderNotiSwitch setOn:[[NSUserDefaults standardUserDefaults] boolForKey:@"isGetOrderNoti"]];

    [self setNeedsStatusBarAppearanceUpdate];
    
}

- (void)viewWillAppear:(BOOL)animated {
    [self.navigationController setNavigationBarHidden:NO animated:YES];
}

- (IBAction)switchValueChanged:(id)sender {
    
    if (sender == _eventNotiSwitch) {
        [[NSUserDefaults standardUserDefaults] setBool:_eventNotiSwitch.on forKey:@"isGetEventNoti"];
    } else if (sender == _orderNotiSwitch){
        
        [[NSUserDefaults standardUserDefaults] setBool:_orderNotiSwitch.on forKey:@"isGetOrderNoti"];
    }
    
    [[NSUserDefaults standardUserDefaults]synchronize];
    
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {

    switch (section) {
        case 0:
        case 1:
            return 2;
            break;
        default:
            return 0;
            break;
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{

    
    //로그아웃
    if (indexPath.section == 0 && indexPath.row == 1) {
        
        [UIAlertView showWithTitle:NSLocalizedString(@"logout_confirm", nil)
                           message:nil
                 cancelButtonTitle:NSLocalizedString(@"label_cancel", nil)
                 otherButtonTitles:@[NSLocalizedString(@"logout", nil)]
                          tapBlock:^(UIAlertView *alertView, NSInteger buttonIndex){
                              if (buttonIndex == 1) {
                                  [self logout];
                              }
                              
                          }];
        
        
    } else if (indexPath.section == 0 && indexPath.row == 0) {

        UIStoryboard *sb = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
        ChangePasswordViewController *changePasswordViewController = [sb instantiateViewControllerWithIdentifier:@"ChangePwVC"];
        [self presentViewController:changePasswordViewController animated:YES completion:nil];
    }


    [tableView deselectRowAtIndexPath:indexPath animated:YES];

}

- (void)logout{
    
    
    AFHTTPRequestOperationManager *manager =[AFHTTPRequestOperationManager manager];
    
    manager.responseSerializer = [AFJSONResponseSerializer serializer];
    manager.responseSerializer.acceptableContentTypes = [manager.responseSerializer.acceptableContentTypes setByAddingObject:@"text/html"];
    NSString *urlString = [NSString stringWithFormat:@"%@%@",CB_SERVER_URL,@"logout/success"];
    [manager GET:urlString
      parameters:nil
         success:^(AFHTTPRequestOperation *operation, id responseObject) {
             
             if ([responseObject[@"constant"]  isEqual: @1]) {
                 RLMRealm *realm = [RLMRealm defaultRealm];
                 
                 [realm beginWriteTransaction];
                 [realm deleteObjects:[User allObjects]];
                 [realm commitWriteTransaction];
                 
                 AppDelegate *appDelegate = [[UIApplication sharedApplication]delegate];
                 [appDelegate.window setRootViewController:(UIViewController*)appDelegate.loginVC];
                 
             }
             
             
             
             
         } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
             NSLog(@"Error: %@", error);
         }];

}


#pragma mark -
- (UIStatusBarStyle)preferredStatusBarStyle {
    return UIStatusBarStyleLightContent;
}

@end
