//
//  AccountsManagerViewController.h
//  CBWallet
//
//  Created by Zin on 16/4/18.
//  Copyright © 2016年 Bitmain. All rights reserved.
//

#import "BaseListViewController.h"
@class CBWAccountStore;

@interface AccountsManagerViewController : BaseListViewController

@property (nonatomic, strong, nonnull) CBWAccountStore *accountStore;

- (nonnull instancetype)initWithAccountStore:(nonnull CBWAccountStore *)store;

@end
