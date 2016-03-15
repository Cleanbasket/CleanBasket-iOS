//
//  UITextField+maxLength.m
//  CleanBasket
//
//  Created by 이상진 on 2016. 1. 8..
//  Copyright © 2016년 WashappKorea. All rights reserved.
//

#import <objc/runtime.h>
#import "UITextField+maxLength.h"

static void *MaxLengthKey;

@implementation UITextField (maxLength)
-(void)setMaxLength:(NSNumber *)maxLength{

    self.delegate = (id <UITextFieldDelegate>) self;

    objc_setAssociatedObject(self, &MaxLengthKey, maxLength, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}
-(NSNumber*)maxLength{
    return objc_getAssociatedObject(self, &MaxLengthKey);
}


- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    BOOL shouldChange = YES;
    
    if(textField.maxLength){
        // Prevent crashing undo bug – see note below.
        if(range.length + range.location > textField.text.length)
        {
            return NO;
        }
        
        NSUInteger newLength = [textField.text length] + [string length] - range.length;
        shouldChange = (newLength > [textField.maxLength integerValue]) ? NO : YES;
        if(!shouldChange){
            return shouldChange;
        }
    }
    return shouldChange;
}



@end
