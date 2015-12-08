//
// Created by 이상진 on 2015. 12. 8..
// Copyright (c) 2015 WashappKorea. All rights reserved.
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
