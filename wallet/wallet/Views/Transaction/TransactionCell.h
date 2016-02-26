//
//  TransactionCell.h
//  wallet
//
//  Created by Zin on 16/2/26.
//  Copyright © 2016年 Bitmain. All rights reserved.
//

#import <UIKit/UIKit.h>

@class Transaction;

@interface TransactionCell : UITableViewCell

@property (nonatomic, strong, nonnull) Transaction *transaction;

@property (nonatomic, weak, readonly, nullable) UIImageView *iconView;
@property (nonatomic, weak, readonly, nullable) UILabel *addressLabel;
@property (nonatomic, weak, readonly, nullable) UILabel *confirmedLabel;
@property (nonatomic, weak, readonly, nullable) UILabel *valueLabel;

@end
