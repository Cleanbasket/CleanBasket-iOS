//
//  HelpViewController.m
//  CleanBasket
//
//  Created by 이상진 on 2015. 12. 14..
//  Copyright © 2015년 WashappKorea. All rights reserved.
//

#import "HelpViewController.h"
#import <ZDCChat/ZDCChat.h>
#import "RoundedButton.h"

@interface HelpViewController ()

@property (weak, nonatomic) IBOutlet UILabel *callLabel;
@property (weak, nonatomic) IBOutlet UILabel *subLabel;
@property (weak, nonatomic) IBOutlet RoundedButton *titleLabel;

@end

@implementation HelpViewController


- (void)labelTap{
    
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"telprompt://18338543"]];
}

- (void)viewDidLoad {
    [super viewDidLoad];

    [self setTitle:NSLocalizedString(@"menu_label_help", nil)];
    
    _subLabel.text = @"메시지를 남겨주세요. \n 고객행복센터에서 연락을 드립니다.";
    _titleLabel.titleLabel.text = @"1:1 문의";
    _callLabel.userInteractionEnabled = YES;
    UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(labelTap)];
    [_callLabel addGestureRecognizer:tapGesture];
}

- (IBAction)tapLiveChat:(id)sender {
    
    [ZDCChat startChatIn:self.navigationController withConfig:nil];
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
