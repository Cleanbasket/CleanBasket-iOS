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

@interface AccountViewController : UIViewController {
    AFHTTPRequestOperationManager *manager;
    RLMRealm *realm;
}
@end
