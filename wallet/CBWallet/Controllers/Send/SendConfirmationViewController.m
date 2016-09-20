//
//  SendConfirmationViewController.m
//  CBWallet
//
//  Created by Zin on 16/8/15.
//  Copyright © 2016年 Bitmain. All rights reserved.
//

#import "SendConfirmationViewController.h"

#import "CBWRequest.h"
#import "Database.h"

#import "NSString+CBWAddress.h"

typedef NS_ENUM(NSUInteger, kSendConfirmationTableSection) {
    kSendConfirmationTableSectionAddresses,
    kSendConfirmationTableSectionFee,
    kSendConfirmationTableSectionButton
};

static NSString *const kSendConfirmationAddressCellIdentifier = @"confirmation.address";

@interface SendConfirmationViewController ()

@end

@implementation SendConfirmationViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"navigation_close"] style:UIBarButtonItemStylePlain target:self action:@selector(p_dismiss)];
    self.title = NSLocalizedStringFromTable(@"Navigation outgoing", @"CBW", nil);
    
    UILabel *balanceLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, 68)];
    balanceLabel.textColor = [UIColor CBWDangerColor];
    balanceLabel.font = [UIFont systemFontOfSize:32.f];
    balanceLabel.adjustsFontSizeToFitWidth = YES;
    balanceLabel.minimumScaleFactor = 0.5;
    balanceLabel.textAlignment = NSTextAlignmentCenter;
    self.tableView.tableHeaderView = balanceLabel;
    __block long long amount = self.fee;
    [self.toAddresses enumerateObjectsUsingBlock:^(CBWAddress * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        amount += obj.balance;
    }];
    balanceLabel.text = [@(amount) satoshiBTCString];
    
    [self.tableView registerClass:[DefaultTableViewCell class] forCellReuseIdentifier:kSendConfirmationAddressCellIdentifier];
}

#pragma mark - <UITableViewDataSource>
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 3;// addresses, fee, button
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (kSendConfirmationTableSectionAddresses == section) {
        // addresses
        return self.toAddresses.count;
    }
    return 1;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    // addresses
    if (kSendConfirmationTableSectionAddresses == indexPath.section) {
        CBWAddress *address = self.toAddresses[indexPath.row];
        DefaultTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:kSendConfirmationAddressCellIdentifier forIndexPath:indexPath];
        cell.textLabel.text = [@(address.balance) satoshiBTCString];
        cell.detailTextLabel.attributedText = [address.address attributedAddressWithAlignment:NSTextAlignmentRight];
        cell.detailTextLabel.font = [UIFont monospacedFontOfSize:[UIFont smallSystemFontSize]];
        return cell;
    }
    // fee
    if (kSendConfirmationTableSectionFee == indexPath.section) {
        DefaultTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:BaseTableViewCellDefaultIdentifier forIndexPath:indexPath];
        cell.textLabel.text = [@(self.fee) satoshiBTCString];
        cell.detailTextLabel.text = self.feePerKByte > 0 ? [NSString stringWithFormat:@"%@/kb", [@(self.feePerKByte) satoshiBTCString]] : nil;
        return cell;
    }
    // button
    if (kSendConfirmationTableSectionButton == indexPath.section) {
        FormControlBlockButtonCell *cell = [tableView dequeueReusableCellWithIdentifier:BaseTableViewCellBlockButtonIdentifier];
        switch (self.state) {
            case SendConfirmationViewControllerStateIdle: {
                cell.buttonCellStyle = BlockButtonCellStylePrimary;
                cell.textLabel.text = NSLocalizedStringFromTable(@"Button confirm_to_send", @"CBW", nil);
                break;
            }
            case SendConfirmationViewControllerStateBroadcasting: {
                cell.buttonCellStyle = BlockButtonCellStyleProcess;
                break;
            }
            case SendConfirmationViewControllerStateSuccess: {
                cell.buttonCellStyle = BlockButtonCellStyleSuccess;
                cell.textLabel.text = NSLocalizedStringFromTable(@"Button broadcast_success", @"CBW", nil);
                break;
            }
            case SendConfirmationViewControllerStateFailed: {
                cell.buttonCellStyle = BlockButtonCellStyleDanger;
                cell.textLabel.text = NSLocalizedStringFromTable(@"Button broadcast_failed", @"CBW", nil);
                break;
            }
        }
        return cell;
    }
    
    // undefined
    return [tableView dequeueReusableCellWithIdentifier:BaseTableViewCellDefaultIdentifier];
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    if (kSendConfirmationTableSectionAddresses == section) {
        return NSLocalizedStringFromTable(@"Send Confirm Section addresses", @"CBW", nil);
    }if (kSendConfirmationTableSectionFee == section) {
        return NSLocalizedStringFromTable(@"Send Confirm Section fee", @"CBW", nil);
    }
    return nil;
}

#pragma mark - <UITableViewDelegate>
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    // button section
    if (kSendConfirmationTableSectionButton == indexPath.section) {
        switch (self.state) {
            case SendConfirmationViewControllerStateIdle: {
                [self p_broadcast];
                break;
            }
                
            case SendConfirmationViewControllerStateSuccess: {
                [self p_dismiss];
                break;
            }
                
            default:
                break;
        }
    }
}

#pragma mark - Private Method
- (void)p_dismiss {
    if ([self.delegate respondsToSelector:@selector(sendConfirmationViewControllerWillDismiss:)]) {
        [self.delegate sendConfirmationViewControllerWillDismiss:self];
        return;
    }
    
    if (self.presentingViewController) {
        [self.presentingViewController dismissViewControllerAnimated:YES completion:nil];
    } else {
        [self dismissViewControllerAnimated:YES completion:nil];
    }
}

- (void)p_broadcast {
    [self p_resetState:@(SendConfirmationViewControllerStateBroadcasting)];
    CBWRequest *request = [[CBWRequest alloc] init];
    [request toolsPublishTxHex:self.txHash withCompletion:^(NSError * _Nullable error, NSInteger statusCode, id  _Nullable response) {
        if (error) {
            [self p_resetState:@(SendConfirmationViewControllerStateFailed)];

            [self performSelector:@selector(p_resetState:) withObject:@(SendConfirmationViewControllerStateIdle) afterDelay:2.5];
            
            if ([self.delegate respondsToSelector:@selector(sendConfirmationViewController:didBroadcast:)]) {
                [self.delegate sendConfirmationViewController:self didBroadcast:NO];
            }

            return;
        }
        
        [self p_resetState:@(SendConfirmationViewControllerStateSuccess)];
        
        if ([self.delegate respondsToSelector:@selector(sendConfirmationViewController:didBroadcast:)]) {
            [self.delegate sendConfirmationViewController:self didBroadcast:YES];
        }

    }];
}

- (void)p_resetState:(NSNumber *)state {
    _state = [state unsignedIntegerValue];
    
    [self.tableView reloadSections:[NSIndexSet indexSetWithIndex:kSendConfirmationTableSectionButton] withRowAnimation:UITableViewRowAnimationAutomatic];
}

@end
