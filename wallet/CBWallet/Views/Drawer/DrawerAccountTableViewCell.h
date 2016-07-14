//
//  DrawerAccountTableViewCell.h
//  CBWallet
//
//  Created by Zin on 16/7/14.
//  Copyright © 2016年 Bitmain. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface DrawerAccountTableViewCell : UITableViewCell

@property (nonatomic, weak, readonly, nullable) UILabel *balanceLabel;

- (void)becomeCurrent:(BOOL)current animated:(BOOL)animated;

@end
