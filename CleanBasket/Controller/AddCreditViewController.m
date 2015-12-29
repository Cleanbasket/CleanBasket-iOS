//
//  AddCreditViewController.m
//  CleanBasket
//
//  Created by 이상진 on 2015. 12. 29..
//  Copyright © 2015년 WashappKorea. All rights reserved.
//

#import "AddCreditViewController.h"

@interface AddCreditViewController ()

@end

@implementation AddCreditViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (IBAction)addCredit:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
    
    UITouch  *touch = [touches anyObject];
    if ([touch view] == self.view){
        [self.view endEditing:YES];
    }
    
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
