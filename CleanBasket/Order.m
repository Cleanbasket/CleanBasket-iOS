//
//  Order.m
//  CleanBasket
//
//  Created by Wonhyo Yi on 2014. 10. 16..
//  Copyright (c) 2014년 WashAppKorea. All rights reserved.
//

#import "Order.h"

@implementation Order

// Specify default values for properties

+ (NSDictionary *)defaultPropertyValues
{
    return @{
      @"oid":@0,
      @"pickup_man":@0,
      @"dropoff_man":@0,
      @"order_number":@"",
      @"state":@0,
      @"phone":@"",
      @"address":@"",
      @"addr_number":@"",
      @"addr_building":@"",
      @"addr_remainder":@"",
      @"memo":@"",
      @"price":@0,
      @"dropoff_price":@0,
      @"pickup_date":@"",
      @"dropoff_date":@"",
      @"rdate":@""
      };
}

// Specify properties to ignore (Realm won't persist these)

//+ (NSArray *)ignoredProperties
//{
//    return @[];
//}

+ (NSString *)primaryKey {
    return @"oid";
}

@end
