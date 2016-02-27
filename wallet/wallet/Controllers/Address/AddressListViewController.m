//
//  AddressListViewController.m
//  wallet
//
//  Created by Zin on 16/2/25.
//  Copyright © 2016年 Bitmain. All rights reserved.
//

#import "AddressListViewController.h"
#import "ArchivedAdressListViewController.h"
#import "AddressViewController.h"

@interface AddressListViewController ()

@end

@implementation AddressListViewController

#pragma mark - View Life Cycle

- (void)viewDidLoad {
    [super viewDidLoad];
    
    switch (self.actionType) {
        case AddressListActionTypeList: {
            self.title = NSLocalizedStringFromTable(@"Navigation Address", @"BTCC", @"Address List");
            self.navigationItem.rightBarButtonItems = @[[[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"navigation_archived_empty"] style:UIBarButtonItemStylePlain target:self action:@selector(p_handleArchivedAddressList:)],
                                                        [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"navigation_create"] style:UIBarButtonItemStylePlain target:self action:@selector(p_handleCreateAddress:)]];
            break;
        }
        case AddressListActionTypeReceive: {
            self.title = NSLocalizedStringFromTable(@"Navigation SelectAddress", @"BTCC", @"Select Address to Receive");
            break;
        }
    }
}

#pragma mark - Private Method
#pragma mark Handlers
- (void)p_handleCreateAddress:(id)sender {
    NSLog(@"clicked %@ to create address", sender);
}
- (void)p_handleArchivedAddressList:(id)sender {
    ArchivedAdressListViewController *archivedAddressListViewController = [[ArchivedAdressListViewController alloc] init];
    [self.navigationController pushViewController:archivedAddressListViewController animated:YES];
}

@end
