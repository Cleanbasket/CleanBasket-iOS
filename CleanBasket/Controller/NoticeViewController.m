//
//  NoticeViewController.m
//  CleanBasket
//
//  Created by 이상진 on 2015. 12. 26..
//  Copyright © 2015년 WashappKorea. All rights reserved.
//

#import <ODSAccordionView/ODSAccordionView.h>
#import <ODSAccordionView/ODSAccordionSectionStyle.h>
#import <AFNetworking/AFNetworking.h>
#import <SVProgressHUD/SVProgressHUD.h>
#import "NoticeViewController.h"
#import "CBConstants.h"


@interface NoticeViewController ()

@property (nonatomic) NSMutableArray *notices;
@property (nonatomic) ODSAccordionView *accordionView;

@end

@implementation NoticeViewController


- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = NSLocalizedString(@"notice_title",@"공지사항");

    [self setNeedsStatusBarAppearanceUpdate];
    
    [self.view setBackgroundColor:[UIColor whiteColor]];
    
}



- (void)viewWillAppear:(BOOL)animated {
}


- (void)loadNotice {

    ODSAccordionSectionStyle *style = [[ODSAccordionSectionStyle alloc] init];
    style.arrowColor = CleanBasketMint;
    style.headerStyle = ODSAccordionHeaderStyleLabelLeft;
    style.headerTitleLabelFont = [UIFont systemFontOfSize:13];
    style.backgroundColor = [UIColor whiteColor];
    style.headerBackgroundColor = [UIColor whiteColor];
    style.dividerColor = [UIColor lightGrayColor];
    style.headerHeight = 50;
    style.stickyHeaders = YES;

    _notices = [NSMutableArray new];

    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.responseSerializer = [AFJSONResponseSerializer serializer];
    manager.responseSerializer.acceptableContentTypes = [manager.responseSerializer.acceptableContentTypes setByAddingObject:@"text/html"];
    
    NSString *urlString = [NSString stringWithFormat:@"%@%@",CB_SERVER_URL,@"notice"];
    [manager GET:urlString
      parameters:nil
         success:^(AFHTTPRequestOperation *operation, id responseObject) {


             NSError *jsonError;
             NSData *objectData = [responseObject[@"data"] dataUsingEncoding:NSUTF8StringEncoding];
             NSArray *notices = [NSJSONSerialization JSONObjectWithData:objectData
                                                                options:NSJSONReadingMutableContainers
                                                                  error:&jsonError];


             for (NSDictionary *notice in notices){
                 [_notices addObject:[[ODSAccordionSection alloc] initWithTitle:notice[@"title"]
                                                                        andView: [self textView:notice[@"content"]]]];


             }




             _accordionView = [[ODSAccordionView alloc] initWithSections:_notices andSectionStyle:style];
             _accordionView.keyboardDismissMode = UIScrollViewKeyboardDismissModeOnDrag;
             self.view = _accordionView;
             self.view.backgroundColor = [UIColor whiteColor];
             [SVProgressHUD dismiss];


         } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                NSLog(@"Error: %@", error);
            }];
}


-(UITextView *)textView:(NSString *)content {
    UITextView *textView = [[UITextView alloc] init];
    textView.frame = CGRectMake(0, 0, 0, 100);
    textView.backgroundColor = [UIColor clearColor];
    textView.font = [UIFont systemFontOfSize:11];
    textView.text = content;
    textView.editable = NO;
    return textView;
    
}



-(void)viewDidAppear:(BOOL)animated {
    
    [self.navigationController setNavigationBarHidden:NO animated:NO];
    
    [SVProgressHUD setDefaultMaskType:SVProgressHUDMaskTypeBlack];
    [SVProgressHUD show];
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        [self loadNotice];
//        dispatch_async(dispatch_get_main_queue(), ^{
//            [SVProgressHUD dismiss];
//        });
    });

}

- (void)viewWillDisappear:(BOOL)animated {
    [SVProgressHUD dismiss];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (UIStatusBarStyle)preferredStatusBarStyle {
    return UIStatusBarStyleLightContent;
}
/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
