//
//  AddressListViewController.m
//  wallet
//
//  Created by Zin (noteon.com) on 16/2/25.
//  Copyright © 2016年 Bitmain. All rights reserved.
//

// TODO: 批量获取地址摘要信息

#import "AddressListViewController.h"
#import "ArchivedAdressListViewController.h"
#import "ScanViewController.h"

#import "Database.h"

#import "NSString+CBWAddress.h"

@interface AddressListViewController ()<ScanViewControllerDelegate>

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

- (NSMutableArray *)selectedAddress {
    if (!_selectedAddress) {
        _selectedAddress = [[NSMutableArray alloc] init];
    }
    return _selectedAddress;
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
            UIBarButtonItem *createButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"navigation_create"] style:UIBarButtonItemStylePlain target:self action:@selector(p_handleCreateAddress:)];
            NSMutableArray *items = [NSMutableArray arrayWithObject:createButtonItem];
            
            if (self.account.idx != CBWRecordWatchedIdx) {
                UIBarButtonItem *archivedListButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"navigation_archived_empty"] style:UIBarButtonItemStylePlain target:self action:@selector(p_handleArchivedAddressList:)];
                [items insertObject:archivedListButtonItem atIndex:0];
                self.archivedListButtonItem = archivedListButtonItem;
            }
            
            self.navigationItem.rightBarButtonItems = items;
            break;
        }
            
        case AddressActionTypeChange:
        case AddressActionTypeReceive: {
            self.title = NSLocalizedStringFromTable(@"Navigation select_address", @"CBW", @"Select Address");
            _actionCells = @[NSLocalizedStringFromTable(@"Address Cell new_address", @"CBW", @"New Address")];
            break;
        }
        case AddressActionTypeSend: {
            self.title = NSLocalizedStringFromTable(@"Navigation select_address", @"CBW", @"Select Address");
            break;
        }
    }
    
    DLog(@"address list of account: %ld", (long)self.account.idx);
    [self.addressStore fetch];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
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
        DLog(@"can not create address without account");
        return;
    }
    if (self.account.idx < 0) {
        DLog(@"can not create address with account idx < 0 (watched only)");
        DLog(@"create manualy");
        
        UIAlertController *alertController = [UIAlertController alertControllerWithTitle:NSLocalizedStringFromTable(@"Alert Title new_address", @"CBW", nil) message:NSLocalizedStringFromTable(@"Alert Message new_address", @"CBW", nil) preferredStyle:UIAlertControllerStyleAlert];
        [alertController addTextFieldWithConfigurationHandler:^(UITextField * _Nonnull textField) {
            textField.font = [UIFont monospacedFontOfSize:UIFont.labelFontSize];
            textField.placeholder = NSLocalizedStringFromTable(@"Placeholder bitcoin_address", @"CBW", nil);
        }];
        UIAlertAction *saveAction = [UIAlertAction actionWithTitle:NSLocalizedStringFromTable(@"Alert Action save_address", @"CBW", nil) style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            NSString *addressString = [alertController.textFields firstObject].text;
            // TODO: 验证地址有效性
            if (addressString.length > 0) {
                [self p_saveAddressString:addressString withIdx:CBWRecordWatchedIdx];
            }
        }];
        UIAlertAction *scanAction = [UIAlertAction actionWithTitle:NSLocalizedStringFromTable(@"Alert Action scan_qr_code", @"CBS", nil) style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            DLog(@"to scan qrcode");
            [self p_handleScan:nil];
        }];
        UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:NSLocalizedStringFromTable(@"Cancel", @"CBW", nil) style:UIAlertActionStyleCancel handler:nil];
        [alertController addAction:cancelAction];
        [alertController addAction:saveAction];
        [alertController addAction:scanAction];
        [self presentViewController:alertController animated:YES completion:nil];
        
        return;
    }
    
    // create address
    NSUInteger idx = self.addressStore.countAllAddresses;
    NSString *addressString = [Address addressStringWithIdx:idx acountIdx:self.account.idx];
    [self p_saveAddressString:addressString withIdx:idx];
}
- (void)p_handleArchivedAddressList:(id)sender {
    ArchivedAdressListViewController *archivedAddressListViewController = [[ArchivedAdressListViewController alloc] initWithAccount:self.account];
    [self.navigationController pushViewController:archivedAddressListViewController animated:YES];
}
- (void)p_handleScan:(id)sender {
    ScanViewController *scanViewController = [[ScanViewController alloc] init];
    scanViewController.delegate = self;
    [self presentViewController:scanViewController animated:YES completion:nil];
}
#pragma mark -
- (void)p_saveAddressString:(NSString *)addressString withIdx:(NSInteger)idx {
    [self p_saveAddressString:addressString withIdx:idx label:@""];
}
- (void)p_saveAddressString:(NSString *)addressString withIdx:(NSInteger)idx label:(NSString *)label {
    if (!addressString) {
        UIAlertController *alertController = [UIAlertController alertControllerWithTitle:NSLocalizedStringFromTable(@"Error", @"CBW", nil) message:NSLocalizedStringFromTable(@"Alert Message failed_to_generate_address", @"CBW", nil) preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *okayAction = [UIAlertAction actionWithTitle:NSLocalizedStringFromTable(@"Okay", @"CBW", nil) style:UIAlertActionStyleCancel handler:nil];
        [alertController addAction:okayAction];
        [self presentViewController:alertController animated:YES completion:nil];
        return;
    }
    
    // save address record
    Address *address = [Address newAdress:addressString withLabel:label idx:idx accountRid:self.account.rid accountIdx:self.account.idx inStore:self.addressStore];
    [address saveWithError:nil];
    
    [self.tableView insertRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:0 inSection:self.actionCells.count > 0 ? 1 : 0]] withRowAnimation:UITableViewRowAnimationAutomatic];
    if (self.actionType == AddressActionTypeChange) {
        [self p_selectChangeAddress:address];
        return;
    }
    [self p_pushToAddress:address];
}
- (void)p_selectChangeAddress:(Address *)address {
    if ([self.delegate respondsToSelector:@selector(addressListViewController:didSelectAddress:)]) {
        [self.delegate addressListViewController:self didSelectAddress:address];
    }
    [self.navigationController popViewControllerAnimated:YES];
}
- (void)p_pushToAddress:(Address *)address {
    AddressViewController *addressViewController = [[AddressViewController alloc] initWithAddress:address actionType:self.actionType];
    if (addressViewController) {
        [self.navigationController pushViewController:addressViewController animated:YES];
    }
}

#pragma mark - <UITableViewDataSource>
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
            FormControlActionButtonCell *cell = [tableView dequeueReusableCellWithIdentifier:BaseTableViewCellActionButtonIdentifier forIndexPath:indexPath];
            cell.imageView.image = [UIImage imageNamed:@"icon_create_mini"];
            cell.textLabel.text = self.actionCells[indexPath.row];
            return cell;
        }
    }
    // address section
    AddressCell *cell = [tableView dequeueReusableCellWithIdentifier:BaseListViewCellAddressIdentifier forIndexPath:indexPath];
    [cell setMetadataHidden:(self.actionType == AddressActionTypeReceive)];
    Address *address = [self.addressStore recordAtIndex:indexPath.row];
    [cell setAddress:address];
    // if used to send, check mark
    if (self.actionType == AddressActionTypeSend) {
        if ([self.selectedAddress containsObject:address]) {
            cell.accessoryType = UITableViewCellAccessoryCheckmark;
        }
    }
    return cell;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    if (self.actionType == AddressActionTypeReceive && section == 1) {
        return NSLocalizedStringFromTable(@"Address Section receive_address", @"CBW", @"Address");
    }
    return nil;
}

#pragma mark <UITableViewDelgate>
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (self.actionType == AddressActionTypeReceive) {
        return CBWCellHeightAddress;
    }
    return CBWCellHeightAddressWithMetadata;
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 0) {
        if (self.actionCells.count > 0) {
            // action section
            [tableView deselectRowAtIndexPath:indexPath animated:YES];
            // TODO: handle different action
            [self p_handleCreateAddress:nil];
            return;
        }
    }
    Address *address = [self.addressStore recordAtIndex:indexPath.row];
    if (self.actionType == AddressActionTypeSend) {
        // used to send
        [tableView deselectRowAtIndexPath:indexPath animated:YES];
        UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
        if ([self.selectedAddress containsObject:address]) {
            // deselect
            [self.selectedAddress removeObject:address];
            cell.accessoryType = UITableViewCellAccessoryNone;
            if ([self.delegate respondsToSelector:@selector(addressListViewController:didDeselectAddress:)]) {
                [self.delegate addressListViewController:self didDeselectAddress:address];
            }
        } else {
            // check value
//            if (address.balance > 0) {
                [self.selectedAddress addObject:address];
                cell.accessoryType = UITableViewCellAccessoryCheckmark;
                if ([self.delegate respondsToSelector:@selector(addressListViewController:didSelectAddress:)]) {
                    [self.delegate addressListViewController:self didSelectAddress:address];
                }
//            }
        }
        return;
    } else if (self.actionType == AddressActionTypeChange) {
        // used for change
        [self p_selectChangeAddress:address];
        return;
    }
    // just select one address
    [self p_pushToAddress:address];
}

#pragma mark - <ScanViewControllerDelegate>
- (BOOL)scanViewControllerWillDismiss:(ScanViewController *)viewController {
    [self dismissViewControllerAnimated:YES completion:nil];
    return YES;
}

- (void)scanViewController:(ScanViewController *)viewController didScanString:(NSString *)string {
    [self dismissViewControllerAnimated:YES completion:nil];
    
    NSDictionary *addressInfo = [string addressInfo];
    if (!addressInfo) {
        UIAlertController *alertController = [UIAlertController alertControllerWithTitle:NSLocalizedStringFromTable(@"Error", @"CBW", nil) message:NSLocalizedStringFromTable(@"Alert Message invalid_address", @"CBW", nil) preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *okAction = [UIAlertAction actionWithTitle:NSLocalizedStringFromTable(@"Okay", @"CBW", nil) style:UIAlertActionStyleCancel handler:nil];
        [alertController addAction:okAction];
        [self presentViewController:alertController animated:YES completion:nil];
        return;
    }
    [self p_saveAddressString:[addressInfo objectForKey:NSStringAddressInfoAddressKey] withIdx:CBWRecordWatchedIdx label:[addressInfo objectForKey:NSStringAddressInfoLabelKey]];
}

@end
