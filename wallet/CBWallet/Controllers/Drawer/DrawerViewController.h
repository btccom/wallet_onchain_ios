//
//  DrawerViewController.h
//  CBWallet
//
//  Created by Zin on 16/7/14.
//  Copyright © 2016年 Bitmain. All rights reserved.
//

#import "BaseListViewController.h"

@class CBWAccount;

@interface DrawerViewController : BaseListViewController

@property (nonatomic, weak) CBWAccount *currentAccount;

@end
