//
//  OrderCheckViewController.h
//  CleanBasket
//
//  Created by ChaTheodore on 2016. 3. 24..
//  Copyright © 2016년 WashappKorea. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface OrderCheckViewController : UIViewController{
    NSString *userAddress;
    NSString *userPickupTime;
    NSString *userDropoffTime;
    
    
}

@property (strong, nonatomic) NSString *userAddress;
@property (strong, nonatomic) NSString *userPickupTime;
@property (strong, nonatomic) NSString *userDropoffTime;

@end
