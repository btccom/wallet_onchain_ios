//
//  Guard.h
//  CBWallet
//
//  Created by Zin on 16/3/22.
//  Copyright © 2016年 Bitmain. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Guard : NSObject

@property (nonatomic, copy, readonly) NSString *code;

// singleton factory method
+ (instancetype)globalGuard;

- (BOOL)checkCode:(NSString *)code;

/// check in
- (BOOL)checkInWithCode:(NSString *)code;
//- (void)checkInWithCode:(NSString *)code completion:(void(^)(BOOL success))completion;
- (void)checkOut;

- (void)signOut;

- (void)refreshTimer;

/// change password
- (BOOL)changeCode:(NSString *)code toNewCode:(NSString *)aNewCode;

@end
