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
@property (weak, nonatomic) IBOutlet UIView *noticeView;

@end

@implementation NoticeViewController


- (void)viewDidLoad {
//    [super viewDidLoad];
    self.title = NSLocalizedString(@"notice_title",@"공지사항");

}



- (void)viewWillAppear:(BOOL)animated {
    [self.navigationController setNavigationBarHidden:NO animated:NO];
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
//    style.animationDuration = 0.2;
//    style.arrowHeight = 1;

    _notices = [NSMutableArray new];

    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.responseSerializer = [AFJSONResponseSerializer serializer];
    manager.responseSerializer.acceptableContentTypes = [manager.responseSerializer.acceptableContentTypes setByAddingObject:@"text/html"];
//    manager.requestSerializer = [AFJSONRequestSerializer serializer];

    [manager GET:@"http://www.cleanbasket.co.kr/notice"
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
//             [self.view addSubview:_accordionView];
             self.view = _accordionView;
//             self.view.backgroundColor = lightBlue;




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

    [SVProgressHUD show];
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        [self loadNotice];
        dispatch_async(dispatch_get_main_queue(), ^{
            [SVProgressHUD dismiss];
        });
    });

}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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
