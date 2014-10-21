//
//  DTOManager.m
//  CleanBasket
//
//  Created by Wonhyo Yi on 2014. 10. 13..
//  Copyright (c) 2014년 WashAppKorea. All rights reserved.
//

#import "DTOManager.h"
/*
 @interface Deliverer : RLMObject
 @property NSString *name;
 @property NSString *phone;
 @property NSString *img;
 @property NSString *birthday;
 @end
 
 @implementation Deliverer
 @end
 
 */
@interface DTOManager () {
    User *currentUser;
    Address *address;
    RLMRealm *realm;
}

@end

@implementation DTOManager

+ (id) defaultManager {
    static DTOManager *sharedDTOManager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedDTOManager = [[self alloc] init];
    });
    return sharedDTOManager;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        self.availableBorough = [NSArray arrayWithObjects:@"강남구", @"서초구", nil];
    }
    
    return self;
}

- (void) createUser:(NSDictionary*)responseDict {
    realm = [RLMRealm defaultRealm];
    self.currentUid = [[responseDict valueForKey:@"uid"] intValue];
    if (![User objectForPrimaryKey:[responseDict valueForKey:@"uid"]]) {
        [realm beginWriteTransaction];
        currentUser = [User createInDefaultRealmWithObject:responseDict];
        [realm addObject:currentUser];
        [realm commitWriteTransaction];
    } else {
        NSLog(@"[Realm] 유저 데이터 중복");
    }
    
    // OrderViewController로 하여금 유저 정보를 View에 채운다.
    [[NSNotificationCenter defaultCenter] postNotificationName:@"didCreateUser" object:self userInfo:[NSDictionary dictionaryWithObject:[responseDict valueForKey:@"uid"] forKey:@"uid"]];
    
//    NSLog(@"\r[CURRENT USER]\r%@", currentUser);
}

- (void) createItemCode:(NSArray*)itemArray {
    realm = [RLMRealm defaultRealm];
    [realm beginWriteTransaction];
    for (NSDictionary* each in itemArray) {
        [realm addObject:[Item createInDefaultRealmWithObject:each]];

    }
    [realm commitWriteTransaction];
//    NSLog(@"%@", [Item allObjects]);
}

- (void) createCoupon:(NSArray*)couponArray {
    realm = [RLMRealm defaultRealm];
    [realm beginWriteTransaction];
    for ( NSDictionary *each in couponArray) {
        [realm addObject:[Coupon createInDefaultRealmWithObject:each]];
    }
    [realm commitWriteTransaction];
    NSLog(@"%@", [Coupon allObjects]);
         
}

@end
