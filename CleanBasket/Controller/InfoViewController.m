//
//  InfoViewController.m
//  CleanBasket
//
//  Created by 이상진 on 2015. 12. 22..
//  Copyright © 2015년 WashappKorea. All rights reserved.
//

#import "InfoViewController.h"
#import "ModalViewController.h"
#import "AppDelegate.h"

@interface InfoViewController ()

@end

@implementation InfoViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}



- (IBAction)showClassInfo:(id)sender {


    AppDelegate *delegate = [[UIApplication sharedApplication]delegate];


    if ([UIDevice currentDevice].systemVersion.integerValue >= 7)
        [self setModalPresentationStyle:UIModalPresentationCurrentContext];

    [self presentViewController:delegate.modalVC animated:NO completion:nil];
    
    
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
