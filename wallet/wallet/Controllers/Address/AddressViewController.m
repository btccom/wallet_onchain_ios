//
//  AddressViewController.m
//  wallet
//
//  Created by Zin on 16/2/15.
//  Copyright © 2016年 Bitmain. All rights reserved.
//

#import "AddressViewController.h"
#import "AddressHeaderView.h"

#import "Address.h"

@interface AddressViewController ()

@end

@implementation AddressViewController

#pragma mark - Initialization

- (instancetype)initWithAddress:(Address *)address {
    self = [super initWithStyle:UITableViewStylePlain];
    if (self) {
        _address = address;
    }
    return self;
}

#pragma mark - View Life Cycle

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    AddressHeaderView *addressHeaderView = [[AddressHeaderView alloc] init];
    [addressHeaderView setAddress:self.address.address withLabel:self.address.label];
    [self.tableView setTableHeaderView:addressHeaderView];
    switch (self.actionType) {
        case AddressActionTypeDefault: {
            self.title = NSLocalizedStringFromTable(@"Navigation Address", @"BTCC", @"Address");
            self.navigationItem.rightBarButtonItems = @[[[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"navigation_archive"] style:UIBarButtonItemStylePlain target:self action:@selector(p_handleArchive:)],
                                                        [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"navigation_share"] style:UIBarButtonItemStylePlain target:self action:@selector(p_handleShare:)]];
            break;
        }
            
        case AddressActionTypeReceive: {
            self.title = NSLocalizedStringFromTable(@"Navigation Receive", @"BTCC", @"Receive");
            break;
        }
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Private Method
#pragma mark Handlers
- (void)p_handleShare:(id)sender {
    NSLog(@"clicked share");
}

- (void)p_handleArchive:(id)sender {
    NSLog(@"clicked archive");
}

@end
