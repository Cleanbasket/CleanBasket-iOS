//
//  Constants.h
//  CleanBasket
//
//  Created by Wonhyo Yi on 2014. 10. 3..
//  Copyright (c) 2014년 WashAppKorea. All rights reserved.
//

#import <Foundation/Foundation.h>

#define FacebookBlue [UIColor colorWithRed:(59/255.0) green:(89/255.0) blue:(152/255.0) alpha:1.0]
#define CleanBasketMint [UIColor colorWithRed:(94/255.0) green:(213/255.0) blue:(198/255.0) alpha:1.0]
#define CleanBasketRed Rgb2UIColor(249, 105, 126)
#define Rgb2UIColor(r, g, b)  [UIColor colorWithRed:((r) / 255.0) green:((g) / 255.0) blue:((b) / 255.0) alpha:1.0]
#define SCREEN_RECT [[UIScreen mainScreen] bounds]
#define DEVICE_WIDTH SCREEN_RECT.size.width
#define DEVICE_HEIGHT SCREEN_RECT.size.height
#define UltraLightGray Rgb2UIColor(238, 238, 238)
#define NEW_MEMBER_INDEX 9999