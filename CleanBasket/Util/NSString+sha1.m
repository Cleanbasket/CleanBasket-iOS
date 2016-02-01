//
//  NSString+sha1.m
//  CleanBasket
//
//  Created by 이상진 on 2016. 1. 30..
//  Copyright © 2016년 WashappKorea. All rights reserved.
//

#import "NSString+sha1.h"
#import <CommonCrypto/CommonDigest.h>

@implementation NSString (sha1)
- (NSString *)sha1
{
    NSData *data = [self dataUsingEncoding:NSUTF8StringEncoding];
    uint8_t digest[CC_SHA1_DIGEST_LENGTH];
    
    CC_SHA1(data.bytes, data.length, digest);
    
    NSMutableString *output = [NSMutableString stringWithCapacity:CC_SHA1_DIGEST_LENGTH * 2];
    
    for (int i = 0; i < CC_SHA1_DIGEST_LENGTH; i++)
    {
        [output appendFormat:@"%02x", digest[i]];
    }
    
    return output;
}
@end
