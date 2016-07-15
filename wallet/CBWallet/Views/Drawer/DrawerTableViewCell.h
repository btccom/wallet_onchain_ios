//
//  DrawerTableViewCell.h
//  CBWallet
//
//  Created by Zin (noteon.com) on 16/7/15.
//  Copyright © 2016年 Bitmain. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface DrawerTableViewCell : UITableViewCell

/// won't do nothing by default
- (void)becomeCurrent:(BOOL)current animated:(BOOL)animated;

@end
