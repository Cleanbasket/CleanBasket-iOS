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

@interface DTOManager : NSObject {
    int currentUid;
}

+ (id)defaultManager;
- (void)createUser:(NSDictionary*)userInfo;

@end
