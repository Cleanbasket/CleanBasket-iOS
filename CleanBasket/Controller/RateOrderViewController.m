//
//  RateOrderViewController.m
//  CleanBasket
//
//  Created by 이상진 on 2015. 12. 29..
//  Copyright © 2015년 WashappKorea. All rights reserved.
//

#import "RateOrderViewController.h"
#import <RateView/RateView.h>
#import "CBConstants.h"

@interface RateOrderViewController ()

@property (weak, nonatomic) IBOutlet RateView *rateView;

@end

@implementation RateOrderViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    _rateView.starSize = 30.0f;
    _rateView.starFillColor = CleanBasketMint;
    _rateView.canRate = YES;
    _rateView.rating = 2.5f;
    _rateView.step = 0.5f;
    // Do any additional setup after loading the view.
}
- (IBAction)confirm:(id)sender {
    
    [self dismissViewControllerAnimated:YES completion:nil];
    
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
