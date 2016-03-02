//
//  RecordObject.h
//  wallet
//
//  Created by Zin on 16/2/24.
//  Copyright © 2016年 Bitmain. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface RecordObject : NSObject

@property (nonatomic, strong, readonly) NSDate * _Nonnull createdDate;
@property (nonatomic, strong) NSDate * _Nonnull updatedDate;

@end
