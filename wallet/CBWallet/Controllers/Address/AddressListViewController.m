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

#import "Address.h"

@interface AddressListViewController ()

@property (nonatomic, strong) NSArray * _Nullable datas; // action button section (optional) + addresses section
@property (nonatomic, strong) NSMutableArray * _Nullable addresses; // of Address

@end

@implementation AddressListViewController

#pragma mark - Property
- (NSMutableArray *)addresses {
    if (!_addresses) {
        _addresses = [[NSMutableArray alloc] init];
    }
    return _addresses;
}

#pragma mark - View Life Cycle

- (void)viewDidLoad {
    [super viewDidLoad];
    
    switch (self.actionType) {
        case AddressActionTypeDefault: {
            self.title = NSLocalizedStringFromTable(@"Navigation AddressList", @"CBW", @"Address List");
            self.navigationItem.rightBarButtonItems = @[[[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"navigation_archived_empty"] style:UIBarButtonItemStylePlain target:self action:@selector(p_handleArchivedAddressList:)],
                                                        [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"navigation_create"] style:UIBarButtonItemStylePlain target:self action:@selector(p_handleCreateAddress:)]];
            _datas = @[self.addresses];
            break;
        }
        case AddressActionTypeReceive: {
            self.title = NSLocalizedStringFromTable(@"Navigation SelectAddress", @"CBW", @"Select Address to Receive");
            _datas = @[@[NSLocalizedStringFromTable(@"Address Cell NewAddress", @"CBW", @"New Address")], self.addresses];
            break;
        }
    }
    
    // test, fake data
    for (NSInteger i = 0 ; i < 20; i++) {
        [self.addresses addObject:[Address new]];
    }
}

#pragma mark - Private Method
#pragma mark Handlers
- (void)p_handleCreateAddress:(id)sender {
    Address *address = [Address new];
    [self.addresses insertObject:address atIndex:0];
    [self.tableView insertRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:0 inSection:self.datas.count - 1]] withRowAnimation:UITableViewRowAnimationAutomatic];
    [self p_selectAddress:address];
}
- (void)p_handleArchivedAddressList:(id)sender {
    ArchivedAdressListViewController *archivedAddressListViewController = [[ArchivedAdressListViewController alloc] init];
    [self.navigationController pushViewController:archivedAddressListViewController animated:YES];
}
#pragma mark -
- (void)p_selectAddress:(Address *)address {
    if (!address) {
        // TODO: handle miss address error
        return;
    }
    AddressViewController *addressViewController = [[AddressViewController alloc] initWithAddress:address actionType:self.actionType];
    if (addressViewController) {
        [self.navigationController pushViewController:addressViewController animated:YES];
    }
}

#pragma mark - UITableViewDataSource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return self.datas.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    id rowsData = self.datas[section];
    if ([rowsData isKindOfClass:[NSArray class]]) {
        return [rowsData count];
    }
    return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    id rowsData = self.datas[indexPath.section];
    if ([rowsData isKindOfClass:[NSArray class]]) {
        id data = rowsData[indexPath.row];
        if ([data isKindOfClass:[NSString class]]) {
            // action section
            ActionButtonCell *cell = [tableView dequeueReusableCellWithIdentifier:BaseTableViewCellActionIdentifier forIndexPath:indexPath];
            cell.imageView.image = [UIImage imageNamed:@"icon_create_mini"];
            cell.textLabel.text = data;
            return cell;
        } else if ([data isKindOfClass:[Address class]]) {
            // address section
            AddressCell *cell = [tableView dequeueReusableCellWithIdentifier:BaseListViewCellAddressIdentifier forIndexPath:indexPath];
            [cell setMetadataHidden:(self.actionType != AddressActionTypeDefault)];
            [cell setAddress:data];
            return cell;
        }
    }
    // empty cell
    DefaultTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:BaseTableViewCellDefaultIdentifier forIndexPath:indexPath];
    cell.textLabel.text = @"NaN";
    
    return cell;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    if (self.actionType == AddressActionTypeReceive && section == 1) {
        return NSLocalizedStringFromTable(@"Address Section ReceiveAddress", @"CBW", @"Address");
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
    id rowsData = self.datas[indexPath.section];
    if ([rowsData isKindOfClass:[NSArray class]]) {
        id data = rowsData[indexPath.row];
        if ([data isKindOfClass:[NSString class]]) {
            // action section
            [self p_handleCreateAddress:nil];
        } else if ([data isKindOfClass:[Address class]]) {
            // address section
            [self p_selectAddress:data];
        }
    }
}

@end
