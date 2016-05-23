//
//  SendViewController+Send.m
//  CBWallet
//
//  Created by Zin on 16/4/29.
//  Copyright © 2016年 Bitmain. All rights reserved.
//

#import "SendViewController+Send.h"
#import "CBWAccount.h"
#import "CBWAddressStore.h"
#import "CBWFee.h"
#import "CBWRequest.h"

#import <CoreBitcoin/CoreBitcoin.h>

@implementation SendViewController (Send)


- (void)sendToAddresses:(NSDictionary *)toAddresses withCompletion:(void (^)(NSError *error))completion {
    [self sendToAddresses:toAddresses withChangeAddress:nil fee:[[CBWFee defaultFee].value longLongValue] completion:completion];
}

- (void)sendToAddresses:(NSDictionary *)toAddresses withChangeAddress:(CBWAddress *)changeAddress fee:(long long)fee completion:(void (^)(NSError *))completion{
    
    // 1. 准备发款地址
    NSMutableArray <CBWAddress *> *fromAddresses = [self.advancedFromAddresses mutableCopy];
    if (fromAddresses.count == 0) {
        CBWAddressStore *store = [[CBWAddressStore alloc] initWithAccountIdx:self.account.idx];
        [store fetch];
        fromAddresses = [[store availableAddresses] mutableCopy];
    }
    if (fromAddresses.count == 0) {
//        [self alertErrorMessage:NSLocalizedStringFromTable(@"Alert Message none_from_address_selected_to_send", @"CBW", nil)];
        completion([NSError errorWithDomain:CBWErrorDomain code:0 userInfo:@{NSLocalizedDescriptionKey: NSLocalizedStringFromTable(@"Alert Message none_from_address_selected_to_send", @"CBW", nil)}]);
        return;
    }
    // 排序，优先使用额度较大的地址
    [fromAddresses sortUsingComparator:^NSComparisonResult(id  _Nonnull obj1, id  _Nonnull obj2) {
        CBWAddress *address1 = obj1;
        CBWAddress *address2 = obj2;
        
        // DESC
        return [@(address2.balance) compare:@(address1.balance)];
    }];
    DLog(@"sorted addresses: %@", fromAddresses);
    // 找零地址
    if (!changeAddress) {
        changeAddress = [fromAddresses firstObject];
    }
    
    // 2. 计算交易额
    __block long long amount = fee;
    [toAddresses enumerateKeysAndObjectsUsingBlock:^(id  _Nonnull key, id  _Nonnull obj, BOOL * _Nonnull stop) {
        amount += [obj longLongValue];
    }];
    
    if (amount > BTC_MAX_MONEY) {
        completion([NSError errorWithDomain:CBWErrorDomain code:0 userInfo:@{NSLocalizedDescriptionKey: NSLocalizedStringFromTable(@"Error too_big_amount", @"CBW", nil)}]);
        return;
    }
    
    // 3. 获取未花交易
    __block NSMutableArray *addresses = [NSMutableArray array];
    [fromAddresses enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        CBWAddress *address = obj;
        [addresses addObject:address.address];
    }];
    CBWRequest *request = [[CBWRequest alloc] init];
    // @[@"1FjEHuM8YHZcM4tCj9YYA7TdAyeJ1e61x7", @"1CZvwQmyurcw2oYQoMrX6UJ3FCYVnFbUwW"]
    [request addressesUnspentForAddresses:addresses withAmount:amount progress:^(NSString * _Nonnull message) {
        DLog(@"send progress: %@", message);
    } completion:^(NSError * _Nullable error, NSArray * _Nullable newAddresses) {
        
        if (error) {
//            [self alertErrorMessage:error.localizedDescription];
            completion(error);
            return;
        }
        
        
        DLog(@"addresses unspent successful: %@", newAddresses);
        
        // 对 unspent tx 进行排序
        NSMutableArray *sortedAddresses = [newAddresses mutableCopy];
        [sortedAddresses enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            if ([obj isKindOfClass:[NSDictionary class]]) {
                NSDictionary *address = obj;
                NSString *addressString = [[address allKeys] firstObject];
                NSMutableArray *utxouts = [[address objectForKey:addressString] mutableCopy];
                // 排序
                [utxouts sortUsingComparator:^NSComparisonResult(id  _Nonnull obj1, id  _Nonnull obj2) {
                    return [obj2[@"value"] compare:obj1[@"value"]];// DESC
                }];
                // 替换
                [sortedAddresses replaceObjectAtIndex:idx withObject:@{addressString: [utxouts copy]}];
            }
        }];
        DLog(@"sorted: %@", sortedAddresses);
            
        // 4. 根据金额取得需要的未花交易
        [self p_fetchUnspentScriptWithAddresses:sortedAddresses totalAmount:amount completion:^(NSError *error, NSArray *usedAddresses) {
            DLog(@"scripted addresses: %@", usedAddresses);
            
            if (error) {
//                [self alertMessage:error.localizedDescription withTitle:NSLocalizedStringFromTable(@"Error", @"CBW", nil)];
                completion(error);
                return;
            }
            
            
            NSMutableArray *unspentAddresses = [NSMutableArray array];
            [usedAddresses enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                if (![obj isKindOfClass:[NSDictionary class]]) {
                    return;
                }
                NSMutableDictionary *unspentAddress = [obj mutableCopy];
                
                NSString *addressString = [[unspentAddress allKeys] firstObject];
                NSArray *unspentTxsJson = [unspentAddress objectForKey:addressString];
                
                // 5. 组装未花交易输出
                __block NSMutableArray *txouts = [[NSMutableArray alloc] init];
                [unspentTxsJson enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                    // FIXME: 只获取部分未花交易？
                    if ([obj[@"script"] length] > 0) {
                        BTCTransactionOutput *txout = [[BTCTransactionOutput alloc] init];
                        txout.value = [obj[@"value"] longLongValue];
                        txout.script = [[BTCScript alloc] initWithString:obj[@"script"]];
                        txout.index = [obj[@"tx_output_n"] intValue];
                        txout.transactionHash = (BTCReversedData(BTCDataFromHex(obj[@"tx_hash"])));
                        txout.confirmations = [obj[@"confirmations"] unsignedIntegerValue];
                        [txouts addObject:txout];
                    }
                }];
                
                if (txouts.count == 0) {
                    DLog(@"none unspent txs");
                } else {
                    [unspentAddress setObject:txouts forKey:addressString];
                    [unspentAddresses addObject:unspentAddress];
                }
            }];
            DLog(@"unspent txs: %@", unspentAddresses);
            
            // 未能获得有效未花交易地址
            if (unspentAddresses.count == 0) {
                DLog(@"none addresses with unspent txs");
                completion([NSError errorWithDomain:CBWErrorDomain code:0 userInfo:@{NSLocalizedDescriptionKey: NSLocalizedStringFromTable(@"Error none_address_with_unspent_txs", @"CBW", nil)}]);
                return;
            }
            
            
            // 6. 新建交易
            __block BTCTransaction *tx = [[BTCTransaction alloc] init];
            __block BTCAmount spentCoins = 0;
            
            // 将所有处理过（统计金额）的输出作为输入
            [unspentAddresses enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                NSDictionary *unspentAddress = obj;
                NSArray *txouts = [[unspentAddress allValues] firstObject];
                [txouts enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                    BTCTransactionOutput *txout = obj;
                    
                    BTCTransactionInput *txin = [[BTCTransactionInput alloc] init];
                    txin.previousHash = txout.transactionHash;
                    txin.previousIndex = txout.index;
                    [tx addInput:txin];
                    
                    DLog(@"txhash: http://blockchain.info/rawtx/%@", BTCHexFromData(txout.transactionHash));
                    DLog(@"txhash: http://blockchain.info/rawtx/%@ (reversed)", BTCHexFromData(BTCReversedData(txout.transactionHash)));
                    
                    spentCoins += txout.value;
                }];
            }];
            
            NSLog(@"Total satoshis to spend:       %lld", spentCoins);
            NSLog(@"Total satoshis to destination: %lld", amount - fee);
            NSLog(@"Total satoshis to fee:         %lld", fee);
            NSLog(@"Total satoshis to change:      %lld", (spentCoins - amount));
            
            
            // 7. 交易输出，支付及找零
            [toAddresses enumerateKeysAndObjectsUsingBlock:^(id  _Nonnull key, id  _Nonnull obj, BOOL * _Nonnull stop) {
                // Idea: deterministically-randomly choose which output goes first to improve privacy.
                BTCAmount value = [obj longLongValue];
                BTCTransactionOutput *paymentOutput = [[BTCTransactionOutput alloc] initWithValue:value address:[BTCPublicKeyAddress addressWithString:key]];
                [tx addOutput:paymentOutput];
            }];
            BTCTransactionOutput *changeOutput = [[BTCTransactionOutput alloc] initWithValue:(spentCoins - amount) address:[BTCPublicKeyAddress addressWithString:changeAddress.address]];
            [tx addOutput:changeOutput];
            
            
            // 8. 签名
            DLog(@"prepare to sign tx: %@", tx);
            [unspentAddresses enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                NSDictionary *unspentAddress = obj;
                NSString *addressString = [[unspentAddress allKeys] firstObject];
                
                // 找到对应的 key
                __block BTCKey *key = nil;
                [fromAddresses enumerateObjectsUsingBlock:^(CBWAddress * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                    if ([obj.address isEqualToString:addressString]) {
                        key = obj.privateKey;
                        *stop = YES;
                    }
                }];
                
                if (!key) {
                    completion([NSError errorWithDomain:CBWErrorDomain code:0 userInfo:@{NSLocalizedDescriptionKey: NSLocalizedStringFromTable(@"Alert Message invalid_key_to_sign_trasaction", @"CBW", nil)}]);
                    return;
                }
                
                NSArray *txouts = [unspentAddress objectForKey:addressString];
                [txouts enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                    BTCTransactionOutput *txout = obj;
                    
                    BTCTransactionInput *txin = tx.inputs[idx];
                    
                    BTCScript *sigScript = [[BTCScript alloc] init];
                    
                    BTCSignatureHashType hashtype = BTCSignatureHashTypeAll;
                    
                    // 生成待签名 hash
                    NSData *hash = [tx signatureHashForScript:txout.script inputIndex:(uint32_t)idx hashType:hashtype error:nil];
                    
                    DLog(@"Hash for input %lu: %@", (unsigned long)idx, BTCHexFromData(hash));
                    if (!hash) {
                        completion([NSError errorWithDomain:CBWErrorDomain code:0 userInfo:@{NSLocalizedDescriptionKey: NSLocalizedStringFromTable(@"Alert Message invalid_hash_to_sign_transaction", @"CBW", nil)}]);
                        return;
                    }
                    
                    // 签名
                    NSData *signatureForScript = [key signatureForHash:hash hashType:hashtype];
                    [sigScript appendData:signatureForScript];
                    [sigScript appendData:key.publicKey];
                    
                    NSData *sig = [signatureForScript subdataWithRange:NSMakeRange(0, signatureForScript.length - 1)]; // trim hashtype byte to check the signature.
                    if (![key isValidSignature:sig hash:hash]) {
                        completion([NSError errorWithDomain:CBWErrorDomain code:0 userInfo:@{NSLocalizedDescriptionKey: NSLocalizedStringFromTable(@"Alert Message invalid_signature_for_transaction", @"CBW", nil)}]);
                        return;
                    }
                    
                    txin.signatureScript = sigScript;
                }];
            }];
            
            
            // 9. 广播
            // Validate the signatures before returning for extra measure.
            {
                BTCScriptMachine *sm = [[BTCScriptMachine alloc] initWithTransaction:tx inputIndex:0];
                NSError *error = nil;
                BOOL r = [sm verifyWithOutputScript:[[(BTCTransactionOutput*)[[[[unspentAddresses firstObject] allValues] firstObject] firstObject] script] copy] error:&error];
                if (!r) {
                    // callback
                    completion(error);
                    return;
                }
            }
            DLog(@"to publish transaction: %@", BTCHexFromData(tx.data));
            
            // confirm to send
            UIAlertController *confirm = [UIAlertController alertControllerWithTitle:self.title message:[NSString stringWithFormat:NSLocalizedStringFromTable(@"Alert Message sure_to_send_coins %d satoshi", @"CBW", nil), amount] preferredStyle:UIAlertControllerStyleAlert];
            UIAlertAction *cancel = [UIAlertAction actionWithTitle:NSLocalizedStringFromTable(@"Cancel", @"CBW", nil) style:UIAlertActionStyleCancel handler:nil];
            [confirm addAction:cancel];
            UIAlertAction *send = [UIAlertAction actionWithTitle:NSLocalizedStringFromTable(@"Send", @"CBW", nil) style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                [request toolsPublishTxHex:BTCHexFromData(tx.data) withCompletion:^(NSError * _Nullable error, NSInteger statusCode, id  _Nullable response) {
                    
                    if (error) {
                        completion(error);
                        return;
                    }
                    
                    // success
                    completion(nil);
                    
                }];
            }];
            [confirm addAction:send];
            [self presentViewController:confirm animated:YES completion:nil];
                
            
        }];
    }];
}

- (void)p_fetchUnspentScriptWithAddresses:(NSArray *)addresses totalAmount:(long long)totalAmount completion:(void (^) (NSError *error, NSArray *newAddresses))completion {
    __block long long fetchedAmount = 0;
    __block NSMutableArray *newAddresses = [addresses mutableCopy];
    [newAddresses enumerateObjectsUsingBlock:^(id  _Nonnull address, NSUInteger addressIdx, BOOL * _Nonnull stopAddress) {
        if ([address isKindOfClass:[NSDictionary class]]) {
            // 存在交易
            // addressString: txs
            NSMutableDictionary *newAddress = [address mutableCopy];
            // txs
            NSString *addressString = [[newAddress allKeys] firstObject];
            NSMutableArray *unspentTxs = [[newAddress objectForKey:addressString] mutableCopy];
            [unspentTxs enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                NSMutableDictionary *tx = [obj mutableCopy];
                NSString *script = [tx objectForKey:@"script"];
                if (script.length > 0) {
                    fetchedAmount += [[tx objectForKey:@"value"] longLongValue];
                    if (fetchedAmount >= totalAmount) {
                        // 满足条件
                        *stop = YES;
                        *stopAddress = YES;
                        // 回调
                        completion(nil, addresses);
                    }
                } else {
                    *stop = YES;
                    *stopAddress = YES;
                    DLog(@"fetch script of unspent: %@", tx);
                    CBWRequest *request = [[CBWRequest alloc] init];
                    [request transactionWithHash:[tx objectForKey:@"tx_hash"] completion:^(NSError * _Nullable error, NSInteger statusCode, id  _Nullable response) {
                        if (error) {
                            completion(error, nil);
                        } else {
                            // 赋值
                            NSArray *outpus = [response objectForKey:@"outputs"];
                            DLog(@"outputs: %@", outpus);
                            [outpus enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                                NSArray *addresses = [obj objectForKey:@"addresses"];
                                if ([addresses containsObject:[[address allKeys] firstObject]]) {
//                                    [tx setObject:[obj objectForKey:@"script_hex"] forKey:@"script"];
                                    [tx setObject:[obj objectForKey:@"script_asm"] forKey:@"script"];
                                }
                            }];
                            
                            // 替换 tx
                            [unspentTxs replaceObjectAtIndex:idx withObject:[tx copy]];
                            // 替换 txs
                            [newAddress setObject:[unspentTxs copy] forKey:addressString];
                            // 替换 addressString: txs
                            [newAddresses replaceObjectAtIndex:addressIdx withObject:newAddress];
                            // 递归
                            [self p_fetchUnspentScriptWithAddresses:[newAddresses copy] totalAmount:totalAmount completion:completion];
                        }
                    }];
                }
            }];
        }
    }];
}


@end
