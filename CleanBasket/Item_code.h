//
//  Item_code.h
//  CleanBasket
//
//  Created by Wonhyo Yi on 2014. 10. 24..
//  Copyright (c) 2014년 WashAppKorea. All rights reserved.
//

#import <Realm/Realm.h>

@interface Item_code : RLMObject

@property int item_code;
@property NSString *name;
@property NSString *descr;
@property int price;
@property NSString *img;
@property NSString *rdate;

@end

// This protocol enables typed collections. i.e.:
// RLMArray<Item_code>
RLM_ARRAY_TYPE(Item_code)
