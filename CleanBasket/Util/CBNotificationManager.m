//
//  CBNotificationManager.m
//  CleanBasket
//
//  Created by 이상진 on 2016. 2. 28..
//  Copyright © 2016년 WashappKorea. All rights reserved.
//

#import "CBNotificationManager.h"
#import <Realm/Realm.h>
#import "Notification.h"
#import <UIKit/UIKit.h>

@implementation CBNotificationManager

SHARED_SINGLETON(CBNotificationManager);

- (void)configure {
    NSLog(@"컨피!!");
    RLMRealm *realm = [RLMRealm defaultRealm];
    [realm beginWriteTransaction];
    [realm deleteObjects:[Notification allObjects]];
    [realm commitWriteTransaction];
    
    [[UIApplication sharedApplication] cancelAllLocalNotifications];
}



- (void)addPickUpNoti:(NSDate*)pickUpDate oid:(NSString*)oid{
    
    NSDateFormatter *dateFormatter = [NSDateFormatter new];
    [dateFormatter setDateFormat:NSLocalizedString(@"time_parse", @"HH:mm")];
    
    UILocalNotification *localNoti = [UILocalNotification new];
    
    //pickUpDate 1시간 전
    localNoti.fireDate = [pickUpDate dateByAddingTimeInterval:-(60*60)];
    localNoti.timeZone = [NSTimeZone systemTimeZone];
    
    NSLog(@"localNoti : %@",localNoti);
    
    //알림 메시지
    NSString *messageString =[NSString stringWithFormat:@"%@ %@%@",NSLocalizedString(@"today", @"오늘"),[dateFormatter stringFromDate:pickUpDate],NSLocalizedString(@"pick_up_notification", @"에 수거가 있습니다.")];
    localNoti.alertBody = messageString;
    
    localNoti.userInfo = @{@"oid":oid};
    
    [[UIApplication sharedApplication] scheduleLocalNotification:localNoti];
    
    //local db에 저장.
    Notification *noti = [Notification new];
    noti.message = messageString;
    noti.oid = oid;
    noti.imageName = @"ic_alarm_pickup";
    noti.date = pickUpDate;
    
    RLMRealm *realm = [RLMRealm defaultRealm];
    [realm beginWriteTransaction];
    [realm addObject:noti];
    [realm commitWriteTransaction];
}

- (void)addDropOffNoti:(NSDate*)dropOffDate  oid:(NSString*)oid{
    NSDateFormatter *dateFormatter = [NSDateFormatter new];
    [dateFormatter setDateFormat:NSLocalizedString(@"time_parse", @"HH:mm")];
    
    UILocalNotification *localNoti = [UILocalNotification new];
    
    //dropOffDate 1시간 전
    localNoti.fireDate = [dropOffDate dateByAddingTimeInterval:-(60*60*2)];
    localNoti.timeZone = [NSTimeZone systemTimeZone];
    
    //알림 메시지
    NSString *messageString =[NSString stringWithFormat:@"%@ %@%@",NSLocalizedString(@"today", @"오늘"),[dateFormatter stringFromDate:dropOffDate],NSLocalizedString(@"drop_off_notification", @"에 배달이 있습니다.")];
    localNoti.alertBody = messageString;
    
    localNoti.userInfo = @{@"oid":oid};
    
    [[UIApplication sharedApplication] scheduleLocalNotification:localNoti];
    
    //local db에 저장.
    Notification *noti = [Notification new];
    noti.message = messageString;
    noti.oid = oid;
    noti.imageName = @"ic_alarm_delivery";
    noti.date = dropOffDate;
    
    RLMRealm *realm = [RLMRealm defaultRealm];
    [realm beginWriteTransaction];
    [realm addObject:noti];
    [realm commitWriteTransaction];
}


- (void)removeNoti:(NSString*)oid{
    
    NSArray *notifications = [[UIApplication sharedApplication] scheduledLocalNotifications];
    
    for (UILocalNotification *noti in notifications) {
        
        if([noti.userInfo[@"oid"] isEqualToString:oid]){
            [[UIApplication sharedApplication] cancelLocalNotification:noti];
        }
    }
    
}




- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

@end
