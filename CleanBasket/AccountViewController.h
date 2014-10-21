//
//  AccountViewController.h
//  CleanBasket
//
//  Created by Wonhyo Yi on 2014. 10. 3..
//  Copyright (c) 2014년 WashAppKorea. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Realm/Realm.h>
#import "AFNetworking.h"
#import "User.h"
#import "Order.h"

@interface AccountViewController : UIViewController {
    AFHTTPRequestOperationManager *manager;
    RLMRealm *realm;
    UILabel *personalLabel;
    UILabel *emailLabel;
    UILabel *emailValueLabel;
    UILabel *contactLabel;
    UILabel *contactValueLabel;
    UILabel *passwordLabel;
    UIButton *passwordChangeButton;
    
    UILabel *pushNotiLabel;
    
}
@end
