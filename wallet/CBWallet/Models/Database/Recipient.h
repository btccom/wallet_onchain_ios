//
//  Recipient.h
//  wallet
//
//  Created by Zin on 16/2/24.
//  Copyright © 2016年 Bitmain. All rights reserved.
//

#import "RecordObject.h"

@interface Recipient : RecordObject

@property (nonatomic, copy) NSString * _Nonnull address;
@property (nonatomic, copy) NSString * _Nullable label;

@end
