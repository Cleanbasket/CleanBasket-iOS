//
//  Order.h
//  CleanBasket
//
//  Created by Wonhyo Yi on 2014. 10. 16..
//  Copyright (c) 2014년 WashAppKorea. All rights reserved.
//

#import <Realm/Realm.h>
#import "CBConstants.h"
#import "Coupon.h"
#import "Item.h"
#import "PickupInfo.h"

@interface Order : RLMObject
@property NSString *addr_building;
@property NSString *addr_number;
@property NSString *addr_remainder;
@property NSString *address;
@property RLMArray<Coupon> *coupon;
@property NSString *dropoff_date;
@property int dropoff_man;
@property int dropoff_price;
@property RLMArray<Item> *Item;
@property NSString *memo;
@property int oid;
@property NSString *order_number;
@property NSString *phone;
@property PickupInfo *pickupInfo;
@property NSString *pickup_date;
@property int pickup_man;
@property int price;
@property NSString *rdate;
@property int state;
@end
RLM_ARRAY_TYPE(Order)