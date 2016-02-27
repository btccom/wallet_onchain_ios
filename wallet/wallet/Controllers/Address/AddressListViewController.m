//
//  AddressListViewController.m
//  wallet
//
//  Created by Zin on 16/2/25.
//  Copyright © 2016年 Bitmain. All rights reserved.
//

#import "AddressListViewController.h"

@interface AddressListViewController ()

@end

@implementation AddressListViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    switch (self.actionType) {
        case AddressListActionTypeList: {
            self.title = NSLocalizedStringFromTable(@"Navigation Address", @"BTCC", @"Address List");
            break;
        }
        case AddressListActionTypeReceive: {
            self.title = NSLocalizedStringFromTable(@"Navigation SelectAddress", @"BTCC", @"Select Address to Receive");
            break;
        }
    }
}

@end
