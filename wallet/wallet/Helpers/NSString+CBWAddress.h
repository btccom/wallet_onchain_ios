//
//  NSString+CBWAddress.h
//  wallet
//
//  Created by Zin on 16/2/27.
//  Copyright © 2016年 Bitmain. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSString (CBWAddress)

- (nullable NSAttributedString *)attributedAddressWithAlignment:(NSTextAlignment)alignment;

- (nullable UIImage *)qrcodeImageWithSize:(CGSize)size;

@end
