//
//  Recipient.h
//  wallet
//
//  Created by Zin (noteon.com) on 16/2/24.
//  Copyright © 2016年 Bitmain. All rights reserved.
//

#import "CBWRecordObject.h"

@interface CBWRecipient : CBWRecordObject

@property (nonatomic, copy) NSString * _Nonnull address;
@property (nonatomic, copy) NSString * _Nullable label;

@end
