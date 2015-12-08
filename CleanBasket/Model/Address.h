//
// Created by 이상진 on 2015. 12. 8..
// Copyright (c) 2015 WashappKorea. All rights reserved.
//

#import <Realm/Realm.h>

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