//
//  CBWBackup.h
//  CBWallet
//
//  Created by Zin (noteon.com) on 16/4/10.
//  Copyright © 2016年 Bitmain. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CBWBackup : NSObject

/// <pre>[[seed, hint],<br>
/// {account idx:<br>
///   [account label,<br>
///    address count,<br>
///    {address idx: [address label, dirty, archived],<br>
///     address idx: address properties, ...address item}],<br>
///  account idx: account properties, ...account item}]</pre>
/// for watched account <code><b>address item</b></code> will be <code><b>address:label</b></code>
+ (NSArray *)getDatas;
+ (UIImage *)exportImage;
+ (void)saveToLocalPhotoLibraryWithCompleiton:(void(^)(NSURL *assetURL, NSError *error))completion;
+ (void)deleteCloudKitRecord;
+ (void)saveToCloudKitWithCompletion:(void(^)(NSError *error))completion;
+ (void)toggleiCloudBySwith:(UISwitch *)aSwitch inViewController:(UIViewController *)viewController;
+ (BOOL)isiCloudAccountSignedIn;
@end
