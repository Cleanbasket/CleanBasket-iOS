//
//  PickupInfo.h
//  CleanBasket
//
//  Created by Wonhyo Yi on 2014. 10. 21..
//  Copyright (c) 2014년 WashAppKorea. All rights reserved.
//

#import <Realm/Realm.h>

@interface PickupInfo : RLMObject
@property NSString *birthday;
@property NSString *email;
@property NSString *img;
@property NSString *name;
@property NSString *phone;
@property int uid;
@end

// This protocol enables typed collections. i.e.:
// RLMArray<PickupInfo>
RLM_ARRAY_TYPE(PickupInfo)
