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
#import "RoundMint.h"

@interface HelpViewController ()

@property (weak, nonatomic) IBOutlet RoundMint *titleLabel;

@end

@implementation HelpViewController


- (void)labelTap{
    
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"telprompt://18338543"]];
}

- (void)viewDidLoad {
    [super viewDidLoad];

    [self setTitle:NSLocalizedString(@"menu_label_help", nil)];
    
    _titleLabel.titleLabel.text = NSLocalizedString(@"menu_label_help", nil);

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
