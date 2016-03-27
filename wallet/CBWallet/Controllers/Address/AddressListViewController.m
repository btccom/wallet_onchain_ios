//
//  AddressListViewController.m
//  wallet
//
//  Created by Zin on 16/2/25.
//  Copyright © 2016年 Bitmain. All rights reserved.
//

#import "AddressListViewController.h"
#import "ArchivedAdressListViewController.h"

#import "Database.h"

@interface AddressListViewController ()

@property (nonatomic, strong) NSArray *actionCells; // create address button...
@property (nonatomic, strong) AddressStore *addressStore;

@property (nonatomic, weak) UIBarButtonItem *archivedListButtonItem;

@end

@implementation AddressListViewController

#pragma mark - Property
- (AddressStore *)addressStore {
    if (!_addressStore) {
        NSInteger accountIdx = -2;
        if (self.account) {
            accountIdx = self.account.idx;
        }
        _addressStore = [[AddressStore alloc] initWithAccountIdx:accountIdx];
    }
    return _addressStore;
}

#pragma mark - Initializer

- (instancetype)initWithAccount:(Account *)account {
    self = [super initWithStyle:UITableViewStylePlain];
    if (self) {
        _account = account;
    }
    return self;
}

- (instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    return nil;
}

- (instancetype)initWithStyle:(UITableViewStyle)style {
    return nil;
}

#pragma mark - View Life Cycle

- (void)viewDidLoad {
    [super viewDidLoad];
    
    switch (self.actionType) {
        case AddressActionTypeDefault: {
            self.title = NSLocalizedStringFromTable(@"Navigation address_list", @"CBW", @"Address List");
            UIBarButtonItem *archivedListButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"navigation_archived_empty"] style:UIBarButtonItemStylePlain target:self action:@selector(p_handleArchivedAddressList:)];
            self.navigationItem.rightBarButtonItems = @[archivedListButtonItem,
                                                        [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"navigation_create"] style:UIBarButtonItemStylePlain target:self action:@selector(p_handleCreateAddress:)]];
            self.archivedListButtonItem = archivedListButtonItem;
            break;
        }
        case AddressActionTypeReceive: {
            self.title = NSLocalizedStringFromTable(@"Navigation select_address", @"CBW", @"Select Address to Receive");
            _actionCells = @[NSLocalizedStringFromTable(@"Address Cell new_address", @"CBW", @"New Address")];
            break;
        }
    }
    
    DLog(@"address list of account: %ld", (long)self.account.idx);
    [self.addressStore fetch];
}

- (void)viewWillAppear:(BOOL)animated {
    if (self.addressStore.count < self.addressStore.countAllAddresses) {
        self.archivedListButtonItem.image = [UIImage imageNamed:@"navigation_archived"];
    } else {
        self.archivedListButtonItem.image = [UIImage imageNamed:@"navigation_archived_empty"];
    }
    [self.tableView reloadData];
}

#pragma mark - Public Method
- (void)reload {
    [self.addressStore fetch];
    [self.tableView reloadData];
}

#pragma mark - Private Method
#pragma mark Handlers
- (void)p_handleCreateAddress:(id)sender {
    if (!self.account) {
        NSLog(@"can not create address without account");
        return;
    }
    if (self.account.idx < 0) {
        NSLog(@"can not create address with account idx < 0 (watched only)");
        return;
    }
    
    NSUInteger idx = self.addressStore.countAllAddresses;
    NSString *aAddress = [Address addressStringWithIdx:idx acountIdx:self.account.idx];
    if (!aAddress) {
        UIAlertController *alertController = [UIAlertController alertControllerWithTitle:NSLocalizedStringFromTable(@"Error", @"CBW", nil) message:NSLocalizedStringFromTable(@"Message failed_to_generate_address", @"CBW", nil) preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *okayAction = [UIAlertAction actionWithTitle:NSLocalizedStringFromTable(@"Okay", @"CBW", nil) style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
            [self dismissViewControllerAnimated:YES completion:nil];
        }];
        [alertController addAction:okayAction];
        [self presentViewController:alertController animated:YES completion:nil];
        return;
    }
    
    Address *address = [Address newAdress:aAddress withLabel:@"" idx:idx accountRid:self.account.rid accountIdx:self.account.idx inStore:self.addressStore];
    [address saveWithError:nil];
    
    [self.tableView insertRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:0 inSection:self.actionCells.count > 0 ? 1 : 0]] withRowAnimation:UITableViewRowAnimationAutomatic];
    [self p_selectAddress:address];
}
- (void)p_handleArchivedAddressList:(id)sender {
    ArchivedAdressListViewController *archivedAddressListViewController = [[ArchivedAdressListViewController alloc] initWithAccount:self.account];
    [self.navigationController pushViewController:archivedAddressListViewController animated:YES];
}
#pragma mark -
- (void)p_selectAddress:(Address *)address {
    AddressViewController *addressViewController = [[AddressViewController alloc] initWithAddress:address actionType:self.actionType];
    if (addressViewController) {
        [self.navigationController pushViewController:addressViewController animated:YES];
    }
}

#pragma mark - UITableViewDataSource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return self.actionCells.count > 0 ? 2 : 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (section == 0) {
        if (self.actionCells.count > 0) {
            // action section
            return self.actionCells.count;
        }
    }
    // accress section
    return self.addressStore.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 0) {
        if (self.actionCells.count > 0) {
            // action section
            ActionButtonCell *cell = [tableView dequeueReusableCellWithIdentifier:BaseTableViewCellActionButtonIdentifier forIndexPath:indexPath];
            cell.imageView.image = [UIImage imageNamed:@"icon_create_mini"];
            cell.textLabel.text = self.actionCells[indexPath.row];
            return cell;
        }
    }
    // address section
    AddressCell *cell = [tableView dequeueReusableCellWithIdentifier:BaseListViewCellAddressIdentifier forIndexPath:indexPath];
    [cell setMetadataHidden:(self.actionType != AddressActionTypeDefault)];
    Address *address = [self.addressStore recordAtIndex:indexPath.row];
    [cell setAddress:address];
    return cell;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    if (self.actionType == AddressActionTypeReceive && section == 1) {
        return NSLocalizedStringFromTable(@"Address Section receive_address", @"CBW", @"Address");
    }
    return nil;
}

#pragma mark UITableViewDelgate
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (self.actionType == AddressActionTypeDefault) {
        return CBWCellHeightAddressWithMetadata;
    }
    return CBWCellHeightAddress;
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath == 0) {
        if (self.actionCells.count > 0) {
            // action section
            // TODO: handle differenct action
            [self p_handleCreateAddress:nil];
        }
    }
    Address *address = [self.addressStore recordAtIndex:indexPath.row];
    [self p_selectAddress:address];
}

@end
