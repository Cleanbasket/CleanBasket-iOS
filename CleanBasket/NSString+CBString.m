//
//  NSString+CBString.m
//  CleanBasket
//
//  Created by Wonhyo Yi on 2014. 10. 20..
//  Copyright (c) 2014년 WashAppKorea. All rights reserved.
//

#import "NSString+CBString.h"

@implementation NSString (CBString)

+ (NSString*) stringWithCurrencyFormat:(int)price {
    NSNumberFormatter *numberFormatter = [[NSNumberFormatter alloc] init];
    [numberFormatter setNumberStyle: NSNumberFormatterCurrencyStyle];
    NSString *priceAsString = [numberFormatter stringFromNumber:[NSNumber numberWithInt:price]];
    return priceAsString;
}

@end
