//
//  NSData+AES256.h
//  CBWallet
//
//  Created by Zin on 16/3/22.
//  Copyright © 2016年 Bitmain. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSData (AES256)
/// encrypt
///
///@param key Base64 String
///@return data use <code>[encryptedData base64EncodedStringWithOptions:NSDataBase64Encoding64CharacterLineLength]</code>
- (NSData *)AES256EncryptWithKey:(NSString *)key;
/// decrypt
///
///@param key Base64 String
///@return data use <code>[[NSString alloc] initWithData:decryptedData encoding:NSUTF8StringEncoding]</code>
- (NSData *)AES256DecryptWithKey:(NSString *)key;
@end
