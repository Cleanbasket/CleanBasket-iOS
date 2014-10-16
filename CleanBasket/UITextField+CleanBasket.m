//
//  UITextField+CleanBasket.m
//  CleanBasket
//
//  Created by Wonhyo Yi on 2014. 10. 13..
//  Copyright (c) 2014년 WashAppKorea. All rights reserved.
//

#import "UITextField+CleanBasket.h"

@implementation UITextField (CleanBasket)

+ (UITextField*) initWithCBTextField:(id)caller {
    UITextField *textField = [UITextField new];
    [textField setDelegate:caller];
    [textField setBackgroundColor:UltraLightGray];
    [textField setTextColor:[UIColor blackColor]];
    [textField setBorderStyle:UITextBorderStyleNone];
    [textField setTextAlignment:NSTextAlignmentLeft];
    [textField setClearButtonMode:UITextFieldViewModeWhileEditing];
    [textField setAutocapitalizationType:UITextAutocapitalizationTypeNone];
    [textField setAutocorrectionType:UITextAutocorrectionTypeNo];
    [textField.layer setCornerRadius:15.0f];
    UIView *paddingView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 10, 20)];
    [textField setLeftView:paddingView];
    [textField setLeftViewMode:UITextFieldViewModeAlways];
    
    return textField;
}

@end
