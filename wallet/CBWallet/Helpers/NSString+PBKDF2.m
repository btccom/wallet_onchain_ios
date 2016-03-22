//
//  NSString+PBKDF2.m
//  CBWallet
//
//  Created by Zin on 16/3/22.
//  Copyright © 2016年 Bitmain. All rights reserved.
//

#import "NSString+PBKDF2.h"
#import <CommonCrypto/CommonCrypto.h>

@implementation NSString (PBKDF2)

- (NSString *)PBKDF2KeyWithSalt:(NSString *)salt {
    NSUInteger keySize = kCCKeySizeAES256;
    NSMutableData *derivedKey = [NSMutableData dataWithLength:keySize];
    unsigned char *derivedKeyPtr = [derivedKey mutableBytes];
    
    NSData *passwordData = [self dataUsingEncoding:NSUTF8StringEncoding];
    const char *passwordPtr = passwordData.bytes;
    
    NSData *saltData = [salt dataUsingEncoding:NSUTF8StringEncoding];
    const uint8_t *saltPtr = saltData.bytes;
    
    CCPBKDFAlgorithm algorithm = kCCPBKDF2;
    CCPseudoRandomAlgorithm prf = kCCPRFHmacAlgSHA1;
    uint pbkdf2Rounds = 10000;
    
    int result = CCKeyDerivationPBKDF(algorithm, passwordPtr, strlen(passwordPtr), saltPtr, salt.length, prf, pbkdf2Rounds, derivedKeyPtr, derivedKey.length);
    
    if (result != kCCSuccess) {
        NSLog(@"add salt failed");
        return nil;
    }
    
    return [derivedKey base64EncodedStringWithOptions:NSDataBase64Encoding64CharacterLineLength];
}

@end
