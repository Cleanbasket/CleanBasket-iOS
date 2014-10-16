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

- (void) createUser:(NSDictionary*)responseDict {
    realm = [RLMRealm defaultRealm];
    currentUid = [[responseDict valueForKey:@"uid"] intValue];
    if (![User objectForPrimaryKey:[responseDict valueForKey:@"uid"]]) {
        [realm beginWriteTransaction];
        currentUser = [User createInDefaultRealmWithObject:responseDict];
        [realm addObject:currentUser];
        [realm commitWriteTransaction];
    }
    
    // OrderViewController로 하여금 유저 정보를 View에 채운다.
    [[NSNotificationCenter defaultCenter] postNotificationName:@"didCreateUser" object:self userInfo:[NSDictionary dictionaryWithObject:[responseDict valueForKey:@"uid"] forKey:@"uid"]];
    
    NSLog(@"\r[CURRENT USER]\r%@", currentUser);
}

@end
