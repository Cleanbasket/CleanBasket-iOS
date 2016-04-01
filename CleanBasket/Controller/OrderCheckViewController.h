//
//  OrderCheckViewController.h
//  CleanBasket
//
//  Created by ChaTheodore on 2016. 3. 24..
//  Copyright © 2016년 WashappKorea. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol OrderViewDelegate <NSObject>

-(void) getPhoneData:(NSString*) phoneData;
-(void) getMemoData:(NSString*) menoData;
-(void) addOrderEvent;

@end

@interface OrderCheckViewController : UIViewController{
    NSString *userAddress;
    NSString *userPickupTime;
    NSString *userDropoffTime;
    NSString *userPhoneNumber;
    NSString *memo;
    BOOL isMemo;
    
}

@property (strong, nonatomic) NSString *userAddress;
@property (strong, nonatomic) NSString *userPickupTime;
@property (strong, nonatomic) NSString *userDropoffTime;
@property (strong, nonatomic) NSString *userPhoneNumber;
@property (strong, nonatomic) NSString *memo;
@property (nonatomic, assign) id< OrderViewDelegate> delegate;

@end
