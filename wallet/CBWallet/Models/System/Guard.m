//
//  Guard.m
//  CBWallet
//
//  Created by Zin on 16/3/22.
//  Copyright © 2016年 Bitmain. All rights reserved.
//

#import "Guard.h"
//#import <CommonCrypto/CommonCrypto.h>
#import "NSString+PBKDF2.h"
#import "NSData+AES256.h"

@interface Guard ()

@property (nonatomic, strong) NSTimer *timer;

@end

@implementation Guard

+ (instancetype)globalGuard {
    static id staticInstance = nil;
    static dispatch_once_t onceToken;
    
    dispatch_once(&onceToken, ^{
        staticInstance = [[self alloc] init];
    });
    return staticInstance;
}

- (BOOL)checkInWithCode:(NSString *)code {
//
//    size_t i;
//    unsigned char *out;
//    const char pwd[] = "password";
//    unsigned char salt_value[] = {'s','a','l','t'};
//    
//    out = (unsigned char *) malloc(sizeof(unsigned char) * 20);
//    
//    printf("pass: %s\n", pwd);
//    printf("ITERATION: %u\n", 1000);
//    printf("salt: "); for(i=0;i<sizeof(salt_value);i++) { printf("%02x", salt_value[i]); } printf("\n");
//    
//    if( PKCS5_PBKDF2_HMAC_SHA1(pwd, (int)strlen(pwd), salt_value, sizeof(salt_value), 1000, 20, out) != 0 ) {
//        printf("out: "); for(i=0;i<20;i++) { printf("%02x", out[i]); } printf("\n");
//    } else {
//        fprintf(stderr, "PKCS5_PBKDF2_HMAC_SHA1 failed\n");
//    }
//    
//    NSMutableString *password = [NSMutableString string];
//    for (i = 0; i < 20; i++) {
//        [password appendFormat:@"%02x", out[i]];
//    }
//    
//    free(out);
//    
//    NSLog(@"password: %@", password);
    
    
//    NSString *p = @"password";
//    NSString *salt = @"salt";
//    NSLog(@"key: %@", [p PBKDF2KeyWithSalt:salt]);
//    
//    NSString *secret = @"secret";
//    NSData *encryptedData = [[secret dataUsingEncoding:NSUTF8StringEncoding] AES256EncryptWithKey:[p PBKDF2KeyWithSalt:salt]];
//    NSLog(@"encrypted data: %@", [encryptedData base64EncodedStringWithOptions:NSDataBase64Encoding64CharacterLineLength]);
//    
//    NSData *decryptedData = [encryptedData AES256DecryptWithKey:[p PBKDF2KeyWithSalt:salt]];
//    NSLog(@"decrypted secret: %@", [[NSString alloc] initWithData:decryptedData encoding:NSUTF8StringEncoding]);
//    NSLog(@"================================");
    
    return NO;
}

- (void)checkOut {
    _code = @"";
    [self.timer invalidate];
}


//- (NSData *)keyForPassword:(NSString *)password andSalt:(NSData *)salt {
//    NSUInteger keySize = kCCKeySizeAES256;
//    NSMutableData *derivedKey = [NSMutableData dataWithLength:keySize];
//    unsigned char *derivedKeyPtr = [derivedKey mutableBytes];
//    
//    NSData *passwordData = [password dataUsingEncoding:NSUTF8StringEncoding];
//    const char *passwordPtr = passwordData.bytes;
//    
//    const uint8_t *saltPtr = salt.bytes;
//    
//    CCPBKDFAlgorithm algorithm = kCCPBKDF2;
//    CCPseudoRandomAlgorithm prf = kCCPRFHmacAlgSHA1;
//    uint pbkdf2Rounds = 10000;
//    
//    int result = CCKeyDerivationPBKDF(algorithm, passwordPtr, strlen(passwordPtr), saltPtr, salt.length, prf, pbkdf2Rounds, derivedKeyPtr, derivedKey.length);
//    
//    if (result != kCCSuccess) {
//        NSLog(@"add salt failed");
//        return nil;
//    }
//    
//    return derivedKey;
//}

@end
