//
//  AddedItem.h
//  CleanBasket
//
//  Created by 이상진 on 2016. 3. 1..
//  Copyright © 2016년 WashappKorea. All rights reserved.
//

#import <Realm/Realm.h>

@interface AddedItem : RLMObject

@property NSNumber<RLMInt> *itemCode;
@property NSNumber<RLMInt> *itemPrice;
@property NSNumber<RLMInt> *addedCount;

@end

// This protocol enables typed collections. i.e.:
// RLMArray<AddedItem>
RLM_ARRAY_TYPE(Item)
