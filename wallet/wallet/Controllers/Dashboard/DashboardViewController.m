//
//  DashboardViewController.m
//  wallet
//
//  Created by Zin on 16/2/15.
//  Copyright © 2016年 Bitmain. All rights reserved.
//

#import "DashboardViewController.h"
#import "ProfileViewController.h"
#import "AddressListViewController.h"// explorer or receive
#import "ImagePickerController.h"// scan to explorer or send
#import "TransactionListViewController.h"// list all transactions
#import "SendRecipientViewController.h"// send

@interface DashboardViewController ()

@end

@implementation DashboardViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    self.title = NSLocalizedStringFromTable(@"Dashboard Title", @"BTCWallet", @"Dashboard");
    self.view.backgroundColor = [UIColor walletBackgroundColor];
    UILabel *label = [[UILabel alloc] initWithFrame:self.view.bounds];
    label.text = @"Dashboard";
    [self.view addSubview:label];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Private Method
#pragma mark Navigation

/// present profile
- (void)handleProfile:(id)sender {
    ProfileViewController *profileViewController = [[ProfileViewController alloc] init];
    UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:profileViewController];
    [self presentViewController:navigationController animated:YES completion:nil];
}

/// push address list
- (void)handleAddressList:(id)sender {
    AddressListViewController *addressListViewController = [[AddressListViewController alloc] init];
    [self.navigationController pushViewController:addressListViewController animated:YES];
}

/// present scan
- (void)handleScan:(id)sender {
    ImagePickerController *imagePickerViewController = [[ImagePickerController alloc] init];
    [self presentViewController:imagePickerViewController animated:YES completion:nil];
}

/// push transactions
- (void)handleTransactionList:(id)sender {
    TransactionListViewController *transactionListViewController = [[TransactionListViewController alloc] init];
    [self.navigationController pushViewController:transactionListViewController animated:YES];
}

/// push send
- (void)handleSend:(id)sender {
    SendRecipientViewController *sendRecipientViewController = [[SendRecipientViewController alloc] init];
    [self.navigationController pushViewController:sendRecipientViewController animated:YES];
}

/// push address list to receive
- (void)handleReceive:(id)sender {
    AddressListViewController *addressListViewController = [[AddressListViewController alloc] init];
    addressListViewController.actionType = AddressListActionTypeReceive;
    [self.navigationController pushViewController:addressListViewController animated:YES];
}

@end
