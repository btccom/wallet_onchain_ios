//
//  CBWBackup.m
//  CBWallet
//
//  Created by Zin (noteon.com) on 16/4/10.
//  Copyright © 2016年 Bitmain. All rights reserved.
//

#import "CBWBackup.h"
#import "SSKeychain.h"
#import "Database.h"
#import "YYImage.h"
#import <CoreBitcoin/CoreBitcoin.h>
#import <CloudKit/CloudKit.h>

@implementation CBWBackup

+ (NSArray *)getDatas {
    // 检查 seed
    NSString *encryptedSeed = [SSKeychain passwordForService:CBWKeychainSeedService account:CBWKeychainAccountDefault];
    if (!encryptedSeed) {
        NSLog(@"No seed datas");
        return nil;
    }
    
    // 检查 hint
    NSString *hint = [SSKeychain passwordForService:CBWKeychainHintService account:CBWKeychainAccountDefault];
    if (!hint) {
        hint = @"";
    }
    if (hint.length > 0) {
        // 转 bas64
        NSData *hintData = [hint dataUsingEncoding:NSUTF8StringEncoding];
        NSString *hintBase64String = [hintData base64EncodedStringWithOptions:0];
        // 转回字符验证
        NSString *hintFromBase64 = [[NSString alloc] initWithData:[[NSData alloc] initWithBase64EncodedString:hintBase64String options:0] encoding:NSUTF8StringEncoding];
        DLog(@"hint base64 string: %@, back: %@", hintBase64String, hintFromBase64);
        if ([hintFromBase64 isEqualToString:hint]) {
            hint = hintBase64String;
        }
    }
    
    // 种子数据: [seed, hint]
    NSArray *seedAndHint = @[encryptedSeed, hint];
    
    // 1. 待返回数据: [seed data, {dictionary of account item}]
    NSMutableArray *datas = [NSMutableArray arrayWithObject:seedAndHint];
    
    
    // 2. 准备组装 account item 字典: {idx: account properties, ...account item}
    NSMutableDictionary *accountItemsDictionary = [NSMutableDictionary dictionary];
    
    // 处理 account 数据
    CBWAccountStore *accountStore = [[CBWAccountStore alloc] init];
    [accountStore fetch];
    
    // 处理 account item
    for (NSUInteger i = 0; i < accountStore.count; i++) {
        
        // 当前 account
        CBWAccount *account = [accountStore recordAtIndex:i];
        
        // 检查 account label
        NSString *accountLabel = account.label; //[account.label stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
        if (!accountLabel) {
            accountLabel = @"";
        }
        
        // 2-1. account properties: [account label]
        NSMutableArray *accountProperties = [NSMutableArray arrayWithObject:accountLabel];
        
        // 获取 address 数据
        CBWAddressStore *addressStore = [[CBWAddressStore alloc] initWithAccountIdx:account.idx];
        [addressStore fetchAllAddresses];
        
        // 2-2. account properties: [account label, address count]
        [accountProperties addObject:@(addressStore.count)];
        
        // 准备组装 address item 字典: {idx: address properties, ...address item}
        NSMutableDictionary *addressItemsDictionary = [NSMutableDictionary dictionary];
        for (NSUInteger j = 0; j < addressStore.count; j++) {
            
            // 当前 address
            CBWAddress *address = [addressStore recordAtIndex:j];
            
            if (account.idx == CBWRecordWatchedIDX) {
                // watched account
                
                // 检查 address label
                NSString *addressLabel = address.label; //[address.label stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
                if (!addressLabel) {
                    addressLabel = @"";
                }
                
                // 设置 watched address item: {address: label}
                [addressItemsDictionary setObject:addressLabel forKey:address.address];
                
            } else if (address.isDirty || address.isArchived || address.label.length > 0) {
                // 用户账户，且属性不是初始值或设置了标签
                
                // 检查 address label
                NSString *addressLabel = address.label; //[address.label stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
                if (!addressLabel) {
                    addressLabel = @"";
                }
                
                // address properties: [address label, dirty, archived]
                NSArray *addressProperties = @[addressLabel, @(address.isDirty), @(address.isArchived)];
                
                // 设置一个 address item: {address idx: address properties}
                [addressItemsDictionary setObject:addressProperties forKey:[@(address.idx) stringValue]];
                
            }
        }// 完成 address items dicrionary
        
        if (addressItemsDictionary.count > 0) {
            // 2-3. account properties: [account label, address count, {dictionary of address item}]
            [accountProperties addObject:[addressItemsDictionary copy]];
        }
        
        // 3. 设置一个 account item: {account idx: account properties}
        [accountItemsDictionary setObject:[accountProperties copy] forKey:[@(account.idx) stringValue]];
        
    }
    
    if (accountItemsDictionary.count > 0) {
        // 4. 存入 datas
        [datas addObject:[accountItemsDictionary copy]];
    }
    
    DLog(@"formated datas: %@", datas);
    return [datas copy];
}

+ (UIImage *)exportImage {
    NSArray *datas = [self getDatas];
    if (!datas) {
        NSLog(@"No datas to be saved as image");
        return nil;
    }
    
    if (datas.count == 0) {
        NSLog(@"Datas is empty, can't be saved as image");
        return nil;
    }
    
    if (datas.count == 1) {
        NSLog(@"Accounts data is empty, can't be saved as image");
        return nil;
    }
    
    // 种子数据二维码
    NSString *seedAndHint = [[NSString alloc] initWithData:[NSJSONSerialization dataWithJSONObject:[datas firstObject] options:0 error:nil] encoding:NSUTF8StringEncoding];
    UIImage *seedAndHintImage = [BTCQRCode imageForString:seedAndHint size:CGSizeMake(800.f, 800.f) scale:2.f];
    
    // 种子数据二维码压入第一帧
    YYImageEncoder *encoder = [[YYImageEncoder alloc] initWithType:YYImageTypePNG];
    encoder.loopCount = 0;
    [encoder addImage:seedAndHintImage duration:0];
    
    // 账户数据，用来生成二维码
    NSDictionary *accountItemsDictionary = datas[1];
    
    // 账户数据转字符串
    NSError *error = nil;
    NSData *accountsData = [NSJSONSerialization dataWithJSONObject:accountItemsDictionary options:0 error:&error];
//    NSString *accountsString = [[NSString alloc] initWithData:accountsData encoding:NSUTF8StringEncoding];
//    DLog(@"account string: %@", accountsString);
    NSString *accountsBase64String = [accountsData base64EncodedStringWithOptions:0];
    DLog(@"accounts base64 string: %@", accountsBase64String);
    DLog(@"accounts string from base64: %@", [[NSString alloc] initWithData:[[NSData alloc] initWithBase64EncodedString:accountsBase64String options:0] encoding:NSUTF8StringEncoding]);
    
    // 切分字符
    float maxCharacterCount = 512.f;
    int groups = (int)ceil(accountsBase64String.length / maxCharacterCount);
    DLog(@"account string groups: %d", groups);
    for (int i = 0; i < groups; i++) {
        NSString *slicedString = [accountsBase64String substringWithRange:NSMakeRange(i * maxCharacterCount, MIN(accountsBase64String.length - i *maxCharacterCount, maxCharacterCount))];
        UIImage *qrCodeImage = [BTCQRCode imageForString:slicedString size:CGSizeMake(800.f, 800.f) scale:2.f];
        // 逐帧压入
        [encoder addImage:qrCodeImage duration:0];
    }
    
    // 编码生成图片
    NSData *apngData = [encoder encode];
    YYImage *image = [YYImage imageWithData:apngData scale:2.f];
    
    return image;
}

+ (void)saveToLocalPhotoLibraryWithCompleiton:(void (^)(NSURL *, NSError *))completion {
    UIImage *exportedImage = [self exportImage];
    if (!exportedImage) {
        completion(nil, [NSError errorWithDomain:CBWErrorDomain code:0 userInfo:@{NSLocalizedDescriptionKey: NSLocalizedStringFromTable(@"Error no_image_to_be_exported", @"CBW", nil)}]);
    }
    
    [exportedImage yy_saveToAlbumWithCompletionBlock:^(NSURL * _Nullable assetURL, NSError * _Nullable error) {
        completion(assetURL, error);
    }];
}

+ (void)deleteCloudKitRecord {
    CKContainer *container = [CKContainer defaultContainer];
    [container accountStatusWithCompletionHandler:^(CKAccountStatus accountStatus, NSError * _Nullable error) {
        if (accountStatus == CKAccountStatusAvailable) {
            // get private database
            CKDatabase *database = container.privateCloudDatabase;
            // the record
            CKRecordID *backupRecordID = [[CKRecordID alloc] initWithRecordName:@"1"];
            [database deleteRecordWithID:backupRecordID completionHandler:^(CKRecordID * _Nullable recordID, NSError * _Nullable error) {
                
            }];
        }
    }];
}

// TODO: handle NSUbiquityIdentityDidChangeNotification, if another account logged in. alert user to switch account.
+ (void)saveToCloudKitWithCompletion:(void (^)(NSError *))completion {
    NSArray *datas = [self getDatas];
    if (!datas) {
        completion([NSError errorWithDomain:CBWErrorDomain code:0 userInfo:@{NSLocalizedDescriptionKey: NSLocalizedStringFromTable(@"Error no_image_to_be_exported", @"CBW", nil)}]);
    }
    // check available
    CKContainer *container = [CKContainer defaultContainer];
    [container accountStatusWithCompletionHandler:^(CKAccountStatus accountStatus, NSError * _Nullable error) {
        if (accountStatus == CKAccountStatusAvailable) {
            // get private database
            CKDatabase *database = container.privateCloudDatabase;
            // the record
            CKRecordID *backupRecordID = [[CKRecordID alloc] initWithRecordName:@"1"];
            [database fetchRecordWithID:backupRecordID completionHandler:^(CKRecord * _Nullable record, NSError * _Nullable error) {
                if (error && error.code != 11) {// 11: not found
                    completion(error);
                } else {
                    CKRecord *backupRecord = record;
                    if (!backupRecord) {
                        backupRecord = [[CKRecord alloc] initWithRecordType:@"Backup" recordID:backupRecordID];
                    }
                    
                    if (backupRecord) {
                        // save backup
                        NSError *error = nil;
                        NSData *data = [NSJSONSerialization dataWithJSONObject:datas options:0 error:&error];
                        NSString *dataString = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
                        backupRecord[@"dataString"] = dataString;
                        [database saveRecord:backupRecord completionHandler:^(CKRecord * _Nullable record, NSError * _Nullable error) {
                            if (error) {
                                NSLog(@"save error: %@", error);
                                completion(error);
                            } else {
                                DLog(@"saved record: %@", record);
                                completion(nil);
                            }
                        }];
                    } else {
                        completion([NSError errorWithDomain:@"CBWBackup" code:500 userInfo:@{@"message":@"Create record failed!"}]);
                    }
                }
            }];
            
        } else {
            NSLog(@"CloudKit not available");
            completion([NSError errorWithDomain:@"CBWBackup" code:404 userInfo:@{@"message":@"CloudKit not available!"}]);
        }
    }];
}

+ (void)toggleiCloudBySwith:(UISwitch *)aSwitch inViewController:(UIViewController *)viewController {
    if ([[NSUserDefaults standardUserDefaults] boolForKey:CBWUserDefaultsiCloudEnabledKey]) {
        // toggle off
        [[NSUserDefaults standardUserDefaults] setBool:NO forKey:CBWUserDefaultsiCloudEnabledKey];
        if ([[NSUserDefaults standardUserDefaults] synchronize]) {
            [aSwitch setOn:NO animated:YES];
        }
    } else {
        // toggle on
        CKContainer *container = [CKContainer defaultContainer];
        [container accountStatusWithCompletionHandler:^(CKAccountStatus accountStatus, NSError * _Nullable error) {
            if (accountStatus == CKAccountStatusAvailable) {
//                [self saveToCloudKitWithCompletion:^(NSError *error) {
                    dispatch_async(dispatch_get_main_queue(), ^{
//                        if (error) {
//                            
//                            UIAlertController *alert = [UIAlertController alertControllerWithTitle:NSLocalizedStringFromTable(@"Failed", @"CBW", nil) message:error.localizedDescription preferredStyle:UIAlertControllerStyleAlert];
//                            UIAlertAction *okay = [UIAlertAction actionWithTitle:NSLocalizedStringFromTable(@"Okay", @"CBW", nil) style:UIAlertActionStyleCancel handler:nil];
//                            [alert addAction:okay];
//                            [viewController presentViewController:alert animated:YES completion:^{
//                                [aSwitch setOn:NO animated:YES];
//                            }];
//                            
//                        } else {
                            [[NSUserDefaults standardUserDefaults] setBool:YES forKey:CBWUserDefaultsiCloudEnabledKey];
                            if ([[NSUserDefaults standardUserDefaults] synchronize]) {
                                [aSwitch setOn:YES animated:YES];
                            }
//                        }
                    });
//                }];
            } else {
                dispatch_async(dispatch_get_main_queue(), ^{
                    UIAlertController *alert = [UIAlertController alertControllerWithTitle:NSLocalizedStringFromTable(@"Error", @"CBW", nil) message:NSLocalizedStringFromTable(@"Alert Message need_icloud_account_signed_in", @"CBW", nil) preferredStyle:UIAlertControllerStyleAlert];
                    UIAlertAction *okay = [UIAlertAction actionWithTitle:NSLocalizedStringFromTable(@"Okay", @"CBW", nil) style:UIAlertActionStyleCancel handler:nil];
                    [alert addAction:okay];
                    [viewController presentViewController:alert animated:YES completion:^{
                        [aSwitch setOn:NO animated:YES];
                    }];
                });
            }
        }];
    }
}

+ (BOOL)isiCloudAccountSignedIn {
    if ([NSFileManager defaultManager].ubiquityIdentityToken) {
        return YES;
    }
    return NO;
}

@end
