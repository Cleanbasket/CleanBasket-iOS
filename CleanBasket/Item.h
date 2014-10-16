//
//  Item.h
//  CleanBasket
//
//  Created by Wonhyo Yi on 2014. 10. 16..
//  Copyright (c) 2014년 WashAppKorea. All rights reserved.
//

#import <Realm/Realm.h>

@interface Item : RLMObject
@property int itid;
@property int oid;
@property int item_code;
@property NSString *name;
@property NSString *descr;
@property int price;
@property int count;
@property NSString *img;
@property NSString *rdate;
@end

// This protocol enables typed collections. i.e.:
// RLMArray<Item>
RLM_ARRAY_TYPE(Item)
