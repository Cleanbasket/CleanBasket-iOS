//
//  ModalViewController.m
//  CleanBasket
//
//  Created by 이상진 on 2015. 12. 22..
//  Copyright © 2015년 WashappKorea. All rights reserved.
//

#import "ModalViewController.h"

@interface ModalViewController ()

@end

@implementation ModalViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}



- (void)awakeFromNib{
    
    [self setModalPresentationStyle:UIModalPresentationCustom];
    [self setNeedsStatusBarAppearanceUpdate];
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/




- (UIStatusBarStyle)preferredStatusBarStyle{
    return UIStatusBarStyleLightContent;
}

- (IBAction)close:(id)sender {
    [self dismissViewControllerAnimated:NO completion:nil];
}



// 배경 터치하면 취소
- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    
    UITouch  *touch = [touches anyObject];
    if ([touch view] == self.view){
        [self dismissViewControllerAnimated:YES completion:nil];
    }
    
    
}

@end
