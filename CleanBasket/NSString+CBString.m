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

+ (NSString*) trimDateString:(NSString *)dateString {
    NSString *trimmedString = dateString;
    trimmedString = [trimmedString substringToIndex:16];
    NSString *pickupHourString = [trimmedString substringWithRange:NSMakeRange(11, 2)];
    NSString *pickupMinuteString = [trimmedString substringWithRange:NSMakeRange(14, 2)];
    int toHour = [pickupHourString intValue] + 1;
    trimmedString = [trimmedString stringByAppendingString:[NSString stringWithFormat:@" ~ %d:%@", toHour, pickupMinuteString]];
    return trimmedString;
}

@end
