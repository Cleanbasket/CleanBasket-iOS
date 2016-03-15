//
//  AddCreditViewController.m
//  CleanBasket
//
//  Created by 이상진 on 2015. 12. 29..
//  Copyright © 2015년 WashappKorea. All rights reserved.
//

#import "AddCreditViewController.h"
#import "CBConstants.h"
#import <BEMCheckBox/BEMCheckBox.h>
#import <AFNetworking/AFNetworking.h>
#import <SVProgressHUD/SVProgressHUD.h>
#import "RoundedButton.h"

@interface AddCreditViewController ()<BEMCheckBoxDelegate>

@property (weak, nonatomic) IBOutlet UIView *inputView;
@property (weak, nonatomic) IBOutlet BEMCheckBox *checkBox;
@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;
@property (weak, nonatomic) IBOutlet UITextField *cardNumberTF1;
@property (weak, nonatomic) IBOutlet UITextField *cardNumberTF2;
@property (weak, nonatomic) IBOutlet UITextField *cardNumberTF3;
@property (weak, nonatomic) IBOutlet UITextField *cardNumberTF4;
@property (weak, nonatomic) IBOutlet UITextField *expiryMonthTF;
@property (weak, nonatomic) IBOutlet UITextField *expiryYearTF;
@property (weak, nonatomic) IBOutlet UITextField *birthDateTF;
@property (weak, nonatomic) IBOutlet UITextField *passwordTF;
@property (weak, nonatomic) IBOutlet UITextField *cardNicknameTF;
@property (weak, nonatomic) IBOutlet RoundedButton *addCardButton;

@end

@implementation AddCreditViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    [_checkBox setBoxType:BEMBoxTypeSquare];
    [_checkBox setOnAnimationType:BEMAnimationTypeFill];
    [_checkBox setDelegate:self];
    
    [_cardNumberTF1 setMaxLength:@4];
    [_cardNumberTF2 setMaxLength:@4];
    [_cardNumberTF3 setMaxLength:@4];
    [_cardNumberTF4 setMaxLength:@4];
    
    [_expiryMonthTF setMaxLength:@2];
    [_expiryYearTF setMaxLength:@2];
    [_birthDateTF setMaxLength:@6];
    [_passwordTF setMaxLength:@2];



    
    
    
}

- (IBAction)dismissVC:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];

    
}


- (void)didTapCheckBox:(BEMCheckBox*)checkBox{
    if (checkBox.on) {
        [_addCardButton setEnabled:YES];
        [_addCardButton setAlpha:1.0f];
    } else{
        [_addCardButton setEnabled:NO];
        [_addCardButton setAlpha:0.5f];
    }
}

- (IBAction)addCredit:(id)sender {

    if ( (_cardNumberTF1.text.length+_cardNumberTF1.text.length+_cardNumberTF1.text.length+_cardNumberTF1.text.length) < 16){
        [SVProgressHUD showErrorWithStatus:NSLocalizedString(@"input_card_number", nil)];
        return;
    }
    else if (_expiryMonthTF.text.length+_expiryYearTF.text.length < 4){
        [SVProgressHUD showErrorWithStatus:NSLocalizedString(@"input_expiration_day", nil)];
        return;
    }
    else if ( _birthDateTF.text.length < 6){
        [SVProgressHUD showErrorWithStatus:NSLocalizedString(@"input_birthday", nil)];
        return;
    }
    else if (_passwordTF.text.length < 2){
        [SVProgressHUD showErrorWithStatus:NSLocalizedString(@"input_card_password", nil)];
        return;
    }

    [SVProgressHUD show];



    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];

    manager.requestSerializer = [AFJSONRequestSerializer serializer];
    manager.responseSerializer.acceptableContentTypes = [manager.responseSerializer.acceptableContentTypes setByAddingObject:@"text/html"];


    NSDictionary *parameters = @{@"CardNo":[NSString stringWithFormat:@"%@%@%@%@",_cardNumberTF1.text,_cardNumberTF2.text,_cardNumberTF3.text,_cardNumberTF4.text],
                                 @"ExpMonth":_expiryMonthTF.text,
                                 @"ExpYear":_expiryYearTF.text,
                                 @"IDNo":_birthDateTF.text,
                                 @"CardPw":_passwordTF.text
                                 };

    
    
    NSString *urlString = [NSString stringWithFormat:@"%@%@",CB_SERVER_URL,@"member/payment"];
    [manager POST:urlString
      parameters:parameters
         success:^(AFHTTPRequestOperation *operation, id responseObject) {

             if ([responseObject[@"constant"] isEqualToNumber:@1]){
                 [SVProgressHUD showSuccessWithStatus:NSLocalizedString(@"success_card", nil)];

                 [[NSNotificationCenter defaultCenter] postNotificationName:@"didFinishAddCredit" object:nil];

                 [self dismissVC:nil];
             }

             else {
                 [SVProgressHUD showErrorWithStatus:NSLocalizedString(@"fail_card", nil)];
             }


         } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                [SVProgressHUD showErrorWithStatus:NSLocalizedString(@"fail_card", nil)];
            }];;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (IBAction)resignOnTap:(id)sender {
    [self.view endEditing:YES];
}




-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self registNotification];
}

-(void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [self unregistNotification];
}

-(void) registNotification
{
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillShow:)
                                                 name:UIKeyboardWillShowNotification
                                               object:nil];

    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillBeHidden:)
                                                 name:UIKeyboardWillHideNotification
                                               object:nil];
}

-(void) unregistNotification
{
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:UIKeyboardWillShowNotification object:nil];

    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:UIKeyboardWillHideNotification object:nil];
}


- (void)keyboardWillShow:(NSNotification*)aNotification
{
    NSDictionary* info = [aNotification userInfo];
    CGSize kbSize = [[info objectForKey:UIKeyboardFrameBeginUserInfoKey] CGRectValue].size;

    CGRect aRect = self.view.frame;
    aRect.size.height -= kbSize.height;




    [_scrollView setScrollIndicatorInsets:UIEdgeInsetsMake(0, 0, kbSize.height, 0)];
    [_scrollView setContentInset:UIEdgeInsetsMake(0, 0, kbSize.height, 0)];



}

- (void)keyboardWillBeHidden:(NSNotification*)aNotification
{
    
    [_scrollView setScrollIndicatorInsets:UIEdgeInsetsZero];
    [_scrollView setContentInset:UIEdgeInsetsZero];
    [self.scrollView setContentOffset:CGPointZero animated:YES];


}




@end
