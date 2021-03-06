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
#import "AddressExplorerViewController.h"

#import "Database.h"

#import "NSString+CBWAddress.h"

@interface AddressListViewController ()<ScanViewControllerDelegate>

@property (nonatomic, strong) NSArray *actionCells; // create address button...
@property (nonatomic, strong) CBWAddressStore *addressStore;

@property (nonatomic, weak) UIBarButtonItem *archivedListButtonItem;

@end

@implementation AddressListViewController

#pragma mark - Property
- (CBWAddressStore *)addressStore {
    if (!_addressStore) {
        NSInteger accountIdx = -2;
        if (self.account) {
            accountIdx = self.account.idx;
        }
        _addressStore = [[CBWAddressStore alloc] initWithAccountIdx:accountIdx];
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

- (instancetype)initWithAccount:(CBWAccount *)account {
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
    
    // 检测 account
    if (!self.account) {
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:NSLocalizedStringFromTable(@"Error", @"CBW", nil) message:NSLocalizedStringFromTable(@"Alert Message invalid_account", @"CBW", nil) preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *okay = [UIAlertAction actionWithTitle:NSLocalizedStringFromTable(@"Okay", @"CBW", nil) style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
            if (self.navigationController) {
                [self.navigationController popViewControllerAnimated:YES];
            } else if (self.presentingViewController) {
                [self.presentingViewController dismissViewControllerAnimated:YES completion:nil];
            }
        }];
        [alert addAction:okay];
        [self presentViewController:alert animated:YES completion:nil];
    }
    
    switch (self.actionType) {
        case AddressActionTypeDefault: {
            self.title = NSLocalizedStringFromTable(@"Navigation address_list", @"CBW", @"Address List");
            UIBarButtonItem *createButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"navigation_create"] style:UIBarButtonItemStylePlain target:self action:@selector(p_handleCreateAddress:)];
            NSMutableArray *items = [NSMutableArray arrayWithObject:createButtonItem];
            
            if (self.account.idx != CBWRecordWatchedIDX) {
                UIBarButtonItem *archivedListButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"navigation_archived_empty"] style:UIBarButtonItemStylePlain target:self action:@selector(p_handleArchivedAddressList:)];
                [items insertObject:archivedListButtonItem atIndex:0];
                self.archivedListButtonItem = archivedListButtonItem;
            }
            
            self.navigationItem.rightBarButtonItems = items;
            break;
        }
            
        case AddressActionTypeChange: {
            self.title = NSLocalizedStringFromTable(@"Navigation select_address", @"CBW", @"Select Address");
            _actionCells = @[NSLocalizedStringFromTable(@"Address Cell new_address", @"CBW", @"New Address")];
            break;
        }
        case AddressActionTypeReceive: {
            self.title = NSLocalizedStringFromTable(@"Navigation select_address", @"CBW", @"Select Address");
//            _actionCells = @[NSLocalizedStringFromTable(@"Address Cell new_address", @"CBW", @"New Address")];
            break;
        }
        case AddressActionTypeSend: {
            self.title = NSLocalizedStringFromTable(@"Navigation select_address", @"CBW", @"Select Address");
            break;
        }
        default: {
            self.title = NSLocalizedStringFromTable(@"Navigation address_list", @"CBW", @"Address List");
            break;
        }
    }
    
    DLog(@"address list of account: %ld", (long)self.account.idx);
    [self.addressStore fetch];
    [self.addressStore addObserver:self forKeyPath:CBWRecordObjectStoreCountKey options:NSKeyValueObservingOptionNew context:nil];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self reload];
    if (self.addressStore.count < self.addressStore.countAllAddresses) {
        self.archivedListButtonItem.image = [UIImage imageNamed:@"navigation_archived"];
    } else {
        self.archivedListButtonItem.image = [UIImage imageNamed:@"navigation_archived_empty"];
    }
    [self.tableView reloadData];
}

- (void)dealloc {
    [self.addressStore removeObserver:self forKeyPath:CBWRecordObjectStoreCountKey];
    DLog(@"address list controller dealloc");
}

#pragma mark - Public Method
- (void)reload {
    [self.addressStore fetch];
    [self.tableView reloadData];
}

#pragma mark - KVO
- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSString *,id> *)change context:(void *)context {
    if ([keyPath isEqualToString:CBWRecordObjectStoreCountKey]) {
        // 当地址数量变化时，通知更新
        if ([self.delegate respondsToSelector:@selector(addressListViewControllerDidUpdate:)]) {
            [self.delegate addressListViewControllerDidUpdate:self];
        }
    }
}

#pragma mark - Private Method
#pragma mark Handlers
- (void)p_handleCreateAddress:(id)sender {
    
    if (!self.account) {
        DLog(@"can not create address without account");
        return;
    }
    // add watched address
    if (CBWRecordWatchedIDX == self.account.idx) {
        DLog(@"can not create address with account idx < 0 (watched only)");
        DLog(@"create manualy");
        
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:NSLocalizedStringFromTable(@"Alert Title new_watched_address", @"CBW", nil) message:NSLocalizedStringFromTable(@"Alert Message new_address", @"CBW", nil) preferredStyle:UIAlertControllerStyleAlert];
        [alert addTextFieldWithConfigurationHandler:^(UITextField * _Nonnull textField) {
            textField.font = [UIFont monospacedFontOfSize:UIFont.labelFontSize];
            textField.placeholder = NSLocalizedStringFromTable(@"Placeholder bitcoin_address", @"CBW", nil);
        }];
        
        __weak typeof(alert) weakAlert = alert;
        UIAlertAction *saveAction = [UIAlertAction actionWithTitle:NSLocalizedStringFromTable(@"Alert Action save_address", @"CBW", nil) style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            NSString *addressString = [weakAlert.textFields firstObject].text;
            if (addressString.length > 0) {
                if ([CBWAddress validateAddressString:addressString]) {
                    [self p_saveAddressString:addressString withIdx:CBWRecordWatchedIDX];
                } else {
                    [self alertMessageWithInvalidAddress:addressString];
                }
            } else {
                [self alertMessageWithInvalidAddress:nil];
            }
        }];
        UIAlertAction *scanAction = [UIAlertAction actionWithTitle:NSLocalizedStringFromTable(@"Alert Action scan_qr_code", @"CBW", nil) style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            DLog(@"to scan qrcode");
            [self p_handleScan:nil];
        }];
        UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:NSLocalizedStringFromTable(@"Cancel", @"CBW", nil) style:UIAlertActionStyleCancel handler:nil];
        [alert addAction:cancelAction];
        [alert addAction:saveAction];
        [alert addAction:scanAction];
        [self presentViewController:alert animated:YES completion:nil];
        
        return;
    }
    
    // create account address
    NSUInteger idx = self.addressStore.countAllAddresses;
    DLog(@"all addresses count: %lu", (unsigned long)idx);
    NSString *addressString = [CBWAddress addressStringWithIdx:idx acountIdx:self.account.idx];
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
        [self alertMessage:NSLocalizedStringFromTable(@"Alert Message failed_to_generate_address", @"CBW", nil) withTitle:NSLocalizedStringFromTable(@"Error", @"CBW", nil)];
        return;
    }
    
    // to save address record
    CBWAddress *address = [CBWAddress newAdress:addressString withLabel:label idx:idx accountRid:self.account.rid accountIdx:self.account.idx inStore:self.addressStore];
    if (self.account.idx == CBWRecordWatchedIDX) {
        // 直接保存 watched address
        [address saveWithError:nil];
    }
    
    if (!address) {
        return;
    }
    
    // 更新视图
    NSInteger addressSection = self.actionCells.count > 0 ? 1 : 0;
    NSInteger numberOfSections = [self.tableView numberOfSections];
    if (numberOfSections > addressSection) {
        [self.tableView insertRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:0 inSection:addressSection]] withRowAnimation:UITableViewRowAnimationAutomatic];
    } else {
        [self.tableView insertSections:[NSIndexSet indexSetWithIndex:addressSection] withRowAnimation:UITableViewRowAnimationAutomatic];
    }
    
    // 回调
    if (self.actionType == AddressActionTypeChange) {
        [self p_selectChangeAddress:address];
        return;
    }
    // 或展示 watched 地址
    if (self.account.idx == CBWRecordWatchedIDX) {
        [self p_pushToAddress:address];
        return;
    }
    // 或展示新建地址
    AddressViewController *addressViewController = [[AddressViewController alloc] initWithAddress:address actionType:AddressActionTypeCreate];
    if (addressViewController) {
        [self.navigationController pushViewController:addressViewController animated:YES];
    }
}
- (void)p_selectChangeAddress:(CBWAddress *)address {
    if ([self.delegate respondsToSelector:@selector(addressListViewController:didSelectAddress:)]) {
        [self.delegate addressListViewController:self didSelectAddress:address];
    }
    [self.navigationController popViewControllerAnimated:YES];
}
- (void)p_pushToAddress:(CBWAddress *)address {
    if (AddressActionTypeReceive == self.actionType) {
        AddressExplorerViewController *addressViewController = [[AddressExplorerViewController alloc] initWithAddress:address actionType:self.actionType];
        if (addressViewController) {
            [self.navigationController pushViewController:addressViewController animated:YES];
        }
    } else {
        AddressViewController *addressViewController = [[AddressViewController alloc] initWithAddress:address actionType:self.actionType];
        if (addressViewController) {
            [self.navigationController pushViewController:addressViewController animated:YES];
        }
    }
}
#pragma mark - <UITableViewDataSource>
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    NSInteger actionSectionNumber = 0;
    if (self.actionCells.count > 0) {
        actionSectionNumber = 1;
    }
    NSInteger addressSectionNumber = 0;
    if (self.addressStore.count > 0) {
        addressSectionNumber = 1;
    }
    return actionSectionNumber + addressSectionNumber;
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
    CBWAddress *address = [self.addressStore recordAtIndex:indexPath.row];
    [cell setAddress:address];
    // if used to send, check mark
    if (self.actionType == AddressActionTypeSend) {
        if ([self.selectedAddress containsObject:address]) {
            cell.accessoryType = UITableViewCellAccessoryCheckmark;
        } else {
            cell.accessoryType = UITableViewCellAccessoryNone;
        }
    }
    return cell;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    if (self.actionType == AddressActionTypeChange && section == 1) {
        return NSLocalizedStringFromTable(@"Address Section change_address", @"CBW", @"Address");
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
//            [self p_handleCreateAddress:nil];
            if (self.actionType == AddressActionTypeChange) {
                [self p_selectChangeAddress:nil];
            }
            return;
        }
    }
    CBWAddress *address = [self.addressStore recordAtIndex:indexPath.row];
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
            if (address.balance > 0) {
                [self.selectedAddress addObject:address];
                cell.accessoryType = UITableViewCellAccessoryCheckmark;
                if ([self.delegate respondsToSelector:@selector(addressListViewController:didSelectAddress:)]) {
                    [self.delegate addressListViewController:self didSelectAddress:address];
                }
            }
        }
        if (self.selectedAddress.count == 0) {
            self.title = NSLocalizedStringFromTable(@"Navigation select_address", @"CBW", @"Select Address");
        } else {
            __block long long balance = 0;
            [self.selectedAddress enumerateObjectsUsingBlock:^(CBWAddress * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                balance += obj.balance;
            }];
            self.title = [NSString stringWithFormat:NSLocalizedStringFromTable(@"Navigation select_balance_%@", @"CBW", nil), [@(balance) satoshiBTCString]];
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

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    return YES;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        [self reportActivity:@"cellEditingDelete"];
        
        CBWAddress *address = [self.addressStore recordAtIndex:indexPath.row];
        if (self.account.idx == CBWRecordWatchedIDX) {
            // delete
            [address deleteWatchedAddressFromStore:self.addressStore];
        } else {
            address.archived = YES;
            [address saveWithError:nil];
            self.archivedListButtonItem.image = [UIImage imageNamed:@"navigation_archived"];
        }
        // TODO: handle errors
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    }
}

- (NSString *)tableView:(UITableView *)tableView titleForDeleteConfirmationButtonForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (self.account.idx != CBWRecordWatchedIDX) {
        return NSLocalizedStringFromTable(@"Button archive", @"CBW", nil);
    }
    return NSLocalizedStringFromTable(@"Button delete", @"CBW", nil);
}

#pragma mark - <ScanViewControllerDelegate>
- (BOOL)scanViewControllerWillDismiss:(ScanViewController *)viewController {
    [self dismissViewControllerAnimated:YES completion:nil];
    return YES;
}

- (void)scanViewController:(ScanViewController *)viewController didScanString:(NSString *)string {
    [self dismissViewControllerAnimated:YES completion:nil];
    // decode qr code string
    NSDictionary *addressInfo = [string addressInfo];
    if (!addressInfo) {
        [self alertMessageWithInvalidAddress:nil];
        return;
    }
    // check address
    NSString *addressString = [addressInfo objectForKey:CBWAddressInfoAddressKey];
    if (![CBWAddress validateAddressString:addressString]) {
        [self alertMessageWithInvalidAddress:addressString];
    }
    // save
    [self p_saveAddressString:addressString withIdx:CBWRecordWatchedIDX label:[addressInfo objectForKey:CBWAddressInfoLabelKey]];
}

@end
