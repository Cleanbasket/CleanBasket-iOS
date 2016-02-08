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

@interface SettingTableViewController ()
@property (weak, nonatomic) IBOutlet UILabel *latestVersion;
@property (weak, nonatomic) IBOutlet UISwitch *eventNotiSwitch;
@property (weak, nonatomic) IBOutlet UISwitch *orderNotiSwitch;

@end

@implementation SettingTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    [self setTitle:NSLocalizedString(@"setting", @"설정")];
    self.tableView.tableFooterView = [UIView new];
    
    [self getVersion];
    
    [_eventNotiSwitch setOn:[[NSUserDefaults standardUserDefaults] boolForKey:@"isGetEventNoti"]];
    [_orderNotiSwitch setOn:[[NSUserDefaults standardUserDefaults] boolForKey:@"isGetOrderNoti"]];

    [self setNeedsStatusBarAppearanceUpdate];
    
}

- (void)getVersion{

    AFHTTPRequestOperationManager *manager =[AFHTTPRequestOperationManager manager];

    manager.responseSerializer = [AFJSONResponseSerializer serializer];
    manager.responseSerializer.acceptableContentTypes = [manager.responseSerializer.acceptableContentTypes setByAddingObject:@"text/html"];
    [manager GET:@"http://52.79.39.100:8080/appinfo"
      parameters:nil
            success:^(AFHTTPRequestOperation *operation, id responseObject) {



                NSError *jsonError;
                NSData *objectData = [responseObject[@"data"] dataUsingEncoding:NSUTF8StringEncoding];

                NSDictionary *data = [NSJSONSerialization JSONObjectWithData:objectData
                                                                     options:NSJSONReadingMutableContainers
                                                                       error:&jsonError];

                [_latestVersion setText:[NSString stringWithFormat:@"%@ %@",NSLocalizedString(@"latest_version",nil),data[@"ios_app_ver"]]];



            } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                NSLog(@"Error: %@", error);
            }];
    
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
    return 3;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {

    switch (section) {
        case 0:
        case 1:
            return 2;
            break;
            
        case 2:
            return 3;
        default:
            return 0;
            break;
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{

    
    //로그아웃
    if (indexPath.section == 0 && indexPath.row == 1) {
        
        AFHTTPRequestOperationManager *manager =[AFHTTPRequestOperationManager manager];
        
        manager.responseSerializer = [AFJSONResponseSerializer serializer];
        manager.responseSerializer.acceptableContentTypes = [manager.responseSerializer.acceptableContentTypes setByAddingObject:@"text/html"];
        [manager GET:@"http://52.79.39.100:8080/logout/success"
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
        
        
    } else if (indexPath.section == 0 && indexPath.row == 0) {

        UIStoryboard *sb = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
        ChangePasswordViewController *changePasswordViewController = [sb instantiateViewControllerWithIdentifier:@"ChangePwVC"];
        [self presentViewController:changePasswordViewController animated:YES completion:nil];
    } else if (indexPath.section == 2 && indexPath.row == 2) {
        NSURL *url = [NSURL URLWithString:@"itms-apps://itunes.apple.com/app/id933165319"];
        [[UIApplication sharedApplication] openURL:url];
    }


    [tableView deselectRowAtIndexPath:indexPath animated:YES];

}


- (UIStatusBarStyle)preferredStatusBarStyle {
    return UIStatusBarStyleLightContent;
}

@end
