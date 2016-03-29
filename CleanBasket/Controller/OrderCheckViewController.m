//
//  OrderCheckViewController.m
//  CleanBasket
//
//  Created by ChaTheodore on 2016. 3. 24..
//  Copyright © 2016년 WashappKorea. All rights reserved.
//

#import "OrderCheckViewController.h"
#import "OrderViewController.h"

@interface OrderCheckViewController ()

@property (weak, nonatomic) IBOutlet UIButton *cancleButton;
@property (weak, nonatomic) IBOutlet UIButton *orderButton;
@property (weak, nonatomic) IBOutlet UILabel *addressLabel;
@property (weak, nonatomic) IBOutlet UILabel *pickupLabel;
@property (weak, nonatomic) IBOutlet UILabel *dropoffLabel;
@property (weak, nonatomic) IBOutlet UITextField *phoneLabel;
@property (weak, nonatomic) IBOutlet UITextField *memoLabel;

@end

@implementation OrderCheckViewController

@synthesize userAddress;
@synthesize userPickupTime;
@synthesize userDropoffTime;

- (void)viewDidLoad {
    [super viewDidLoad];
    
    
    
    // UI 변경 요소
    
    _cancleButton.layer.borderWidth = 2.0;
    _cancleButton.layer.borderColor = [UIColor whiteColor].CGColor;
    _cancleButton.layer.cornerRadius = 3;
    
    _orderButton.layer.borderWidth = 2.0;
    _orderButton.layer.borderColor = [UIColor whiteColor].CGColor;
    _orderButton.layer.cornerRadius = 3;
    
    _addressLabel.text = userAddress;
    _pickupLabel.text = userPickupTime;
    _dropoffLabel.text = userDropoffTime;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)awakeFromNib{
    
    [self setModalPresentationStyle:UIModalPresentationCustom];
    [self setNeedsStatusBarAppearanceUpdate];
}

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
