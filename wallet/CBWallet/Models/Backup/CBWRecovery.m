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

#import <CloudKit/CloudKit.h>

@interface CBWRecovery ()

@property (nonatomic, strong) NSArray *datas;
@property (nonatomic, strong) NSURL *assetURL;

@end

@implementation CBWRecovery

+ (NSDictionary *)defaultAccountItemsDictionary {
    return @{[@(CBWRecordWatchedIDX) stringValue]: @[NSLocalizedStringFromTable(@"Label watched_account", @"CBW", nil), @0],
             [@0 stringValue]: @[NSLocalizedStringFromTable(@"Label default_account", @"CBW", nil), @1]
             };
}

- (NSString *)hint {
    return [self.datas.firstObject count] > 1 ? [[self.datas firstObject] lastObject] : nil;
}

- (instancetype)initWithAssetURL:(NSURL *)assetURL {
    self = [super init];
    if (self) {
        if (!assetURL) {
            return nil;
        }
        _assetURL = assetURL;
    }
    
    return self;
}

- (void)fetchAssetDatasWithCompletion:(void (^)(NSError *))completion {
    
    // TODO: 图片校验及容错
    
    ALAssetsLibrary *assetslibrary = [[ALAssetsLibrary alloc] init];
    [assetslibrary assetForURL:self.assetURL resultBlock:^(ALAsset *asset) {
        
        ALAssetRepresentation *representation = asset.defaultRepresentation;
        //            long long size = representation.size;
        NSUInteger size = (NSUInteger)representation.size;
        NSMutableData *rawData = [[NSMutableData alloc] initWithCapacity:size];
        void *buffer = [rawData mutableBytes];
        [representation getBytes:buffer fromOffset:0 length:size error:nil];
        NSData *apngData = [[NSData alloc] initWithBytes:buffer length:size];
        YYImageDecoder *decoder = [YYImageDecoder decoderWithData:apngData scale:2.f];
        DLog(@"found frames: %ld", (unsigned long)decoder.frameCount);
        
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
                DLog(@"seed and hint: %@ ", featureR.messageString);
                [datas addObject:[NSJSONSerialization JSONObjectWithData:[featureR.messageString dataUsingEncoding:NSUTF8StringEncoding] options:NSJSONReadingAllowFragments error:nil]];
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
//            completion(error);// 只有 seed 时候应该仍然可以返回数据
//            return;
        }
        DLog(@"account datas: %@", accountsData);
        if (![accountsData isKindOfClass:[NSArray class]]) {
            accountsData = @[[CBWRecovery defaultAccountItemsDictionary]];
        }
        [datas addObjectsFromArray:accountsData];
        
        _datas = [datas copy];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            completion(nil);
        });
    } failureBlock:^(NSError *error) {
        NSLog(@"Asset error: %@", error);
        dispatch_async(dispatch_get_main_queue(), ^{
            completion(error);
        });
    }];
}

- (instancetype)initWithDatas:(NSArray *)datas {
    self = [super init];
    if (self) {
        _datas = datas;
    }
    return self;
}

- (void)fetchCloudKitDataWithCompletion:(void (^)(NSError *))completion {
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
                    completion(nil);
                    // set data
                    NSString *dataString = record[@"dataString"];
                    NSError *error = nil;
                    _datas = [NSJSONSerialization JSONObjectWithData:[dataString dataUsingEncoding:NSUTF8StringEncoding] options:NSJSONReadingAllowFragments error:&error];
                    if (error) {
                        completion(error);
                    }
                }
            }];
        } else {
            NSLog(@"CloudKit not available");
            completion([NSError errorWithDomain:@"CBWBackup" code:404 userInfo:@{@"message":@"CloudKit not available!"}]);
        }
    }];
}

- (BOOL)recoverWithCode:(NSString *)code {
    DLog(@"recover with datas: %@", self.datas);
    
    if (self.datas.count == 0) {
        NSLog(@"no datas to be recovered.");
        return NO;
    }
    
    NSString *encryptedSeed = [[self.datas firstObject] firstObject];
    
    if (!encryptedSeed) {
        NSLog(@"Not found encrypted seed data");
        return NO;
    }
    
    // save encrypted seed
    [SSKeychain setPassword:encryptedSeed forService:CBWKeychainSeedService account:CBWKeychainAccountDefault];
    // save hint
    NSString *hint = self.hint;//[[self.datas firstObject] lastObject];
    if (hint) {
        [SSKeychain setPassword:hint forService:CBWKeychainHintService account:CBWKeychainAccountDefault];
    }
    
    // guard
    if (![[Guard globalGuard] checkInWithCode:code]) {
        NSLog(@"recover failed");
        return NO;
    }
    
    CBWAccountStore *accountStore = [[CBWAccountStore alloc] init];
    NSDictionary *accountItemsDictionary = self.datas[1];
    [accountItemsDictionary enumerateKeysAndObjectsUsingBlock:^(id  _Nonnull key, id  _Nonnull obj, BOOL * _Nonnull stop) {
        NSArray *accountProperties = obj;
        
        DLog(@"recover account with data: %@", accountProperties);
        
        // save account
        NSInteger accountIdx = [key integerValue];
        NSString *accountLabel = [accountProperties firstObject];
        if (!accountLabel) {
            accountLabel = @"";
        }
        CBWAccount *account = [CBWAccount newAccountWithIdx:accountIdx label:accountLabel inStore:accountStore];
        account.ignoringSync = YES;
        [account saveWithError:nil];
        
        DLog(@"account saved");
        
        // address
        CBWAddressStore *adderssStore = [[CBWAddressStore alloc] initWithAccountIdx:account.idx];
        NSDictionary *addresseItemsDictionary = nil;
        if (accountProperties.count > 2) {
            addresseItemsDictionary = accountProperties[2];
        }
        
        DLog(@"recover addresses with data: %@", addresseItemsDictionary);
        
        if (account.idx == CBWRecordWatchedIDX) {
            // watched account
            [addresseItemsDictionary enumerateKeysAndObjectsUsingBlock:^(id  _Nonnull key, id  _Nonnull obj, BOOL * _Nonnull stop) {
                NSString *addressString = key;
                NSString *label = obj;
                
                // save address
                CBWAddress *address = [CBWAddress newAdress:addressString withLabel:label idx:CBWRecordWatchedIDX archived:NO dirty:NO internal:NO accountRid:account.rid accountIdx:account.idx inStore:adderssStore];
                address.ignoringSync = YES;
                [address saveWithError:nil];
            }];
            
            DLog(@"recovered watched addresses (%ld)", adderssStore.count);
        } else {
            NSUInteger addressCount = [accountProperties[1] unsignedIntegerValue];
            DLog(@"address count: %ld", (unsigned long)addressCount);
            for (NSUInteger addressIdx = 0; addressIdx < addressCount; addressIdx ++) {
                
                NSString *addressString = [CBWAddress addressStringWithIdx:addressIdx acountIdx:account.idx];
                NSString *label = @"";
                BOOL dirty = NO;
                BOOL archived = NO;
                
                NSString *addressIdxKey = [@(addressIdx) stringValue];
                NSArray *addressProperties = [addresseItemsDictionary objectForKey:addressIdxKey];//[label, dirty, archived]
                if (addressProperties.count >= 2) {
                    label = addressProperties[0];
                    dirty = [addressProperties[1] boolValue];
                    archived = [addressProperties[2] boolValue];
                }
                
                // save address
                CBWAddress *address = [CBWAddress newAdress:addressString withLabel:label idx:addressIdx archived:archived dirty:dirty internal:NO accountRid:account.rid accountIdx:account.idx inStore:adderssStore];
                address.ignoringSync = YES;
                [address saveWithError:nil];
            }
            
            DLog(@"recovered user addresses (%ld)", adderssStore.count);
        }
    }];
    
    return YES;
}

/// 验证数据，从相册中恢复时，需要校验数据完整性
- (BOOL)validateData:(NSArray *)data {
    return YES;
}
@end
