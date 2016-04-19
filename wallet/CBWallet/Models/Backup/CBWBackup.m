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

@implementation CBWBackup

- (NSArray *)getDatas {
    // add seed
    NSMutableArray *datas = [NSMutableArray arrayWithObject:[SSKeychain passwordForService:CBWKeychainSeedService account:CBWKeychainAccountDefault]];
    
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

- (UIImage *)exportImage {
    NSMutableArray *datas = [self.getDatas mutableCopy];
    if (datas.count > 0) {
        NSString *seed = [datas firstObject];
        UIImage *seedQRCodeImage = [BTCQRCode imageForString:seed size:CGSizeMake(800.f, 800.f) scale:2.f];
        
        YYImageEncoder *encoder = [[YYImageEncoder alloc] initWithType:YYImageTypePNG];
        encoder.loopCount = 0;
        [encoder addImage:seedQRCodeImage duration:0];
        
        [datas removeObject:seed];
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
        
        YYImageDecoder *decoder = [YYImageDecoder decoderWithData:apngData scale:2.f];
        DLog(@"decoder frames count: %ld", decoder.frameCount);
        
        YYImage *image = [YYImage imageWithData:apngData scale:2.f];
        return image;
    }
    return nil;
}

- (void)saveToLocalPhotoLibraryWithCompleiton:(void (^)(NSURL *, NSError *))completion {
    [[self exportImage] yy_saveToAlbumWithCompletionBlock:^(NSURL * _Nullable assetURL, NSError * _Nullable error) {
        completion(assetURL, error);
    }];
}

@end
