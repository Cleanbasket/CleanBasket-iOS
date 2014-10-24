//
//  DTOManager.m
//  CleanBasket
//
//  Created by Wonhyo Yi on 2014. 10. 13..
//  Copyright (c) 2014년 WashAppKorea. All rights reserved.
//

#import "DTOManager.h"
#import <Realm/Realm.h>
#import "User.h"
#import "Address.h"
#import "Item_code.h"
#import "Coupon.h"
@interface DTOManager () {
    Address *address;
    RLMRealm *realm;
}

@end

@implementation DTOManager

@synthesize currentUser = _currentUser;

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
        _currentUser = [User createInDefaultRealmWithObject:responseDict];
        [realm addObject:_currentUser];
        [realm commitWriteTransaction];
    } else {
        NSLog(@"[Realm] 유저 데이터 중복");
    }
    
    // OrderViewController로 하여금 유저 정보를 View에 채운다.
    [[NSNotificationCenter defaultCenter] postNotificationName:@"didCreateUser" object:self userInfo:[NSDictionary dictionaryWithObject:[responseDict valueForKey:@"uid"] forKey:@"uid"]];
    
//        NSLog(@"\r[CURRENT USER]\r%@", _currentUser);
}

- (void) createItemCode:(NSArray*)itemArray {
    realm = [RLMRealm defaultRealm];
    [realm beginWriteTransaction];
    [realm deleteObjects:[Item_code allObjects]];
    for (NSDictionary* each in itemArray) {
        if (![Item_code objectForPrimaryKey:[NSNumber numberWithInt:[[each valueForKey:@"itid"] intValue]]])
            [realm addObject:[Item_code createInDefaultRealmWithObject:each]];
        else
            NSLog(@"Duplicated Item");
    }
    [realm commitWriteTransaction];
    NSLog(@"%@", [Item_code allObjects]);
}

- (void) createCoupon:(NSArray*)couponArray {
    realm = [RLMRealm defaultRealm];
    [realm beginWriteTransaction];
    [realm deleteObjects:[Coupon allObjects]];
    for ( NSDictionary *each in couponArray) {
        [realm addObject:[Coupon createInDefaultRealmWithObject:each]];
    }
    [realm commitWriteTransaction];
}

@end
