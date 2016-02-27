//
//  Address.h
//  wallet
//
//  Created by Zin on 16/2/24.
//  Copyright © 2016年 Bitmain. All rights reserved.
//

#import "RecordObject.h"

@interface Address : RecordObject

/// 仅用来观察，不持有私钥，用户有默认的 watched account 来管理该类型地址
@property (nonatomic, assign, getter=isWatched) BOOL watched;

@end
