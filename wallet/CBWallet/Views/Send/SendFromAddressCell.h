//
//  SendFromAddressCell.h
//  CBWallet
//
//  Created by Zin on 16/4/6.
//  Copyright © 2016年 Bitmain. All rights reserved.
//

#import "FormControlStaticArrowCell.h"

@interface SendFromAddressCell : FormControlStaticArrowCell

/// of label or address string
- (void)setAddresses:(nullable NSArray *)addresses;

@end
