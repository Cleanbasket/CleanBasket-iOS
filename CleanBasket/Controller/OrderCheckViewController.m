//
//  OrderCheckViewController.m
//  CleanBasket
//
//  Created by ChaTheodore on 2016. 3. 24..
//  Copyright © 2016년 WashappKorea. All rights reserved.
//

#import "OrderCheckViewController.h"
#import "OrderViewController.h"
#import "UIAlertView+Blocks.h"
#define kOFFSET_FOR_KEYBOARD 100.0
#define SCREEN_UP 1
#define SCREEN_DOWN 0
@interface OrderCheckViewController ()

@property (weak, nonatomic) IBOutlet UIButton *cancleButton;
@property (weak, nonatomic) IBOutlet UIButton *orderButton;
@property (weak, nonatomic) IBOutlet UILabel *addressLabel;
@property (weak, nonatomic) IBOutlet UILabel *pickupLabel;
@property (weak, nonatomic) IBOutlet UILabel *dropoffLabel;
@property (weak, nonatomic) IBOutlet UITextField *phoneLabel;
@property (weak, nonatomic) IBOutlet UITextField *memoLabel;
@property (strong, nonatomic) IBOutlet UIView *scrollView;

@end

@implementation OrderCheckViewController

@synthesize userAddress;
@synthesize userPickupTime;
@synthesize userDropoffTime;
@synthesize userPhoneNumber;
@synthesize memo;

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
    
    if([[NSUserDefaults standardUserDefaults] stringForKey:@"phone"] != nil){
        _phoneLabel.text = [[NSUserDefaults standardUserDefaults] stringForKey:@"phone"];
    }
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

- (IBAction)phoneBegin:(id)sender {
    
    if([_phoneLabel.text isEqual: @"연락처를 입력해주세요."]){
        _phoneLabel.text = @"";
    }

    [_phoneLabel setTextColor:[UIColor whiteColor]];
}

- (IBAction)memoBegin:(id)sender {
    _memoLabel.text = @"";
    [_memoLabel setTextColor:[UIColor whiteColor]];
    isMemo = YES;
    [self moveScreen:SCREEN_UP];
}

- (IBAction)memoEnd:(id)sender {
    [self moveScreen:SCREEN_DOWN];
}

-(void) addOrderEvent{
    [self.delegate addOrderEvent];
}


#pragma mark - delegate
- (void) getPhoneData:(NSString*) phoneData
{
    [self.delegate getPhoneData:phoneData];
}

#pragma mark - delegate
- (void) getMemoData:(NSString*) memoData
{
    [self.delegate getMemoData:memoData];
}

// 배경 터치하면 취소
- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    
//    UITouch  *touch = [touches anyObject];
//    if ([touch view] == self.view){
//        [self dismissViewControllerAnimated:YES completion:nil];
//    }
    [self.view endEditing:YES];
}

- (IBAction)orderSuccessTouch:(id)sender {
    
    NSString *phoneRegex = @"([0-9]{9,11})?";
    NSPredicate *range_phone = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", phoneRegex];
    BOOL matches = [range_phone evaluateWithObject:_phoneLabel.text];
    
    
    if([_phoneLabel.text isEqual: @"연락처를 입력해주세요."]){
        [[[UIAlertView alloc]
          initWithTitle:@"연락처 입력"
          message:@"입력란에 연락처를 입력해주세요." delegate:self
          cancelButtonTitle:@"Ok" otherButtonTitles:nil] show];
        return;
    }else if([_phoneLabel.text isEqual: @""]){
        [[[UIAlertView alloc]
          initWithTitle:@"연락처 입력"
          message:@"입력란에 연락처를 입력해주세요." delegate:self
          cancelButtonTitle:@"Ok" otherButtonTitles:nil] show];
        return;
    }else if(!matches){
        [[[UIAlertView alloc]
          initWithTitle:@"유효하지 않은 번호"
          message:@"유효하지 않은 전화번호입니다. 입력하신 전화번호를 다시 한 번 확인해주세요." delegate:self
          cancelButtonTitle:@"Ok" otherButtonTitles:nil] show];
        return;
    }
    
    userPhoneNumber = _phoneLabel.text;
    memo = _memoLabel.text;
    
    [[NSUserDefaults standardUserDefaults] setValue :userPhoneNumber forKey:@"phone"];
    [[NSUserDefaults standardUserDefaults] synchronize];
    
    [self getPhoneData:userPhoneNumber];
    [self getMemoData:memo];
    [self addOrderEvent];
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)moveScreen:(BOOL)upOrDown{
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationDuration:0];
    
    CGRect rect = self.view.frame;
    if(upOrDown){
        rect.origin.y -= kOFFSET_FOR_KEYBOARD;
        rect.size.height += kOFFSET_FOR_KEYBOARD;
    }
    else{
        rect.origin.y += kOFFSET_FOR_KEYBOARD;
        rect.size.height -= kOFFSET_FOR_KEYBOARD;
    }
    self.view.frame = rect;
    [UIView commitAnimations];
}


@end
