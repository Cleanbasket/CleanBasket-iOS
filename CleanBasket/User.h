//
//  User.h
//  CleanBasket
//
//  Created by Wonhyo Yi on 2014. 10. 16..
//  Copyright (c) 2014년 WashAppKorea. All rights reserved.
//

#import <Realm/Realm.h>
#import "Address.h"

@interface User : RLMObject
@property int uid;
@property NSString *email;
@property NSString *phone;
@property RLMArray<Address> *address;
@end

//RLMArray<User>
RLM_ARRAY_TYPE(User)
