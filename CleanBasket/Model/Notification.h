//
//  Notification.h
//  CleanBasket
//
//  Created by 이상진 on 2016. 2. 28..
//  Copyright © 2016년 WashappKorea. All rights reserved.
//

#import <Realm/Realm.h>

@interface Notification : RLMObject

@property NSString *message;
@property NSString *oid;
@property NSString *imageName;
@property NSDate *date;

@end

// This protocol enables typed collections. i.e.:
// RLMArray<Notification>
RLM_ARRAY_TYPE(Notification)
