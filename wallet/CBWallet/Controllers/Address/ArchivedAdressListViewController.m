//
//  ArchivedAdressListViewController.m
//  wallet
//
//  Created by Zin (noteon.com) on 16/2/25.
//  Copyright © 2016年 Bitmain. All rights reserved.
//

#import "ArchivedAdressListViewController.h"

#import "Database.h"

@interface ArchivedAdressListViewController ()

@property (nonatomic, strong) CBWAddressStore *addressStore;

@end

@implementation ArchivedAdressListViewController

#pragma mark - Property
- (CBWAddressStore *)addressStore {
    if (!_addressStore) {
        NSInteger accountIdx = -2;
        if (self.account) {
            accountIdx = self.account.idx;
        }
        _addressStore = [[CBWAddressStore alloc] initWithAccountIdx:accountIdx];
        _addressStore.archived = YES;
    }
    return _addressStore;
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
    
    self.title = NSLocalizedStringFromTable(@"Navigation archived_address_list", @"CBW", @"Archived Address List");
    
    [self.addressStore fetch];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    [self.tableView reloadData];
}

#pragma mark - Private Method

#pragma mark -
- (void)p_selectAddress:(CBWAddress *)address {
    AddressViewController *addressViewController = [[AddressViewController alloc] initWithAddress:address actionType:self.actionType];
    if (addressViewController) {
        [self.navigationController pushViewController:addressViewController animated:YES];
    }
}

#pragma mark - <UITableViewDataSource>
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.addressStore.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    AddressCell *cell = [tableView dequeueReusableCellWithIdentifier:BaseListViewCellAddressIdentifier forIndexPath:indexPath];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    [cell setMetadataHidden:(self.actionType != AddressActionTypeDefault)];
    CBWAddress *address = [self.addressStore recordAtIndex:indexPath.row];
    [cell setAddress:address];
    return cell;
}

#pragma mark <UITableViewDelgate>
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (self.actionType == AddressActionTypeDefault) {
        return CBWCellHeightAddressWithMetadata;
    }
    return CBWCellHeightAddress;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
//    CBWAddress *address = [self.addressStore recordAtIndex:indexPath.row];
//    [self p_selectAddress:address];
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    return YES;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        CBWAddress *address = [self.addressStore recordAtIndex:indexPath.row];
        address.archived = NO;
        [address saveWithError:nil];
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
        if (self.addressStore.count == 0) {
            [self.navigationController popViewControllerAnimated:YES];
        }
    }
}

- (NSString *)tableView:(UITableView *)tableView titleForDeleteConfirmationButtonForRowAtIndexPath:(NSIndexPath *)indexPath {
    return NSLocalizedStringFromTable(@"Button unarchive", @"CBW", nil);
}

@end
