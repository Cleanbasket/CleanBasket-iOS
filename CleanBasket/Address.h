//
//  Address.h
//  CleanBasket
//
//  Created by Wonhyo Yi on 2014. 10. 16..
//  Copyright (c) 2014년 WashAppKorea. All rights reserved.
//

#import <Realm/Realm.h>
#import "CBConstants.h"

@interface Address : RLMObject
@property int adrid;
@property int uid;
@property int type;
@property NSString *address;
@property NSString *addr_number;
@property NSString *addr_building;
@property NSString *addr_remainder;
@property NSString *rdate;

- (NSString *)fullAddress;

@end

// This protocol enables typed collections. i.e.:
// RLMArray<Address>
RLM_ARRAY_TYPE(Address);