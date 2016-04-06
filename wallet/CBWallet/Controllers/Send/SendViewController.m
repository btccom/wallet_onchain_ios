//
//  SendViewController.m
//  wallet
//
//  Created by Zin (noteon.com) on 16/2/15.
//  Copyright © 2016年 Bitmain. All rights reserved.
//
// TODO: cache the recipient

#import "SendViewController.h"
#import "ScanViewController.h"

#import "FormControlStaticArrowCell.h"
#import "SendFromAddressCell.h"
#import "SendToAddressCell.h"
#import "FormControlInputCell.h"
#import "FormControlInputActionCell.h"

#import "Address.h"

#import "NSString+CBWAddress.h"

typedef NS_ENUM(NSUInteger, kSendViewControllerQuicklySection) {
    kSendViewControllerQuicklySectionInput,
    kSendViewControllerQuicklySectionButton
};

typedef NS_ENUM(NSUInteger, kSendViewControllerAdvancedSection) {
    kSendViewControllerAdvancedSectionFrom,
    kSendViewControllerAdvancedSectionTo,
    kSendViewControllerAdvancedSectionInput,
    kSendViewControllerAdvancedSectionChange,
    kSendViewControllerAdvancedSectionFee,
    kSendViewControllerAdvancedSectionButton
};

// for quick
/// FormControlInputActionCell
static NSString *const kSendViewControllerCellQuicklyAddressIdentifier = @"quickly.cell.address";
/// FormControlInputCell
static NSString *const kSendViewControllerCellQuicklyAmountIdentifier = @"quickly.cell.amount";
// for advanced
/// SendFromAddressCell
static NSString *const kSendViewControllerCellAdvancedFromAddressIdentifier = @"advnaced.cell.from.address";
/// SendToAddressCell
static NSString *const kSendViewControllerCellAdvancedToAddressIdentifier = @"advnaced.cell.to.address";
/// FormControlInputActionCell
static NSString *const kSendViewControllerCellAdvancedToAddressInputIdentifier = @"advanced.cell.to.address.input";
/// FormControlInputActionCell
static NSString *const kSendViewControllerCellAdvancedToAmountInputIdentifier = @"advanced.cell.to.amount.input";
/// AddressCell
static NSString *const kSendViewControllerCellAdvancedChangeIdentifier = @"advanced.cell.change";
/// FormControlStaticArrowCell
static NSString *const kSendViewControllerCellAdvancedFeeIdentifier = @"advanced.cell.fee";

@interface SendViewController ()<UITextFieldDelegate, ScanViewControllerDelegate>

@property (nonatomic, weak) FormControlInputActionCell *quicklyAddressCell;
@property (nonatomic, weak) FormControlInputCell *quicklyAmountCell;
@property (nonatomic, weak) FormControlBlockButtonCell *quicklySendButtonCell;

@property (nonatomic, strong) NSArray *advancedSectionTitles;
@property (nonatomic, strong) NSMutableArray *advancedFromAddresses;
@property (nonatomic, strong) NSMutableArray<Address *> *advancedToDatas;
@property (nonatomic, weak) FormControlInputActionCell *advancedToAddressCell;
@property (nonatomic, weak) FormControlInputActionCell *advancedToAmountCell;
@property (nonatomic, weak) FormControlBlockButtonCell *advancedSendButtonCell;

@property (nonatomic, strong) Address *changeAddress;// new address as default
@property (nonatomic, assign) long long fee;// medium as default

@end

@implementation SendViewController

- (NSMutableArray *)advancedFromAddresses {
    if (!_advancedFromAddresses) {
        _advancedFromAddresses = [[NSMutableArray alloc] init];
    }
    return _advancedFromAddresses;
}

- (NSMutableArray *)advancedToDatas {
    if (!_advancedToDatas) {
        _advancedToDatas = [[NSMutableArray alloc] init];
    }
    return _advancedToDatas;
}

#pragma mark - View Life Cycle
- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = NSLocalizedStringFromTable(@"Navigation send", @"CBW", @"Quickly Send");
    
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedStringFromTable(@"Navigation advanced_send", @"CBW", @"Advanced Send") style:UIBarButtonItemStylePlain target:self action:@selector(p_handleSwitchMode:)];
    
    _advancedSectionTitles = @[NSLocalizedStringFromTable(@"Send Section from", @"CBW", nil),
                               NSLocalizedStringFromTable(@"Send Section to", @"CBW", nil),
                               @"",
                               NSLocalizedStringFromTable(@"Send Section change", @"CBW", nil),
                               NSLocalizedStringFromTable(@"Send Section fee", @"CBW", nil),
                               @""];
    
    // quickly form
    [self.tableView registerClass:[FormControlInputActionCell class] forCellReuseIdentifier:kSendViewControllerCellQuicklyAddressIdentifier];
    [self.tableView registerClass:[FormControlInputCell class] forCellReuseIdentifier:kSendViewControllerCellQuicklyAmountIdentifier];
    // advanced form
    [self.tableView registerClass:[SendFromAddressCell class] forCellReuseIdentifier:kSendViewControllerCellAdvancedFromAddressIdentifier];
    [self.tableView registerClass:[SendToAddressCell class] forCellReuseIdentifier:kSendViewControllerCellAdvancedToAddressIdentifier];
    [self.tableView registerClass:[FormControlInputActionCell class] forCellReuseIdentifier:kSendViewControllerCellAdvancedToAddressInputIdentifier];
    [self.tableView registerClass:[FormControlInputActionCell class] forCellReuseIdentifier:kSendViewControllerCellAdvancedToAmountInputIdentifier];
    [self.tableView registerClass:[AddressCell class] forCellReuseIdentifier:kSendViewControllerCellAdvancedChangeIdentifier];
    [self.tableView registerClass:[FormControlStaticArrowCell class] forCellReuseIdentifier:kSendViewControllerCellAdvancedFeeIdentifier];

}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // TODO: cache the send data
}

#pragma mark - Private Method

#pragma mark Handlers

/// clicked navigation right button to switch mode
- (void)p_handleSwitchMode:(id)sender {
    [self.tableView beginUpdates];
    switch (self.mode) {
        case SendViewControllerModeQuickly: {
            // to advanced
            self.mode = SendViewControllerModeAdvanced;
            self.title = NSLocalizedStringFromTable(@"Navigation advanced_send", @"CBW", @"Advanced Send");
            self.navigationItem.rightBarButtonItem.title = NSLocalizedStringFromTable(@"Navigation quickly_send", @"CBW", @"Quickly Send");
            
            [self.tableView reloadSections:[NSIndexSet indexSetWithIndexesInRange:NSMakeRange(0, 2)] withRowAnimation:UITableViewRowAnimationAutomatic];
            [self.tableView insertSections:[NSIndexSet indexSetWithIndexesInRange:NSMakeRange(2, 4)] withRowAnimation:UITableViewRowAnimationFade];
            
            break;
        }
        case SendViewControllerModeAdvanced: {
            // to quickly
            self.mode = SendViewControllerModeQuickly;
            self.title = NSLocalizedStringFromTable(@"Navigation send", @"CBW", @"Quickly Send");
            self.navigationItem.rightBarButtonItem.title = NSLocalizedStringFromTable(@"Navigation advanced_send", @"CBW", @"Advanced Send");
            
            [self.tableView reloadSections:[NSIndexSet indexSetWithIndexesInRange:NSMakeRange(0, 2)] withRowAnimation:UITableViewRowAnimationAutomatic];
            [self.tableView deleteSections:[NSIndexSet indexSetWithIndexesInRange:NSMakeRange(2, 4)] withRowAnimation:UITableViewRowAnimationFade];
            
            break;
        }
    }
    [self.tableView endUpdates];
    
//    // reload table view
//    [UIView animateWithDuration:CBWAnimateDurationFast animations:^{
//        self.tableView.alpha = 0;
//    } completion:^(BOOL finished) {
//        [self.tableView reloadData];
//        [UIView animateWithDuration:CBWAnimateDurationFast animations:^{
//            self.tableView.alpha = 1.f;
//        } completion:nil];
//    }];
}

/// clicked send button
- (void)p_handleSend:(id)sender {
    NSLog(@"handle send");
    [self.view endEditing:YES];
}

///
- (void)p_handleAddAdvancedToData:(id)sender {
    DLog(@"handle add advanced to data");
    [self.view endEditing:YES];
    
    __block BOOL duplicated = NO;
    [self.advancedToDatas enumerateObjectsUsingBlock:^(Address * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if ([self.advancedToAddressCell.textField.text isEqualToString:obj.address]) {
            duplicated = YES;
            *stop = YES;
        }
    }];
    if (duplicated) {
        // TODO: 错误提示，重复地址不同金额可以相加或替换
        return;
    }
    
    Address *address = [Address new];
    address.address = self.advancedToAddressCell.textField.text;
    address.balance = [@(self.advancedToAmountCell.textField.text.doubleValue * 100000000.0) longLongValue];
    [self.advancedToDatas addObject:address];
    [self.tableView beginUpdates];
    [self.tableView insertRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:self.advancedToDatas.count - 1 inSection:kSendViewControllerAdvancedSectionTo]] withRowAnimation:((self.advancedToDatas.count > 1) ? UITableViewRowAnimationTop : UITableViewRowAnimationFade)];
    self.advancedToAddressCell.textField.text = nil;
    self.advancedToAmountCell.textField.text = nil;
    [self p_editingChanged:self.advancedToAmountCell.textField];
//    [self.tableView reloadSections:[NSIndexSet indexSetWithIndex:kSendViewControllerAdvancedSectionInput] withRowAnimation:UITableViewRowAnimationFade];
    [self.tableView endUpdates];
    
    [self p_checkIfSendButtonEnabled];
}

/// click scan
- (void)p_handleScan:(id)sender {
    DLog(@"handle scan");
    [self.view endEditing:YES];
    
    ScanViewController *scanViewController = [[ScanViewController alloc] init];
    scanViewController.delegate = self;
    [self presentViewController:scanViewController animated:YES completion:nil];
    
}

- (BOOL)p_editingChanged:(id)sender {
    BOOL valid = YES;
    if ([sender isEqual:self.quicklyAddressCell.textField] || [sender isEqual:self.quicklyAmountCell.textField]) {
        valid = [self p_checkIfSendButtonEnabled];
    } else if ([sender isEqual:self.advancedToAddressCell.textField] || [sender isEqual:self.advancedToAmountCell.textField]) {
        NSString *address = [self.advancedToAddressCell.textField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
        valid = address.length > 0 && valid;
        double value = [[self.advancedToAmountCell.textField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]] doubleValue];
        valid = value > 0 && valid;
        DLog(@"address: %@, value: %f", address, value);
        self.advancedToAmountCell.actionButton.enabled = valid;
    }
    return valid;
}
- (void)p_handleDeleteAdvancedToData:(id)sender {
    SendToAddressCellDeleteButton *button = sender;
    NSIndexPath *indexPath = [self.tableView indexPathForCell:button.cell];
    [self.advancedToDatas removeObjectAtIndex:indexPath.row];
    [self.tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationBottom];
    [self p_checkIfSendButtonEnabled];
}

///
- (BOOL)p_checkIfSendButtonEnabled {
    BOOL valid = YES;
    switch (self.mode) {
        case SendViewControllerModeQuickly: {
            valid = valid && self.quicklyAddressCell.textField.text.length > 0;
            valid = valid && self.quicklyAmountCell.textField.text.length > 0;
            self.quicklySendButtonCell.enabled = valid;
            break;
        }
            
        case SendViewControllerModeAdvanced: {
            valid = valid && self.advancedToDatas.count > 0;
            self.advancedSendButtonCell.enabled = valid;
            break;
        }
    }
    return valid;
}

#pragma mark - TableViewDataSource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    NSInteger number = 0;
    switch (self.mode) {
        case SendViewControllerModeQuickly:
            number = 2; // input, button
            break;
            
        case SendViewControllerModeAdvanced:
            number = 6; // from, to, input, change, fee, button
            break;
    }
    return number;
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    NSInteger number = 1;
    switch (self.mode) {
        case SendViewControllerModeQuickly: {
            // quickly
            switch (section) {
                case kSendViewControllerQuicklySectionInput: {
                    // input
                    number = 2; // address, value
                    break;
                }
                default:
                    // buton
                    break;
            }
            break;
        }
        case SendViewControllerModeAdvanced: {
            // advanced
            switch (section) {
                case kSendViewControllerAdvancedSectionFrom: {
                    // from
                    break;
                }
                case kSendViewControllerAdvancedSectionTo: {
                    // to
                    number = self.advancedToDatas.count;
                    break;
                }
                case kSendViewControllerAdvancedSectionInput: {
                    // input
                    number = 2; // address, value
                    break;
                }
                case kSendViewControllerAdvancedSectionChange: {
                    // change
                    break;
                }
                case kSendViewControllerAdvancedSectionFee: {
                    // fee
                    break;
                }
                default:
                    // button
                    break;
            }
            break;
        }
    }
    return number;
}
- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    // quickly
    if (self.mode == SendViewControllerModeQuickly) {
        if (section == 0) {
            return @" "; // 对齐
        }
        return nil;
    }
    
    // advanced
    return self.advancedSectionTitles[section];
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = nil;
    
    switch (self.mode) {
        case SendViewControllerModeQuickly: {
            switch (indexPath.section) {
                case kSendViewControllerQuicklySectionInput: {
                    // quickly input
                    switch (indexPath.row) {
                        case 0: {
                            // address
                            FormControlInputActionCell *quicklyAddressCell = [tableView dequeueReusableCellWithIdentifier:kSendViewControllerCellQuicklyAddressIdentifier];
                            quicklyAddressCell.imageView.image = [UIImage imageNamed:@"icon_label_mini"];
                            quicklyAddressCell.textField.placeholder = NSLocalizedStringFromTable(@"Placeholder bitcoin_address", @"CBW", nil);
                            [quicklyAddressCell.textField addTarget:self action:@selector(p_editingChanged:) forControlEvents:UIControlEventEditingChanged];
                            quicklyAddressCell.textField.delegate = self;
                            quicklyAddressCell.textField.returnKeyType = UIReturnKeyNext;
                            quicklyAddressCell.inputType = FormControlInputTypeBitcoinAddress;
                            [quicklyAddressCell.actionButton setImage:[UIImage imageNamed:@"icon_scan_mini"] forState:UIControlStateNormal];
                            [quicklyAddressCell.actionButton addTarget:self action:@selector(p_handleScan:) forControlEvents:UIControlEventTouchUpInside];
                            self.quicklyAddressCell = quicklyAddressCell;
                            cell = quicklyAddressCell;
                            break;
                        }
                        case 1: {
                            // amount
                            FormControlInputCell *quicklyAmountCell = [tableView dequeueReusableCellWithIdentifier:kSendViewControllerCellQuicklyAmountIdentifier];
                            quicklyAmountCell.imageView.image = [UIImage imageNamed:@"icon_coin_mini"];
                            quicklyAmountCell.textField.placeholder = NSLocalizedStringFromTable(@"Placeholder value", @"CBW", @"Value or Amount?");
                            [quicklyAmountCell.textField addTarget:self action:@selector(p_editingChanged:) forControlEvents:UIControlEventEditingChanged];
                            quicklyAmountCell.textField.delegate = self;
//                            quicklyValueCell.textField.returnKeyType = UIReturnKeyDone;
                            quicklyAmountCell.inputType = FormControlInputTypeBitcoinAmount;
                            self.quicklyAmountCell = quicklyAmountCell;
                            cell = quicklyAmountCell;
                            break;
                        }
                    }
                    break;
                }
                case kSendViewControllerQuicklySectionButton: {
                    // quickly button
                    FormControlBlockButtonCell *buttonCell = [tableView dequeueReusableCellWithIdentifier:BaseTableViewCellBlockButtonIdentifier];
                    buttonCell.textLabel.text = NSLocalizedStringFromTable(@"Button send", @"CBW", nil);;
                    self.quicklySendButtonCell = buttonCell;
                    [self p_checkIfSendButtonEnabled];
                    cell = buttonCell;
                    break;
                }
            }
            break;
        }
            
        case SendViewControllerModeAdvanced: {
            switch (indexPath.section) {
                case kSendViewControllerAdvancedSectionFrom: {
                    // advanced from
                    SendFromAddressCell *advancedFromAddressCell = [tableView dequeueReusableCellWithIdentifier:kSendViewControllerCellAdvancedFromAddressIdentifier];
//                    advancedFromAddressCell.textLabel.text = @"from";
                    [advancedFromAddressCell setAddresses:@[@"Label", @"1ABfjldaogl3lLKFJDOlagfsagLFLAWGLFDJLGKLFDSGJLGKLsafag"]];
                    cell = advancedFromAddressCell;
                    break;
                }
                case kSendViewControllerAdvancedSectionTo: {
                    // advanced to
                    SendToAddressCell *advancedToAddressCell = [tableView dequeueReusableCellWithIdentifier:kSendViewControllerCellAdvancedToAddressIdentifier];
                    advancedToAddressCell.imageView.image = [UIImage imageNamed:@"icon_delete_mini"];
                    [advancedToAddressCell.deleteButton addTarget:self action:@selector(p_handleDeleteAdvancedToData:) forControlEvents:UIControlEventTouchUpInside];
                    Address *address = self.advancedToDatas[indexPath.row];
                    [advancedToAddressCell setAddress:address];
                    cell = advancedToAddressCell;
                    break;
                }
                case kSendViewControllerAdvancedSectionInput: {
                    // advanced input
                    FormControlInputActionCell *inputCell = nil;
                    switch (indexPath.row) {
                        case 0: {
                            // advanced input address
                            inputCell = [tableView dequeueReusableCellWithIdentifier:kSendViewControllerCellAdvancedToAddressInputIdentifier];
                            inputCell.imageView.image = [UIImage imageNamed:@"icon_label_mini"];
                            inputCell.textField.placeholder = NSLocalizedStringFromTable(@"Placeholder new_address", @"CBW", @"New Address");
                            inputCell.textField.returnKeyType = UIReturnKeyNext;
                            inputCell.inputType = FormControlInputTypeBitcoinAddress;
                            [inputCell.actionButton setImage:[UIImage imageNamed:@"icon_scan_mini"] forState:UIControlStateNormal];
                            [inputCell.actionButton addTarget:self action:@selector(p_handleScan:) forControlEvents:UIControlEventTouchUpInside];
                            self.advancedToAddressCell = inputCell;
                            break;
                        }
                            
                        case 1: {
                            // advanced input amount
                            inputCell = [tableView dequeueReusableCellWithIdentifier:kSendViewControllerCellAdvancedToAmountInputIdentifier];
                            inputCell.imageView.image = [UIImage imageNamed:@"icon_coin_mini"];
                            inputCell.textField.placeholder = NSLocalizedStringFromTable(@"Placeholder value", @"CBW", @"Value or Amount?");
//                            inputCell.textField.returnKeyType = UIReturnKeyDone;
                            inputCell.inputType = FormControlInputTypeBitcoinAmount;
                            [inputCell.actionButton setTitle:NSLocalizedStringFromTable(@"Send Cell add_recipient", @"CBW", @"Add Recipient") forState:UIControlStateNormal];
                            [inputCell.actionButton addTarget:self action:@selector(p_handleAddAdvancedToData:) forControlEvents:UIControlEventTouchUpInside];
                            self.advancedToAmountCell = inputCell;
                            break;
                        }
                    }
                    inputCell.textField.delegate = self;
                    [inputCell.textField addTarget:self action:@selector(p_editingChanged:) forControlEvents:UIControlEventEditingChanged];
                    [self p_editingChanged:inputCell.textField];
                    cell = inputCell;
                    break;
                }
                case kSendViewControllerAdvancedSectionChange: {
                    // advanced change
                    AddressCell *advancedChangeCell = [tableView dequeueReusableCellWithIdentifier:kSendViewControllerCellAdvancedChangeIdentifier];
                    advancedChangeCell.labelLabel.text = @"Address Label";
                    advancedChangeCell.addressLabel.text = @"1ABCDEFGHIJKLMNOPQRSTUVWXYZ";
                    cell = advancedChangeCell;
                    break;
                }
                case kSendViewControllerAdvancedSectionFee: {
                    // advanced fee
                    FormControlStaticArrowCell *advancedFeeCell = [tableView dequeueReusableCellWithIdentifier:kSendViewControllerCellAdvancedFeeIdentifier];
                    advancedFeeCell.textLabel.text = [@10000 satoshiBTCString];
                    advancedFeeCell.detailTextLabel.text = NSLocalizedStringFromTable(@"Send Fee minimum", @"CBW", nil);
                    cell = advancedFeeCell;
                    break;
                }
                case kSendViewControllerAdvancedSectionButton: {
                    // advanced button
                    FormControlBlockButtonCell *buttonCell = [tableView dequeueReusableCellWithIdentifier:BaseTableViewCellBlockButtonIdentifier];
                    buttonCell.textLabel.text = NSLocalizedStringFromTable(@"Button send", @"CBW", nil);
                    self.advancedSendButtonCell = buttonCell;
                    [self p_checkIfSendButtonEnabled];
                    cell = buttonCell;
                    break;
                }
            }
            break;
        }
    }
    
    
    return cell;
}

#pragma mark <UITableViewDelegate>
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    if (section == kSendViewControllerAdvancedSectionInput) {
        return CGFLOAT_MIN;
    }
    return [super tableView:tableView heightForHeaderInSection:section];
}
- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    if (self.mode == SendViewControllerModeAdvanced) {
        if (section == kSendViewControllerAdvancedSectionTo) {
            return CGFLOAT_MIN;
        }
    }
    return 0;// default
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (self.mode == SendViewControllerModeAdvanced) {
        if (indexPath.section == kSendViewControllerAdvancedSectionTo) {
            return CBWCellHeightAddressWithMetadata;
        }
    }
    return [super tableView:tableView heightForRowAtIndexPath:indexPath];
}
- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    DefaultSectionHeaderView *headerView = (DefaultSectionHeaderView *)[super tableView:tableView viewForHeaderInSection:section];
    headerView.topHairlineHidden = YES;
    return headerView;
}

#pragma mark - <UITextFieldDelegate>
- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    if ([textField isEqual:self.quicklyAddressCell.textField]) {
        [self.quicklyAmountCell.textField becomeFirstResponder];
    } else if ([textField isEqual:self.quicklyAmountCell.textField]) {
        [self.quicklyAmountCell.textField resignFirstResponder];
        if ([self p_checkIfSendButtonEnabled]) {
            [self p_handleSend:nil];
        }
    } else if ([textField isEqual:self.advancedToAddressCell.textField]) {
        [self.advancedToAmountCell.textField becomeFirstResponder];
    } else if ([textField isEqual:self.advancedToAmountCell.textField]) {
        [self.advancedToAmountCell.textField resignFirstResponder];
        if ([self p_editingChanged:textField]) {
            [self p_handleAddAdvancedToData:nil];
        }
    }
    return YES;
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
    DLog(@"send scan address info: %@", addressInfo);
    NSString *address = [addressInfo objectForKey:NSStringAddressInfoAddressKey];
    NSString *amount = [addressInfo objectForKey:NSStringAddressInfoAmountKey];
    
    switch (self.mode) {
        case SendViewControllerModeQuickly: {
            self.quicklyAddressCell.textField.text = address;
            self.quicklyAmountCell.textField.text = amount;
            [self p_checkIfSendButtonEnabled];
            break;
        }
        case SendViewControllerModeAdvanced: {
            self.advancedToAddressCell.textField.text = address;
            self.advancedToAmountCell.textField.text = amount;            [self p_editingChanged:self.advancedToAmountCell.textField];
            break;
        }
    }
    
}

@end
