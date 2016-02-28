//
//  CBNotificationManager.h
//  CleanBasket
//
//  Created by 이상진 on 2016. 2. 28..
//  Copyright © 2016년 WashappKorea. All rights reserved.
//

#import <Foundation/Foundation.h>

#ifndef SHARED_SINGLETON
#define SHARED_SINGLETON(classname)                     \
+ (classname *)sharedManager {                          \
static dispatch_once_t pred;                            \
static classname * shared##classname = nil;             \
dispatch_once( &pred, ^{                                \
shared##classname = [[self alloc] init];                \
});                                                     \
return shared##classname;                               \
}
#endif

@interface CBNotificationManager : NSObject


+ (instancetype) sharedManager;

- (void)configure;

- (void)addPickUpNoti:(NSDate*)pickUpDate oid:(NSString*)oid;
- (void)addDropOffNoti:(NSDate*)dropOffDate oid:(NSString*)oid;
- (void)removeNoti:(NSString*)oid;

@end
