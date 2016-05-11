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
    // add seed
    NSString *hint = [SSKeychain passwordForService:CBWKeychainHintService account:CBWKeychainAccountDefault];
    if (!hint) {
        hint = @"";
    }
    NSMutableArray *datas = [NSMutableArray arrayWithObject:@[[SSKeychain passwordForService:CBWKeychainSeedService account:CBWKeychainAccountDefault], hint]];
    
    NSMutableDictionary *accountsDictionary = [NSMutableDictionary dictionary];//{idx:[accountDataArray]}
    
    CBWAccountStore *accountStore = [[CBWAccountStore alloc] init];
    [accountStore fetch];
    
    if (accountStore.count > 0) {
        for (NSUInteger i = 0; i < accountStore.count; i ++) {
            
            CBWAccount *account = [accountStore recordAtIndex:i];
            
            NSString *label = account.label;
            if (!label) {
                label = @"";
            }
            NSMutableArray *accountDataArray = [NSMutableArray arrayWithObject:label];// account data [label]
            [accountsDictionary setObject:accountDataArray forKey:[@(account.idx) stringValue]];// idx: account data
            
            // 处理 address 数据
            CBWAddressStore *addressStore = [[CBWAddressStore alloc] initWithAccountIdx:account.idx];
            [addressStore fetch];
            [accountDataArray addObject:@(addressStore.count)];// account data [label, address count]
            
            if (addressStore.count > 0) {
                NSMutableDictionary *addressesDictionary = [NSMutableDictionary dictionary];//{idx:[addressDataArray]}
                for (NSUInteger j = 0; j < addressStore.count; j++) {
                    CBWAddress *address = [addressStore recordAtIndex:j];
                    if (account.idx == CBWRecordWatchedIdx) {
                        // watched account
                        NSString *label = address.label;
                        if (!label) {
                            label = @"";
                        }
                        [addressesDictionary setObject:label forKey:address.address];// address: label
                    } else if (address.isDirty || address.isArchived || address.label.length > 0) {// 属性不是初始值或设置了标签
                        NSString *label = address.label;
                        if (!label) {
                            label = @"";
                        }
                        NSArray *addressDataArray = @[label, @(address.isDirty), @(address.isArchived)];
                        [addressesDictionary setObject:addressDataArray forKey:[@(address.idx) stringValue]];// address: [label, dirty]
                    }
                }
                if (addressesDictionary.count > 0) {
                    [accountDataArray addObject:addressesDictionary];// account data [label, address count, {addresses}]
                }
            }
            
        }
        
        if (accountsDictionary.count > 0) {
            [datas addObject:accountsDictionary];
        }
    }
    
    DLog(@"formated datas: %@", datas);
    return [datas copy];
}

+ (UIImage *)exportImage {
    NSMutableArray *datas = [self.getDatas mutableCopy];
    if (datas.count > 0) {
        NSString *seedAndHint = [[NSString alloc] initWithData:[NSJSONSerialization dataWithJSONObject:[datas firstObject] options:0 error:nil] encoding:NSUTF8StringEncoding];
        UIImage *seedQRCodeImage = [BTCQRCode imageForString:seedAndHint size:CGSizeMake(800.f, 800.f) scale:2.f];
        
        YYImageEncoder *encoder = [[YYImageEncoder alloc] initWithType:YYImageTypePNG];
        encoder.loopCount = 0;
        [encoder addImage:seedQRCodeImage duration:0];
        // 移除 seed and hint，生成其他信息二维码
        [datas removeObjectAtIndex:0];
        NSError *error = nil;
        NSData *accountData = [NSJSONSerialization dataWithJSONObject:datas options:0 error:&error];
        NSString *accountString = [[NSString alloc] initWithData:accountData encoding:NSUTF8StringEncoding];
        DLog(@"account string: %@", accountString);
        // 切分字符
        float maxCharacterCount = 200.f;
        int groups = (int)ceil(accountString.length / maxCharacterCount);
        DLog(@"groups: %d", groups);
        for (int i = 0; i < groups; i++) {
            NSString *slicedString = [accountString substringWithRange:NSMakeRange(i * maxCharacterCount, MIN(accountString.length - i *maxCharacterCount, maxCharacterCount))];
            UIImage *qrCodeImage = [BTCQRCode imageForString:slicedString size:CGSizeMake(800.f, 800.f) scale:2.f];
            [encoder addImage:qrCodeImage duration:0];
        }
        
        NSData *apngData = [encoder encode];
        
        YYImage *image = [YYImage imageWithData:apngData scale:2.f];
        return image;
    }
    return nil;
}

+ (void)saveToLocalPhotoLibraryWithCompleiton:(void (^)(NSURL *, NSError *))completion {
    [[self exportImage] yy_saveToAlbumWithCompletionBlock:^(NSURL * _Nullable assetURL, NSError * _Nullable error) {
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
    // check available
    CKContainer *container = [CKContainer defaultContainer];
    [container accountStatusWithCompletionHandler:^(CKAccountStatus accountStatus, NSError * _Nullable error) {
        if (accountStatus == CKAccountStatusAvailable) {
            // get private database
            CKDatabase *database = container.privateCloudDatabase;
            // the record
            CKRecordID *backupRecordID = [[CKRecordID alloc] initWithRecordName:@"1"];
            [database fetchRecordWithID:backupRecordID completionHandler:^(CKRecord * _Nullable record, NSError * _Nullable error) {
                if (error) {
                    completion(error);
                } else {
                    CKRecord *backupRecord = record;
                    if (!backupRecord) {
                        backupRecord = [[CKRecord alloc] initWithRecordType:@"Backup" recordID:backupRecordID];
                    }
                    
                    if (backupRecord) {
                        // save backup
                        NSError *error = nil;
                        NSData *data = [NSJSONSerialization dataWithJSONObject:[self getDatas] options:0 error:&error];
                        NSString *dataString = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
                        backupRecord[@"dataString"] = dataString;
                        [database saveRecord:backupRecord completionHandler:^(CKRecord * _Nullable record, NSError * _Nullable error) {
                            if (error) {
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
                [self saveToCloudKitWithCompletion:^(NSError *error) {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        if (error) {
                            
                            UIAlertController *alert = [UIAlertController alertControllerWithTitle:NSLocalizedStringFromTable(@"Error", @"CBW", nil) message:error.localizedDescription preferredStyle:UIAlertControllerStyleAlert];
                            UIAlertAction *okay = [UIAlertAction actionWithTitle:NSLocalizedStringFromTable(@"Okay", @"CBW", nil) style:UIAlertActionStyleCancel handler:nil];
                            [alert addAction:okay];
                            [viewController presentViewController:alert animated:YES completion:^{
                                [aSwitch setOn:NO animated:YES];
                            }];
                            
                        } else {
                            [[NSUserDefaults standardUserDefaults] setBool:YES forKey:CBWUserDefaultsiCloudEnabledKey];
                            if ([[NSUserDefaults standardUserDefaults] synchronize]) {
                                [aSwitch setOn:YES animated:YES];
                            }
                        }
                    });
                }];
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
