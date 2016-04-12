//
//  CBWiCloud.m
//  CBWallet
//
//  Created by Zin (noteon.com) on 16/4/10.
//  Copyright © 2016年 Bitmain. All rights reserved.
//

#import "CBWiCloud.h"
#import "CBWiCloudDocument.h"

static NSString *const kCBWiCloudDataWrapperKey = @"data";
static NSString *const kCBWiCloudVersionKey = @"version";
static NSString *const kCBWiCloudCreationDateKey = @"creationDate";
static NSString *const kCBWiCloudBackupFileExtension = @"cbb";

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
    [self saveWithData:nil];
}

+ (void)saveWithData:(id)data {
    if (![data isKindOfClass:[NSNull class]]) {
        NSDate *date = [NSDate date];
        NSNumber *version = @1;
        NSDictionary *wrappedData = @{kCBWiCloudVersionKey: version, kCBWiCloudCreationDateKey: date, kCBWiCloudDataWrapperKey: data};
        NSString *fileName = [NSString stringWithFormat:@"%@.%@", [NSUUID UUID].UUIDString, kCBWiCloudBackupFileExtension];
        
        NSError *error = nil;
        NSString *contents = [[NSString alloc] initWithData:[NSJSONSerialization dataWithJSONObject:wrappedData options:0 error:&error] encoding:NSUTF8StringEncoding];
        
        if (error) {
            NSLog(@"format backup data error: %@", error);
            return;
        }
        
        NSURL *uniquityFileURL = [[self ubiquityDocumentsURL] URLByAppendingPathComponent:fileName];
        
        CBWiCloudDocument *document = [[CBWiCloudDocument alloc] initWithFileURL:uniquityFileURL];
        if (document.contents.length > 0) {//existing
            document.contents = contents;
            [document saveToURL:uniquityFileURL
               forSaveOperation:UIDocumentSaveForOverwriting
              completionHandler:^(BOOL success) {
//                  completionHandler(success);
              }];
        } else {
            document.contents = contents;
            [document saveToURL:uniquityFileURL
               forSaveOperation:UIDocumentSaveForCreating
              completionHandler:^(BOOL success) {
//                  completionHandler(success);
              }];
        }
    }
}

+ (void)fetchWithCompletion:(void (^)(NSError *, id))completion {
    
}


#pragma mark - Private Method

+ (NSURL *)ubiquityDocumentsURL {
    return [[[NSFileManager defaultManager] URLForUbiquityContainerIdentifier:nil] URLByAppendingPathComponent:@"Documents"];
}

@end
