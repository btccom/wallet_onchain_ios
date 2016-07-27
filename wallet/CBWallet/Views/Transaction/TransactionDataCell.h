//
//  TransactionDataCell.h
//  CBWallet
//
//  Created by Zin on 16/3/31.
//  Copyright © 2016年 Bitmain. All rights reserved.
//

#import <UIKit/UIKit.h>

/// 显示交易摘要、块信息等
@interface TransactionDataCell : UITableViewCell

@property (nonatomic, assign, getter=isHashEnabled) BOOL hashEnabled;

@end
