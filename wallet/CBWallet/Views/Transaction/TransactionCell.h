//
//  TransactionCell.h
//  wallet
//
//  Created by Zin on 16/2/26.
//  Copyright © 2016年 Bitmain. All rights reserved.
//

#import <UIKit/UIKit.h>

@class CBWTransaction;

@interface TransactionCell : UITableViewCell

@property (nonatomic, weak, readonly, nullable) UIImageView *iconView;
@property (nonatomic, weak, readonly, nullable) UILabel *dateLabel;
@property (nonatomic, weak, readonly, nullable) UILabel *addressLabel;
@property (nonatomic, weak, readonly, nullable) UILabel *confirmationLabel;
@property (nonatomic, weak, readonly, nullable) UILabel *valueLabel;

- (void)setTransaction:(nonnull CBWTransaction *)trasaction;

@end
