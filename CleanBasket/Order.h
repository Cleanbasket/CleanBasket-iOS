//
//  Order.h
//  CleanBasket
//
//  Created by Wonhyo Yi on 2014. 10. 16..
//  Copyright (c) 2014년 WashAppKorea. All rights reserved.
//

#import <Realm/Realm.h>

@interface Order : RLMObject
@property int oid;
@property int pickup_man;
@property int dropoff_man;
@property NSString *order_number;
@property int state;
@property NSString *phone;
@property NSString *address;
@property NSString *addr_number;
@property NSString *addr_building;
@property NSString *addr_remainder;
@property NSString *memo;
@property int price;
@property int dropoff_price;
@property NSString *pickup_date;
@property NSString *dropoff_date;
@property NSString *rdate;
@end
RLM_ARRAY_TYPE(Order)