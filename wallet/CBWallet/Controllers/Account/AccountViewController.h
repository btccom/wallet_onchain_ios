//
//  AccountViewController.h
//  wallet
//
//  Created by Zin (noteon.com) on 16/2/15.
//  Copyright © 2016年 Bitmain. All rights reserved.
//

#import "BaseListViewController.h"

#import "UIViewControllerUserInteractionSetable.h"

@class CBWAccount;

/// Account
@interface AccountViewController : BaseListViewController <UIViewControllerUserInteractionSetable>

- (void)reload;
- (void)reloadTransactions;

@end

