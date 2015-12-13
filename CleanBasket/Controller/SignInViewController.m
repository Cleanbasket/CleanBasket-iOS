//
//  SignInViewController.m
//  CleanBasket
//
//  Created by 이상진 on 2015. 12. 14..
//  Copyright © 2015년 WashappKorea. All rights reserved.
//

#import "SignInViewController.h"

@interface SignInViewController ()

@end

@implementation SignInViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}


- (void)awakeFromNib {


}


- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {


    UITouch  *touch = [touches anyObject];
    if ([touch view] == self.view){

        NSLog(@"타치");
        [self dismissViewControllerAnimated:NO completion:nil];
    }


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
