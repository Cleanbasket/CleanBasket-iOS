//
//  Address.m
//  CleanBasket
//
//  Created by Wonhyo Yi on 2014. 10. 16..
//  Copyright (c) 2014년 WashAppKorea. All rights reserved.
//

#import "Address.h"

@implementation Address

// Specify default values for properties

+ (NSDictionary *)defaultPropertyValues
{
    return @{
             @"adrid":@0,
             @"uid":@0,
             @"type":@0,
             @"address":@"",
             @"addr_number":@"",
             @"addr_building":@"",
             @"addr_remainder":@"",
             @"rdate":@""
             };
}

// Specify properties to ignore (Realm won't persist these)

//+ (NSArray *)ignoredProperties
//{
//    return @[];
//}

+ (NSString *)primaryKey {
    return @"adrid";
}

- (NSString *)fullAddress {
    NSString *fullAddress = [[NSString alloc] init];
    
    fullAddress = [fullAddress stringByAppendingString:self.address];
    fullAddress = [fullAddress stringByAppendingString:@" "];
    fullAddress = [fullAddress stringByAppendingString:self.addr_number];
    fullAddress = [fullAddress stringByAppendingString:@" "];
    fullAddress = [fullAddress stringByAppendingString:self.addr_building];
    fullAddress = [fullAddress stringByAppendingString:@" "];
    fullAddress = [fullAddress stringByAppendingString:self.addr_remainder];
    
    NSLog(@"%d", [fullAddress length]);
    if ( [fullAddress length] == 3)
        return @"주소가 없습니다";
    else
        return fullAddress;
}

@end
