//
//  DTOManager.h
//  CleanBasket
//
//  Created by Wonhyo Yi on 2014. 10. 13..
//  Copyright (c) 2014년 WashAppKorea. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Realm/Realm.h>
#import "User.h"
#import "Address.h"
#import "Item.h"
#import "Coupon.h"

@interface DTOManager : NSObject

@property int currentUid;
@property NSArray *availableBorough;

+ (id)defaultManager;
- (void)createUser:(NSDictionary*)userInfo;
- (void)createItemCode:(NSArray*)itemArray;
- (void)createCoupon:(NSArray*)couponArray;
@end
