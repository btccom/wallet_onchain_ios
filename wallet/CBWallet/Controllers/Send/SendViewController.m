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
#import "AddressListViewController.h"

#import "FormControlStaticArrowCell.h"
#import "SendFromAddressCell.h"
#import "SendToAddressCell.h"
#import "FormControlInputCell.h"
#import "FormControlInputActionCell.h"

#import "CBWAccount.h"
#import "CBWAddressStore.h"
#import "CBWFee.h"

#import <CoreBitcoin/CoreBitcoin.h>

#import "CBWRequest.h"

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

@interface SendViewController ()<UITextFieldDelegate, ScanViewControllerDelegate, AddressListViewControllerDelegate>

@property (nonatomic, strong) CBWAddressStore *addressStore;

@property (nonatomic, weak) FormControlInputActionCell *quicklyAddressCell;
@property (nonatomic, weak) FormControlInputCell *quicklyAmountCell;
@property (nonatomic, weak) FormControlBlockButtonCell *quicklySendButtonCell;

@property (nonatomic, strong) NSArray *advancedSectionTitles;
@property (nonatomic, strong) NSMutableArray<CBWAddress *> *advancedFromAddresses;
@property (nonatomic, strong) NSMutableArray<CBWAddress *> *advancedToDatas;
@property (nonatomic, weak) FormControlInputActionCell *advancedToAddressCell;
@property (nonatomic, weak) FormControlInputActionCell *advancedToAmountCell;
@property (nonatomic, weak) FormControlBlockButtonCell *advancedSendButtonCell;
@property (nonatomic, strong) CBWAddress *advancedChangeAddress;// new address as default
@property (nonatomic, strong) CBWFee *fee;// medium as default


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

- (instancetype)initWithAccount:(CBWAccount *)account {
    self = [super init];
    if (self) {
        _account = account;
        _fee = [CBWFee defaultFee];
    }
    return self;
}

#pragma mark - View Life Cycle
- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = NSLocalizedStringFromTable(@"Navigation send", @"CBW", @"Quickly Send");
//    暂时关闭高级发款
//    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedStringFromTable(@"Navigation advanced_send", @"CBW", @"Advanced Send") style:UIBarButtonItemStylePlain target:self action:@selector(p_handleSwitchMode:)];
    
    _advancedSectionTitles = @[NSLocalizedStringFromTable(@"Send Section from", @"CBW", nil),
                               NSLocalizedStringFromTable(@"Send Section to", @"CBW", nil),
                               @"",
                               NSLocalizedStringFromTable(@"Send Section change", @"CBW", nil),
                               NSLocalizedStringFromTable(@"Send Section fee", @"CBW", nil),
                               @""];
    
    
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
    
    [self p_checkIfSendButtonEnabled];
    
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
    
}

/// click scan
- (void)p_handleScan:(id)sender {
    DLog(@"handle scan");
    [self.view endEditing:YES];
    
    ScanViewController *scanViewController = [[ScanViewController alloc] init];
    scanViewController.delegate = self;
    [self presentViewController:scanViewController animated:YES completion:nil];
    
}

/// clicked send button
- (void)p_handleSend {
    NSLog(@"handle send");
    [self.view endEditing:YES];
    // TODO: quickly
    // check address
    NSString *addressString = self.quicklyAddressCell.textField.text;
    if (![CBWAddress validateAddressString:addressString]) {
        [self p_alertInvalidAddress];
        return;
    }
    
    [self p_sendToAddressString:self.quicklyToAddress withAmount:[@([self.quicklyToAmountInBTC doubleValue]) longLongValue]];
    
    // TODO: advanced
    // check from address balance
    // check to address
    // check change address
    // check fee
    // sign inputs
    // post
}

- (void)p_sendToAddressString:(NSString *)addressString withAmount:(long long)amount {
    
    // 1. Get a private key, destination address, change address and amount
    // 用当前账户的第一个地址测试，应该轮询余额大于零的全部地址
    CBWAddressStore *store = [[CBWAddressStore alloc] initWithAccountIdx:self.account.idx];
    [store fetch];
    CBWAddress *address = [store recordAtIndex:0];
    BTCKey *key = address.privateKey;
    CBWAddress *newAddress = [store recordAtIndex:(store.count - 1)];//
    BTCPublicKeyAddress *changeAddress = newAddress.privateKey.compressedPublicKeyAddress;
    DLog(@"got key for address: %@", key.compressedPublicKeyAddress);
    
    // 2. Get unspent outputs for that key (using both compressed and non-compressed pubkey)
    CBWRequest *request = [[CBWRequest alloc] init];
    [request addressUnspentWithAddressString:address.address completion:^(NSError * _Nullable error, NSInteger statusCode, id  _Nullable response) {
        DLog(@"unspent response: %@", response);

        NSArray *list = [response objectForKey:CBWRequestResponseDataListKey];
        if (list.count == 0) {
            return;
        }
        
        
        __block NSMutableArray *utxos = [[NSMutableArray alloc] init];
        [list enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            BTCTransactionOutput *txout = [[BTCTransactionOutput alloc] init];
            
            txout.value = [obj[@"value"] longLongValue];
//            txout.script = [[BTCScript alloc] initWithString:obj[@"script"]];
            txout.index = [obj[@"tx_output_n"] intValue];
            txout.transactionHash = (BTCReversedData(BTCDataFromHex(obj[@"tx_hash"])));
            txout.confirmations = [obj[@"confirmations"] unsignedIntegerValue];
            [utxos addObject:txout];
        }];
        
        DLog(@"UTXOs for %@: %@ %@", key.compressedPublicKeyAddress, utxos, error);
        
        if (!utxos) {
            return;
        }
        
        // 3. Take the smallest available outputs to combine into the inputs of new transaction
        CBWFee *fee = [CBWFee defaultFee];
        BTCAmount totalAmount = amount + [fee.value longLongValue];
        BTCAmount dustThreshold = 100000;
        
        utxos = [[utxos sortedArrayUsingComparator:^(BTCTransactionOutput* obj1, BTCTransactionOutput* obj2) {
            if ((obj1.value - obj2.value) < 0) return NSOrderedAscending;
            else return NSOrderedDescending;
        }] mutableCopy];
        DLog(@"sorted UTXOs: %@", utxos);
        
        NSArray *txouts = nil;
        
        for (BTCTransactionOutput *txout in utxos) {
            if (txout.value > (totalAmount + dustThreshold) && txout.script.isPayToPublicKeyHashScript) {
                txouts = @[ txout ];
                break;// only one out
            }
        }
        
        if (!txouts) return;
        
        // 4. Prepare the scripts with proper signatures for the inputs
        
        // Create a new transaction
        BTCTransaction *tx = [[BTCTransaction alloc] init];
        
        BTCAmount spentCoins = 0;
        
        // Add all outputs as inputs
        for (BTCTransactionOutput *txout in txouts) {
            BTCTransactionInput *txin = [[BTCTransactionInput alloc] init];
            txin.previousHash = txout.transactionHash;
            txin.previousIndex = txout.index;
            [tx addInput:txin];
            
            DLog(@"txhash: http://blockchain.info/rawtx/%@", BTCHexFromData(txout.transactionHash));
            DLog(@"txhash: http://blockchain.info/rawtx/%@ (reversed)", BTCHexFromData(BTCReversedData(txout.transactionHash)));
            
            spentCoins += txout.value;
        }
        
        NSLog(@"Total satoshis to spend:       %lld", spentCoins);
        NSLog(@"Total satoshis to destination: %lld", amount);
        NSLog(@"Total satoshis to fee:         %lld", [fee.value longLongValue]);
        NSLog(@"Total satoshis to change:      %lld", (spentCoins - (amount + [fee.value longLongValue])));
        
        // Add required outputs - payment and change
        BTCTransactionOutput *paymentOutput = [[BTCTransactionOutput alloc] initWithValue:amount address:[BTCPublicKeyAddress addressWithString:addressString]];
        BTCTransactionOutput *changeOutput = [[BTCTransactionOutput alloc] initWithValue:(spentCoins - totalAmount) address:changeAddress];
        
        // Idea: deterministically-randomly choose which output goes first to improve privacy.
        [tx addOutput:paymentOutput];
        [tx addOutput:changeOutput];
        
        
        // Sign all inputs.
        for (int i = 0; i < txouts.count; i++) {
            
            BTCTransactionOutput* txout = txouts[i]; // output from a previous tx which is referenced by this txin.
            BTCTransactionInput* txin = tx.inputs[i];
            
            BTCScript* sigScript = [[BTCScript alloc] init];
            
            NSData* d1 = tx.data;
            
            BTCSignatureHashType hashtype = BTCSignatureHashTypeAll;
            
            NSData *hash = [tx signatureHashForScript:txout.script inputIndex:i hashType:hashtype error:nil];
            
            NSData *d2 = tx.data;
            
            NSAssert([d1 isEqual:d2], @"Transaction must not change within signatureHashForScript!");
            
            DLog(@"Hash for input %d: %@", i, BTCHexFromData(hash));
            if (!hash) {
                return;
            }
            
            NSData* signatureForScript = [key signatureForHash:hash hashType:hashtype];
            [sigScript appendData:signatureForScript];
            [sigScript appendData:key.publicKey];
            
            NSData* sig = [signatureForScript subdataWithRange:NSMakeRange(0, signatureForScript.length - 1)]; // trim hashtype byte to check the signature.
            NSAssert([key isValidSignature:sig hash:hash], @"Signature must be valid");
            
            txin.signatureScript = sigScript;
        }
        
        // Validate the signatures before returning for extra measure.
        
        {
            BTCScriptMachine* sm = [[BTCScriptMachine alloc] initWithTransaction:tx inputIndex:0];
            NSError* error = nil;
            BOOL r = [sm verifyWithOutputScript:[[(BTCTransactionOutput*)txouts[0] script] copy] error:&error];
            NSLog(@"Error: %@", error);
            NSAssert(r, @"should verify first output");
        }
        
        // 5. Broadcast the transaction
        
        
    }];
}

- (BOOL)p_editingChanged:(id)sender {
    BOOL valid = YES;
    if ([sender isEqual:self.quicklyAddressCell.textField]) {
        self.quicklyToAddress = [self.quicklyAddressCell.textField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
        valid = [self p_checkIfSendButtonEnabled];
    } else if ([sender isEqual:self.quicklyAmountCell.textField]) {
        self.quicklyToAmountInBTC = [self.quicklyAmountCell.textField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
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
            valid = valid && self.advancedFromAddresses.count > 0;
            valid = valid && self.advancedToDatas.count > 0;
            self.advancedSendButtonCell.enabled = valid;
            break;
        }
    }
    return valid;
}

-(void)p_alertInvalidAddress {
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:NSLocalizedStringFromTable(@"Error", @"CBW", nil) message:NSLocalizedStringFromTable(@"Alert Message invalid_address", @"CBW", nil) preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *okay = [UIAlertAction actionWithTitle:NSLocalizedStringFromTable(@"Okay", @"CBW", nil) style:UIAlertActionStyleCancel handler:nil];
    [alert addAction:okay];
    [self presentViewController:alert animated:YES completion:nil];
}

#pragma mark Advanced Actions
///
- (void)p_handleAdvancedAddToData:(id)sender {
    DLog(@"handle add advanced to data");
    [self.view endEditing:YES];
    
    NSString *addressString = self.advancedToAddressCell.textField.text;
    
    // check address
    if (![CBWAddress validateAddressString:addressString]) {
        [self p_alertInvalidAddress];
        return;
    }
    
    // check duplicated address
    __block BOOL duplicated = NO;
    [self.advancedToDatas enumerateObjectsUsingBlock:^(CBWAddress * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if ([self.advancedToAddressCell.textField.text isEqualToString:obj.address]) {
            duplicated = YES;
            *stop = YES;
        }
    }];
    if (duplicated) {
        // TODO: 错误提示，重复地址不同金额可以相加或替换
        return;
    }
    
    CBWAddress *address = [CBWAddress new];
    address.address = addressString;
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
- (void)p_handleAdvancedDeleteToData:(id)sender {
    SendToAddressCellDeleteButton *button = sender;
    NSIndexPath *indexPath = [self.tableView indexPathForCell:button.cell];
    [self.advancedToDatas removeObjectAtIndex:indexPath.row];
    [self.tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationBottom];
    [self p_checkIfSendButtonEnabled];
}
- (void)p_handleAdvancedSelectFromAddress {
    DLog(@"to select from address");
    AddressListViewController *addressListViewController = [[AddressListViewController alloc] initWithAccount:self.account];
    addressListViewController.actionType = AddressActionTypeSend;
    addressListViewController.selectedAddress = [self.advancedFromAddresses mutableCopy];
    addressListViewController.delegate = self;
    [self.navigationController pushViewController:addressListViewController animated:YES];
}
- (void)p_handleAdvancedSelectChangeAddress {
    DLog(@"to select change address");
    AddressListViewController *addressListViewController = [[AddressListViewController alloc] initWithAccount:self.account];
    addressListViewController.actionType = AddressActionTypeChange;
    addressListViewController.delegate = self;
    [self.navigationController pushViewController:addressListViewController animated:YES];
}
- (void)p_handleAdvancedSelectFee {
    DLog(@"to select fee");
    UIAlertController *actionSheet = [UIAlertController alertControllerWithTitle:NSLocalizedStringFromTable(@"Send Section fee", @"CBW", nil) message:nil preferredStyle:UIAlertControllerStyleActionSheet];
    NSUInteger count = CBWFee.values.count;
    for (NSUInteger i = 0; i < count; i ++) {
        CBWFee *fee = [CBWFee feeWithLevel:i];
        UIAlertAction *feeAction = [UIAlertAction actionWithTitle:[NSString stringWithFormat:@"%@ (%@)", [fee.value satoshiBTCString], fee.description] style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            self.fee = fee;
            [self.tableView reloadSections:[NSIndexSet indexSetWithIndex:kSendViewControllerAdvancedSectionFee] withRowAnimation:UITableViewRowAnimationFade];
        }];
        [actionSheet addAction:feeAction];
    }
    
    NSString *customFeeString = [NSString stringWithFormat:@"Description Fee %ld", (long)CBWFeeLevelCustom];
    UIAlertAction *customFeeAction = [UIAlertAction actionWithTitle:NSLocalizedStringFromTable(customFeeString, @"CBW", nil) style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [self p_handleAdvancedCustomFee];
    }];
    [actionSheet addAction:customFeeAction];
    
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:NSLocalizedStringFromTable(@"Cancel", @"CBW", nil) style:UIAlertActionStyleCancel handler:nil];
    [actionSheet addAction:cancelAction];
    
    [self presentViewController:actionSheet animated:YES completion:nil];
}

- (void)p_handleAdvancedCustomFee {
    NSString *customFeeString = [NSString stringWithFormat:@"Description Fee %ld", (long)CBWFeeLevelCustom];
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:NSLocalizedStringFromTable(customFeeString, @"CBW", nil) message:nil preferredStyle:UIAlertControllerStyleAlert];
    [alert addTextFieldWithConfigurationHandler:^(UITextField * _Nonnull textField) {
        textField.keyboardType = UIKeyboardTypeDecimalPad;
    }];
    UIAlertAction *okay = [UIAlertAction actionWithTitle:NSLocalizedStringFromTable(@"Okay", @"CBW", nil) style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        UITextField *textField = [alert.textFields firstObject];
        NSString *valueString = textField.text;
        DLog(@"custom value string: %@", valueString);
        long long value = valueString.doubleValue * 100000000;
        CBWFee *fee = [CBWFee feeWithValue:@(value)];
        self.fee = fee;
        [self.tableView reloadSections:[NSIndexSet indexSetWithIndex:kSendViewControllerAdvancedSectionFee] withRowAnimation:UITableViewRowAnimationFade];
    }];
    [alert addAction:okay];
    UIAlertAction *cancel = [UIAlertAction actionWithTitle:NSLocalizedStringFromTable(@"Cancel", @"CBW", nil) style:UIAlertActionStyleCancel handler:nil];
    [alert addAction:cancel];
    [self presentViewController:alert animated:YES completion:nil];
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
                            quicklyAddressCell.textField.text = self.quicklyToAddress;
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
                            quicklyAmountCell.textField.placeholder = NSLocalizedStringFromTable(@"Placeholder amount", @"CBW", @"Value or Amount?");
                            quicklyAmountCell.textField.text = self.quicklyToAmountInBTC;
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
                    buttonCell.textLabel.text = NSLocalizedStringFromTable(@"Button send", @"CBW", nil);
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
                    __block NSMutableArray *addresses = [NSMutableArray array];
                    [self.advancedFromAddresses enumerateObjectsUsingBlock:^(CBWAddress * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                        [addresses addObject:obj.address];
                    }];
                    advancedFromAddressCell.textLabel.text = nil;
                    if (addresses.count == 0) {
                        advancedFromAddressCell.textLabel.text = NSLocalizedStringFromTable(@"Send Cell select_from_address", @"CBW", nil);
                    }
                    [advancedFromAddressCell setAddresses:addresses];
                    cell = advancedFromAddressCell;
                    break;
                }
                case kSendViewControllerAdvancedSectionTo: {
                    // advanced to
                    SendToAddressCell *advancedToAddressCell = [tableView dequeueReusableCellWithIdentifier:kSendViewControllerCellAdvancedToAddressIdentifier];
                    advancedToAddressCell.imageView.image = [UIImage imageNamed:@"icon_delete_mini"];
                    [advancedToAddressCell.deleteButton addTarget:self action:@selector(p_handleAdvancedDeleteToData:) forControlEvents:UIControlEventTouchUpInside];
                    CBWAddress *address = self.advancedToDatas[indexPath.row];
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
                            inputCell.textField.placeholder = NSLocalizedStringFromTable(@"Placeholder amount", @"CBW", @"Value or Amount?");
//                            inputCell.textField.returnKeyType = UIReturnKeyDone;
                            inputCell.inputType = FormControlInputTypeBitcoinAmount;
                            [inputCell.actionButton setTitle:NSLocalizedStringFromTable(@"Send Cell add_recipient", @"CBW", @"Add Recipient") forState:UIControlStateNormal];
                            [inputCell.actionButton addTarget:self action:@selector(p_handleAdvancedAddToData:) forControlEvents:UIControlEventTouchUpInside];
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
                    advancedChangeCell.metadataHidden = YES;
                    if (self.advancedChangeAddress) {
                        [advancedChangeCell setAddress:self.advancedChangeAddress];
                    } else {
                        advancedChangeCell.labelLabel.text = NSLocalizedStringFromTable(@"Placeholder new_address", @"CBW", nil);
                    }
                    cell = advancedChangeCell;
                    break;
                }
                case kSendViewControllerAdvancedSectionFee: {
                    // advanced fee
                    FormControlStaticArrowCell *advancedFeeCell = [tableView dequeueReusableCellWithIdentifier:kSendViewControllerCellAdvancedFeeIdentifier];
                    advancedFeeCell.textLabel.text = [self.fee.value satoshiBTCString];
                    advancedFeeCell.detailTextLabel.text = self.fee.description;
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
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    switch (self.mode) {
        case SendViewControllerModeQuickly: {
            // quickly
            if (indexPath.section == kSendViewControllerQuicklySectionButton) {
                // send button
                [self p_handleSend];
            }
            break;
        }
        case SendViewControllerModeAdvanced: {
            // advanced
            switch (indexPath.section) {
                case kSendViewControllerAdvancedSectionFrom: {
                    [self p_handleAdvancedSelectFromAddress];
                    break;
                }
                case kSendViewControllerAdvancedSectionChange: {
                    [self p_handleAdvancedSelectChangeAddress];
                    break;
                }
                case kSendViewControllerAdvancedSectionFee: {
                    [self p_handleAdvancedSelectFee];
                    break;
                }
                case kSendViewControllerAdvancedSectionButton: {
                    [self p_handleSend];
                    break;
                }
            }
            break;
        }
    }
    [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
}

#pragma mark - <UITextFieldDelegate>
- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    if ([textField isEqual:self.quicklyAddressCell.textField]) {
        [self.quicklyAmountCell.textField becomeFirstResponder];
    } else if ([textField isEqual:self.quicklyAmountCell.textField]) {
        [self.quicklyAmountCell.textField resignFirstResponder];
        if ([self p_checkIfSendButtonEnabled]) {
            [self p_handleSend];
        }
    } else if ([textField isEqual:self.advancedToAddressCell.textField]) {
        [self.advancedToAmountCell.textField becomeFirstResponder];
    } else if ([textField isEqual:self.advancedToAmountCell.textField]) {
        [self.advancedToAmountCell.textField resignFirstResponder];
        if ([self p_editingChanged:textField]) {
            [self p_handleAdvancedAddToData:nil];
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
    NSString *address = [addressInfo objectForKey:CBWAddressInfoAddressKey];
    NSString *amount = [addressInfo objectForKey:CBWAddressInfoAmountKey];
    
    switch (self.mode) {
        case SendViewControllerModeQuickly: {
            self.quicklyAddressCell.textField.text = address;
            if (amount.doubleValue > 0) {
                self.quicklyAmountCell.textField.text = amount;
            }
            [self p_checkIfSendButtonEnabled];
            break;
        }
        case SendViewControllerModeAdvanced: {
            self.advancedToAddressCell.textField.text = address;
            if (amount.doubleValue > 0) {
                self.advancedToAmountCell.textField.text = amount;
            }
            [self p_editingChanged:self.advancedToAmountCell.textField];
            break;
        }
    }
    
}

#pragma mark - <AddressListViewControllerDelegate>
- (void)addressListViewController:(AddressListViewController *)controller didSelectAddress:(CBWAddress *)address {
    if (controller.actionType == AddressActionTypeSend) {
        if (![self.advancedFromAddresses containsObject:address]) {
            [self.advancedFromAddresses addObject:address];
            [self.tableView reloadSections:[NSIndexSet indexSetWithIndex:kSendViewControllerAdvancedSectionFrom] withRowAnimation:UITableViewRowAnimationNone];
        }
    } else if (controller.actionType == AddressActionTypeChange) {
        self.advancedChangeAddress = address;
        [self.tableView reloadSections:[NSIndexSet indexSetWithIndex:kSendViewControllerAdvancedSectionChange] withRowAnimation:UITableViewRowAnimationNone];
    }
    [self p_checkIfSendButtonEnabled];
}
- (void)addressListViewController:(AddressListViewController *)controller didDeselectAddress:(CBWAddress *)address {
    if ([self.advancedFromAddresses containsObject:address]) {
        [self.advancedFromAddresses removeObject:address];
        [self.tableView reloadSections:[NSIndexSet indexSetWithIndex:kSendViewControllerAdvancedSectionFrom] withRowAnimation:UITableViewRowAnimationNone];
    }
    [self p_checkIfSendButtonEnabled];
}

@end
