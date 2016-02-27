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

@property (nonatomic, strong) Transaction * _Nonnull transaction;

@property (nonatomic, weak, readonly) UIImageView * _Nullable iconView;
@property (nonatomic, weak, readonly) UILabel * _Nullable dateLabel;
@property (nonatomic, weak, readonly) UILabel * _Nullable addressLabel;
@property (nonatomic, weak, readonly) UILabel * _Nullable confirmedLabel;
@property (nonatomic, weak, readonly) UILabel * _Nullable valueLabel;

@end
