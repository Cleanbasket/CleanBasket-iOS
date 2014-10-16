//
//  Coupon.h
//  CleanBasket
//
//  Created by Wonhyo Yi on 2014. 10. 16..
//  Copyright (c) 2014년 WashAppKorea. All rights reserved.
//

#import <Realm/Realm.h>

@interface Coupon : RLMObject
@property int cpid;
@property NSString *name;
@property NSString *descr;
@property int type;
@property int kind;
@property BOOL infinite;
@property int value;
@property NSString *img;
@property NSString *start_date;
@property NSString *end_date;
@property NSString *rdate;
@end

// This protocol enables typed collections. i.e.:
// RLMArray<Coupon>
RLM_ARRAY_TYPE(Coupon)
