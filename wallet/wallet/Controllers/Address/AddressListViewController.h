//
//  AddressListViewController.h
//  wallet
//
//  Created by Zin on 16/2/25.
//  Copyright © 2016年 Bitmain. All rights reserved.
//

#import "BaseListViewController.h"

typedef NS_ENUM(NSUInteger, AddressListActionType) {
    /// default
    AddressListActionTypeList = 0,
    /// Receive
    AddressListActionTypeReceive
};

@interface AddressListViewController : BaseListViewController

@property (nonatomic, assign) AddressListActionType actionType;

@end
