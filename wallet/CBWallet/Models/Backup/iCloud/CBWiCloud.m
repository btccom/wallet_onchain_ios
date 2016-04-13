//
//  CBWiCloud.m
//  CBWallet
//
//  Created by Zin (noteon.com) on 16/4/10.
//  Copyright © 2016年 Bitmain. All rights reserved.
//

#import "CBWiCloud.h"
#import "CBWiCloudDocument.h"
#import "CBWBackup.h"

static NSString *const kCBWiCloudDataWrapperKey = @"data";
static NSString *const kCBWiCloudVersionKey = @"version";
static NSString *const kCBWiCloudCreationDateKey = @"creationDate";
static NSString *const kCBWiCloudBackupFileExtension = @"cbb";
static NSString *const kCBWiCloudBackupFileName = @"cbw-s-ud-b7";

@interface CBWiCloud ()

@property (nonatomic, strong) CBWiCloudFetchCompletion fetchCompletion;
@property (nonatomic, strong) NSMetadataQuery *query;

@end

@implementation CBWiCloud

+ (void)toggleiCloudBySwith:(UISwitch *)aSwitch inViewController:(UIViewController *)viewController {
    if ([[NSUserDefaults standardUserDefaults] boolForKey:CBWUserDefaultsiCloudEnabledKey]) {
        // toggle off
        [aSwitch setOn:NO animated:YES];
        [[NSUserDefaults standardUserDefaults] setBool:NO forKey:CBWUserDefaultsiCloudEnabledKey];
        [[NSUserDefaults standardUserDefaults] synchronize];
    } else {
        // toggle on
        if (![self isiCloudAccountSignedIn]) {
            UIAlertController *alert = [UIAlertController alertControllerWithTitle:NSLocalizedStringFromTable(@"Error", @"CBW", nil) message:NSLocalizedStringFromTable(@"Alert Message need_icloud_account_signed_in", @"CBW", nil) preferredStyle:UIAlertControllerStyleAlert];
            UIAlertAction *okay = [UIAlertAction actionWithTitle:NSLocalizedStringFromTable(@"Okay", @"CBW", nil) style:UIAlertActionStyleCancel handler:nil];
            [alert addAction:okay];
            [viewController presentViewController:alert animated:YES completion:^{
                [aSwitch setOn:NO animated:YES];
            }];
        } else {
            [aSwitch setOn:YES animated:YES];
            [[NSUserDefaults standardUserDefaults] setBool:YES forKey:CBWUserDefaultsiCloudEnabledKey];
            [[NSUserDefaults standardUserDefaults] synchronize];
            // TODO: sync
            [self saveBackupData];
        }
    }
}

+ (BOOL)isiCloudAccountSignedIn {
    if ([NSFileManager defaultManager].ubiquityIdentityToken) {
        return YES;
    }
    return NO;
}

+ (void)saveBackupData {
    if (![[NSUserDefaults standardUserDefaults] boolForKey:CBWUserDefaultsiCloudEnabledKey]) {
        return;
    }
    
    CBWBackup *backup = [[CBWBackup alloc] init];
    [self saveData:[backup getDatas] withFileName:[NSString stringWithFormat:@"%@.%@", kCBWiCloudBackupFileName, kCBWiCloudBackupFileExtension] completion:^(BOOL success) {
        if (success) {
            DLog(@"backup saved to iCloud");
            [[NSUserDefaults standardUserDefaults] setObject:[NSDate date] forKey:CBWUserDefaultsiCloudSyncDateKey];
            [[NSUserDefaults standardUserDefaults] synchronize];
        }
    }];
}

+ (void)saveData:(id)data withFileName:(NSString *)fileName completion:(void (^)(BOOL))completion {
    if (![self ubiquityDocumentsURL]) {
        completion(NO);
        return;
    }
    
    if (![data isKindOfClass:[NSNull class]] && data) {
        NSTimeInterval timestamp = [[NSDate date] timeIntervalSince1970];
        NSNumber *version = @1;
        NSDictionary *wrappedData = @{kCBWiCloudVersionKey: version, kCBWiCloudCreationDateKey: @(timestamp), kCBWiCloudDataWrapperKey: data};
        
        NSError *error = nil;
        NSString *contents = [[NSString alloc] initWithData:[NSJSONSerialization dataWithJSONObject:wrappedData options:0 error:&error] encoding:NSUTF8StringEncoding];
        
        if (error) {
            NSLog(@"format backup data error: %@", error);
            completion(NO);
            return;
        }
        
        NSURL *uniquityFileURL = [[self ubiquityDocumentsURL] URLByAppendingPathComponent:fileName];
        
        CBWiCloudDocument *document = [[CBWiCloudDocument alloc] initWithFileURL:uniquityFileURL];
        if (document.contents.length > 0) {//existing
            document.contents = contents;
            [document saveToURL:uniquityFileURL
               forSaveOperation:UIDocumentSaveForOverwriting
              completionHandler:^(BOOL success) {
                  completion(success);
              }];
        } else {
            document.contents = contents;
            [document saveToURL:uniquityFileURL
               forSaveOperation:UIDocumentSaveForCreating
              completionHandler:^(BOOL success) {
                  completion(success);
              }];
        }
    }
}

- (void)fetchBackupDataWithCompletion:(CBWiCloudFetchCompletion)completion {
    [self fetchWithFileName:[NSString stringWithFormat:@"%@.%@", kCBWiCloudBackupFileName, kCBWiCloudBackupFileExtension] withCompletion:^(NSError *error, id data) {
        if (error) {
            completion(error, nil);
        } else {
            if (data) {
                NSString *contents = data;
                NSError *error = nil;
                id jsonData = [NSJSONSerialization JSONObjectWithData:[contents dataUsingEncoding:NSUTF8StringEncoding] options:NSJSONReadingAllowFragments error:&error];
                
                if ([jsonData isKindOfClass:[NSDictionary class]]) {
                    NSDictionary *wrappedDictionary = jsonData;
                    completion(nil, [wrappedDictionary objectForKey:kCBWiCloudDataWrapperKey]);
                } else {
                    completion(error, nil);
                }
                
            } else {
                completion(nil, nil);
            }
        }
    }];
}

- (void)fetchWithFileName:(NSString *)fileName withCompletion:(CBWiCloudFetchCompletion)completion {
    NSLog(@"fetch file name: %@", fileName);
    if (![CBWiCloud ubiquityDocumentsURL]) {
        completion(nil, nil);
        return;
    }
    _fetchCompletion = completion;
    
    _query = [[NSMetadataQuery alloc] init];
    [_query setSearchScopes:[NSArray arrayWithObject:NSMetadataQueryUbiquitousDocumentsScope]];// NSMetadataQueryUbiquitousDataScope?
    _query.predicate = [NSPredicate predicateWithFormat:@"%K LIKE %@", NSMetadataItemFSNameKey, fileName];
    
    NSLog(@"Query predicate: %@", _query.predicate);
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(queryDidFinishGethering:)
                                                 name:NSMetadataQueryDidFinishGatheringNotification
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(queryDidFinishGethering:)
                                                 name:NSMetadataQueryDidUpdateNotification
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(queryDidStart:)
                                                 name:NSMetadataQueryDidStartGatheringNotification
                                               object:nil];
    
    [_query startQuery];
//    if (![_query isStarted]) {
//        [_query startQuery];
//        [_query enableUpdates];
//    }
    
}


#pragma mark - Private Method

+ (NSURL *)ubiquityDocumentsURL {
    return [[[NSFileManager defaultManager] URLForUbiquityContainerIdentifier:nil] URLByAppendingPathComponent:@"Documents"];
}

- (void)queryDidStart:(NSNotification *)notification {
    NSLog(@"query start");
}

- (void)queryDidFinishGethering:(NSNotification *)notification {
    NSMetadataQuery *query = [notification object];
    [query disableUpdates];
    [query stopQuery];
    NSLog(@"query finish: %@", query);
    
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:NSMetadataQueryDidFinishGatheringNotification
                                                  object:nil];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:NSMetadataQueryDidUpdateNotification
                                                  object:nil];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:NSMetadataQueryDidStartGatheringNotification
                                                  object:nil];
    
    [self loadDataWithQuery:query];
    
}
- (void)loadDataWithQuery:(NSMetadataQuery *)query {
    NSArray *items = [query results];
    NSLog(@"fetched items: %@", items);
    
    if (items.count == 0) {
        self.fetchCompletion(nil, nil);
        self.fetchCompletion = nil;
        return;
    }
    
    NSMetadataItem *item = [items firstObject];
    
    NSURL *fileURL = [item valueForAttribute:NSMetadataItemURLKey];
    CBWiCloudDocument *document = [[CBWiCloudDocument alloc] initWithFileURL:fileURL];
    [document openWithCompletionHandler:^(BOOL success) {
        if (success) {
            self.fetchCompletion(nil, document.contents);
        } else {
            self.fetchCompletion(nil, nil);
        }
        self.fetchCompletion = nil;
    }];
}

@end
