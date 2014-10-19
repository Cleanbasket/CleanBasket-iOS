//
//  User.m
//  CleanBasket
//
//  Created by Wonhyo Yi on 2014. 10. 16..
//  Copyright (c) 2014년 WashAppKorea. All rights reserved.
//

#import "User.h"

@implementation User

// Specify default values for properties

//+ (NSDictionary *)defaultPropertyValues
//{
//    return @{
//             @"uid":@NEW_INDEX,
//             @"email":@"",
//             @"phone":@"",
//             @"address":@[]};
//}

// Specify properties to ignore (Realm won't persist these)

//+ (NSArray *)ignoredProperties
//{
//    return @[];
//}

+ (NSString *)primaryKey {
    return @"uid";
}

@end
