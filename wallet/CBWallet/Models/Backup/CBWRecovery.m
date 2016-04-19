//
//  CBWRecovery.m
//  CBWallet
//
//  Created by Zin (noteon.com) on 16/4/10.
//  Copyright © 2016年 Bitmain. All rights reserved.
//

#import "CBWRecovery.h"
#import <AssetsLibrary/AssetsLibrary.h>
#import "YYImage.h"
#import "AESCrypt.h"
#import "SSKeychain.h"
#import "Database.h"
#import "Guard.h"

@interface CBWRecovery ()

@property (nonatomic, strong) NSArray *datas;

@end

@implementation CBWRecovery

- (instancetype)initWithAssetURL:(NSURL *)assetURL {
    self = [super init];
    if (self) {
        // TODO: 图片校验及容错
        
        ALAssetsLibrary *assetslibrary = [[ALAssetsLibrary alloc] init];
        [assetslibrary assetForURL:assetURL resultBlock:^(ALAsset *asset) {
            
            ALAssetRepresentation *representation = asset.defaultRepresentation;
            long long size = representation.size;
            NSMutableData *rawData = [[NSMutableData alloc] initWithCapacity:size];
            void *buffer = [rawData mutableBytes];
            [representation getBytes:buffer fromOffset:0 length:size error:nil];
            NSData *apngData = [[NSData alloc] initWithBytes:buffer length:size];
            YYImageDecoder *decoder = [YYImageDecoder decoderWithData:apngData scale:2.f];
            DLog(@"found frames: %ld", decoder.frameCount);
            
            UIImage *seedImage = [decoder frameAtIndex:0 decodeForDisplay:NO].image;
            
            NSMutableArray *datas = [[NSMutableArray alloc] init];
            
            // 获取二维码
            CIDetector* detector = [CIDetector detectorOfType:CIDetectorTypeQRCode context:[CIContext contextWithOptions:nil] options:@{CIDetectorAccuracy:CIDetectorAccuracyHigh}];
            
            // seed data
            if (detector) {
                DLog(@"detector ready");
                CIImage *ciimg = [CIImage imageWithCGImage:seedImage.CGImage];
                NSArray *featuresR = [detector featuresInImage:ciimg];
                
                for (CIQRCodeFeature* featureR in featuresR) {
                    DLog(@"seed: %@ ", featureR.messageString);
                    [datas addObject:featureR.messageString];
                }
            }
            
            // account datas
            NSMutableString *string = [NSMutableString string];
            for (NSInteger i = 1; i < decoder.frameCount; i++) {
                UIImage *image = [decoder frameAtIndex:i decodeForDisplay:NO].image;
                if (detector) {
                    CIImage *ciimg = [CIImage imageWithCGImage:image.CGImage];
                    NSArray *featuresR = [detector featuresInImage:ciimg];
                    
                    for (CIQRCodeFeature *featureR in featuresR) {
                        [string appendString:featureR.messageString];
                    }
                }
            }
            DLog(@"account datas string: %@", string);
            NSError *error = nil;
            id accountsData = [NSJSONSerialization JSONObjectWithData:[string dataUsingEncoding:NSUTF8StringEncoding] options:NSJSONReadingAllowFragments error:&error];
            if (error) {
                NSLog(@"JSON Error: %@", error);
            } else {
                DLog(@"account datas: %@", accountsData);
                if ([accountsData isKindOfClass:[NSArray class]]) {
                    [datas addObjectsFromArray:accountsData];
                }
            }
            
            _datas = [datas copy];
            
        } failureBlock:^(NSError *error) {
            NSLog(@"Asset error: %@", error);
        }];
    }
    
    return self;
}

- (instancetype)initWithDatas:(NSArray *)datas {
    self = [super init];
    if (self) {
        _datas = datas;
        DLog(@"recovery datas: %@", datas);
    }
    return self;
}

- (BOOL)recoverWithCode:(NSString *)code {
    DLog(@"recover with datas: %@", self.datas);
    
    if (self.datas.count == 0) {
        return NO;
    }
    NSString *encryptedSeed = [self.datas firstObject];
//    NSString *seed = [AESCrypt decrypt:encryptedSeed password:code];
//    DLog(@"decrypted seed: %@", seed);
//    
//    if (!seed) {
//        return NO;
//    }
    
    // save encrypted seed
    [SSKeychain setPassword:encryptedSeed forService:CBWKeychainSeedService account:CBWKeychainAccountDefault];
    
    // guard
    if (![[Guard globalGuard] checkInWithCode:code]) {
        return NO;
    }
    
    if (self.datas.count > 1) {
        CBWAccountStore *accountStore = [[CBWAccountStore alloc] init];
        NSDictionary *accountsDictionary = self.datas[1];
        [accountsDictionary enumerateKeysAndObjectsUsingBlock:^(id  _Nonnull key, id  _Nonnull obj, BOOL * _Nonnull stop) {
            NSArray *accountDataArray = obj;
            
            // save account
            CBWAccount *account = [CBWAccount newAccountWithIdx:[key integerValue] label:accountDataArray[0] inStore:accountStore];
            [account saveWithError:nil];
            
            // address
            CBWAddressStore *adderssStore = [[CBWAddressStore alloc] initWithAccountIdx:account.idx];
            NSDictionary *addressesDictionary = nil;
            if (accountDataArray.count > 2) {
                addressesDictionary = accountDataArray[2];
            }
            
            if (account.idx == CBWRecordWatchedIdx) {
                DLog(@"recover watched account");
                // watched account
                [addressesDictionary enumerateKeysAndObjectsUsingBlock:^(id  _Nonnull key, id  _Nonnull obj, BOOL * _Nonnull stop) {
                    NSString *addressString = key;
                    NSString *label = obj;
                    
                    // save address
                    CBWAddress *address = [CBWAddress newAdress:addressString withLabel:label idx:CBWRecordWatchedIdx archived:NO dirty:NO internal:NO accountRid:account.rid accountIdx:account.idx inStore:adderssStore];
                    [address saveWithError:nil];
                }];
            } else {
                DLog(@"recover user account: %ld", account.idx);
                
                NSUInteger addressCount = [accountDataArray[1] unsignedIntegerValue];
                DLog(@"address count: %ld", addressCount);
                for (NSUInteger addressIdx = 0; addressIdx < addressCount; addressIdx ++) {
                    
                    NSString *addressString = [CBWAddress addressStringWithIdx:addressIdx acountIdx:account.idx];
                    NSString *label = @"";
                    BOOL dirty = NO;
                    BOOL archived = NO;
                    
                    NSString *addressIdxKey = [@(addressIdx) stringValue];
                    NSArray *addressDataArray = [addressesDictionary objectForKey:addressIdxKey];//[label, dirty, archived]
                    if (addressDataArray.count >= 2) {
                        label = addressDataArray[0];
                        dirty = [addressDataArray[1] boolValue];
                        archived = [addressDataArray[2] boolValue];
                    }
                    
                    // save address
                    CBWAddress *address = [CBWAddress newAdress:addressString withLabel:label idx:addressIdx archived:archived dirty:dirty internal:NO accountRid:account.rid accountIdx:account.idx inStore:adderssStore];
                    [address saveWithError:nil];
                }
            }
        }];
    }
    
    return YES;
}

/// 验证数据，从相册中恢复时，需要校验数据完整性
- (BOOL)validateData:(NSArray *)data {
    return YES;
}
@end
