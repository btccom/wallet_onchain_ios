//
//  CBWBackup.h
//  CBWallet
//
//  Created by Zin (noteon.com) on 16/4/10.
//  Copyright © 2016年 Bitmain. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CBWBackup : NSObject

/// <code>[seed,
///        {account idx: [label, address count, {address idx: [label, dirty]}]
- (NSArray *)getDatas;
- (UIImage *)exportImage;
- (void)saveToLocalPhotoLibraryWithCompleiton:(void(^)(NSURL *assetURL, NSError *error))completion;

@end
