//
//  SendViewController.m
//  wallet
//
//  Created by Zin (noteon.com) on 16/2/15.
//  Copyright © 2016年 Bitmain. All rights reserved.
//

#import "SendViewController.h"
#import "FormControlStaticAddressCell.h"
#import "FormControlInputCell.h"
#import "FormControlInputActionCell.h"

#import "Address.h"

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
static NSString *const kSendViewControllerCellQuicklyValueIdentifier = @"quickly.cell.value";
// for advanced
/// FormControlStaticAddressCell
static NSString *const kSendViewControllerCellAdvancedFromAddressIdentifier = @"advnaced.cell.from.address";
/// FormControlStaticAddressCell
static NSString *const kSendViewControllerCellAdvancedToAddressIdentifier = @"advnaced.cell.to.address";
/// FormControlInputActionCell
static NSString *const kSendViewControllerCellAdvancedToAddressInputIdentifier = @"advanced.cell.to.address.input";
/// FormControlStaticAddressCell
static NSString *const kSendViewControllerCellAdvancedChangeIdentifier = @"advanced.cell.change";
/// FormControlStaticCell
static NSString *const kSendViewControllerCellAdvancedFeeIdentifier = @"advanced.cell.fee";

@interface SendViewController ()

@property (nonatomic, strong) NSMutableArray *advancedFromAddresses;
@property (nonatomic, strong) NSMutableArray *advancedToDatas;
@property (nonatomic, strong) Address *changeAddress;
@property (nonatomic, assign) long long fee;
@property (nonatomic, strong) NSArray *advancedSectionTitles;

@end

@implementation SendViewController

#pragma mark - View Life Cycle
- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = NSLocalizedStringFromTable(@"Navigation send", @"CBW", @"Quickly Send");
    
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedStringFromTable(@"Navigation advanced_send", @"CBW", @"Advanced Send") style:UIBarButtonItemStylePlain target:self action:@selector(p_handleSwitchMode:)];
    
    _advancedSectionTitles = @[NSLocalizedStringFromTable(@"Send Cell from", @"CBW", nil),
                               NSLocalizedStringFromTable(@"Send Cell to", @"CBW", nil),
                               @"",
                               NSLocalizedStringFromTable(@"Send Cell change", @"CBW", nil),
                               NSLocalizedStringFromTable(@"Send Cell fee", @"CBW", nil),
                               @""];
    
    // quickly form
    [self.tableView registerClass:[FormControlInputActionCell class] forCellReuseIdentifier:kSendViewControllerCellQuicklyAddressIdentifier];
    [self.tableView registerClass:[FormControlInputCell class] forCellReuseIdentifier:kSendViewControllerCellQuicklyValueIdentifier];
    // advanced form
    [self.tableView registerClass:[FormControlStaticAddressCell class] forCellReuseIdentifier:kSendViewControllerCellAdvancedFromAddressIdentifier];
    [self.tableView registerClass:[FormControlStaticAddressCell class] forCellReuseIdentifier:kSendViewControllerCellAdvancedToAddressIdentifier];
    [self.tableView registerClass:[FormControlInputActionCell class] forCellReuseIdentifier:kSendViewControllerCellAdvancedToAddressInputIdentifier];
    [self.tableView registerClass:[FormControlStaticAddressCell class] forCellReuseIdentifier:kSendViewControllerCellAdvancedChangeIdentifier];
    [self.tableView registerClass:[FormControlStaticCell class] forCellReuseIdentifier:kSendViewControllerCellAdvancedFeeIdentifier];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // TODO: cache the send data
}

#pragma mark - Private Method

#pragma mark Handlers

/// clicked navigation right button to switch mode
- (void)p_handleSwitchMode:(id)sender {
    switch (self.mode) {
        case SendViewControllerModeQuickly: {
            // to advanced
            self.mode = SendViewControllerModeAdvanced;
            self.title = NSLocalizedStringFromTable(@"Navigation advanced_send", @"CBW", @"Advanced Send");
            self.navigationItem.rightBarButtonItem.title = NSLocalizedStringFromTable(@"Navigation send", @"CBW", @"Quickly Send");
            break;
        }
        case SendViewControllerModeAdvanced: {
            // to quickly
            self.mode = SendViewControllerModeQuickly;
            self.title = NSLocalizedStringFromTable(@"Navigation send", @"CBW", @"Quickly Send");
            self.navigationItem.rightBarButtonItem.title = NSLocalizedStringFromTable(@"Navigation advanced_send", @"CBW", @"Advanced Send");
            break;
        }
    }
    
    // reload table view
    [UIView animateWithDuration:CBWAnimateDurationFast animations:^{
        self.tableView.alpha = 0;
    } completion:^(BOOL finished) {
        [self.tableView reloadData];
        [UIView animateWithDuration:CBWAnimateDurationFast animations:^{
            self.tableView.alpha = 1.f;
        } completion:nil];
    }];
}

/// clicked send button
- (void)p_handleSend:(id)sender {
    
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
                            quicklyAddressCell.textField.placeholder = @"address";
                            cell = quicklyAddressCell;
                            break;
                        }
                        case 1: {
                            // value
                            FormControlInputCell *quicklyValueCell = [tableView dequeueReusableCellWithIdentifier:kSendViewControllerCellQuicklyValueIdentifier];
                            quicklyValueCell.textField.placeholder = @"value";
                            cell = quicklyValueCell;
                            break;
                        }
                    }
                    break;
                }
                case kSendViewControllerQuicklySectionButton: {
                    // quickly button
                    FormControlBlockButtonCell *buttonCell = [tableView dequeueReusableCellWithIdentifier:BaseTableViewCellBlockButtonIdentifier];
                    buttonCell.textLabel.text = @"send";
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
                    FormControlStaticAddressCell *advancedFromAddressCell = [tableView dequeueReusableCellWithIdentifier:kSendViewControllerCellAdvancedFromAddressIdentifier];
                    advancedFromAddressCell.textLabel.text = @"from";
                    cell = advancedFromAddressCell;
                    break;
                }
                case kSendViewControllerAdvancedSectionTo: {
                    // advanced to
                    FormControlStaticAddressCell *advancedToAddressCell = [tableView dequeueReusableCellWithIdentifier:kSendViewControllerCellAdvancedToAddressIdentifier];
                    advancedToAddressCell.textLabel.text = @"to";
                    cell = advancedToAddressCell;
                    break;
                }
                case kSendViewControllerAdvancedSectionInput: {
                    // advanced input
                    FormControlInputActionCell *inputCell = [tableView dequeueReusableCellWithIdentifier:kSendViewControllerCellAdvancedToAddressInputIdentifier];
                    inputCell.textField.placeholder = @"input";
                    cell = inputCell;
                    break;
                }
                case kSendViewControllerAdvancedSectionChange: {
                    // advanced change
                    FormControlStaticAddressCell *advancedChangeCell = [tableView dequeueReusableCellWithIdentifier:kSendViewControllerCellAdvancedChangeIdentifier];
                    advancedChangeCell.textLabel.text = @"change";
                    cell = advancedChangeCell;
                    break;
                }
                case kSendViewControllerAdvancedSectionFee: {
                    // advanced fee
                    FormControlStaticCell *advancedFeeCell = [tableView dequeueReusableCellWithIdentifier:kSendViewControllerCellAdvancedFeeIdentifier];
                    advancedFeeCell.textLabel.text = @"fee";
                    cell = advancedFeeCell;
                    break;
                }
                case kSendViewControllerAdvancedSectionButton: {
                    // advanced button
                    FormControlBlockButtonCell *buttonCell = [tableView dequeueReusableCellWithIdentifier:BaseTableViewCellBlockButtonIdentifier];
                    buttonCell.textLabel.text = @"send";
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
    if (section == kSendViewControllerAdvancedSectionTo) {
        return CGFLOAT_MIN;
    }
    return 0;// default
}
- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    DefaultSectionHeaderView *headerView = (DefaultSectionHeaderView *)[super tableView:tableView viewForHeaderInSection:section];
    headerView.topHairlineHidden = YES;
    return headerView;
}

@end
