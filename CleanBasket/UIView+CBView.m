//
//  UIView+CBView.m
//  CleanBasket
//
//  Created by Wonhyo Yi on 2014. 10. 23..
//  Copyright (c) 2014년 WashAppKorea. All rights reserved.
//

#import "UIView+CBView.h"

@implementation UIView (CBView)
- (UIView *)findSuperViewWithClass:(Class)superViewClass {
    
    UIView *superView = self.superview;
    UIView *foundSuperView = nil;
    
    while (nil != superView && nil == foundSuperView) {
        if ([superView isKindOfClass:superViewClass]) {
            foundSuperView = superView;
        } else {
            superView = superView.superview;
        }
    }
    return foundSuperView;
}
@end
