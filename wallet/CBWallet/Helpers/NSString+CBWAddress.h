//
//  NSString+CBWAddress.h
//  wallet
//
//  Created by Zin on 16/2/27.
//  Copyright © 2016年 Bitmain. All rights reserved.
//

#import <Foundation/Foundation.h>

extern NSString *const _Nonnull NSStringAddressInfoAddressKey;
extern NSString *const _Nonnull NSStringAddressInfoLabelKey;
extern NSString *const _Nonnull NSStringAddressInfoAmountKey;

@interface NSString (CBWAddress)

- (nullable NSAttributedString *)attributedAddressWithAlignment:(NSTextAlignment)alignment;

- (nullable UIImage *)qrcodeImageWithSize:(CGSize)size;

/// 解析地址信息，简单校验地址合法性
- (nullable NSDictionary *)addressInfo;

@end
