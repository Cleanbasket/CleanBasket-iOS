//
//  NSString+CBString.h
//  CleanBasket
//
//  Created by Wonhyo Yi on 2014. 10. 20..
//  Copyright (c) 2014년 WashAppKorea. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSString (CBString)

+ (NSString*) stringWithCurrencyFormat:(int)price;
+ (NSString*) trimDateString:(NSString*)dateString;
@end
