//
//  Item.m
//  CleanBasket
//
//  Created by Wonhyo Yi on 2014. 10. 16..
//  Copyright (c) 2014년 WashAppKorea. All rights reserved.
//

#import "Item.h"

@implementation Item

// Specify default values for properties

+ (NSDictionary *)defaultPropertyValues
{
    return @{@"count":@0};
}

// Specify properties to ignore (Realm won't persist these)

//+ (NSArray *)ignoredProperties
//{
//    return @[];
//}

//+ (NSString *)primaryKey {
//    return @"itid";
//}

@end
