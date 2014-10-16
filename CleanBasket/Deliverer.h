//
//  Deliverer.h
//  CleanBasket
//
//  Created by Wonhyo Yi on 2014. 10. 16..
//  Copyright (c) 2014년 WashAppKorea. All rights reserved.
//

#import <Realm/Realm.h>

@interface Deliverer : RLMObject
@property NSString *name;
@property NSString *phone;
@property NSString *img;
@property NSString *birthday;
@end

// This protocol enables typed collections. i.e.:
// RLMArray<Deliverer>
RLM_ARRAY_TYPE(Deliverer)
