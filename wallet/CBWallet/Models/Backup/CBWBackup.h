//
//  CBWBackup.h
//  CBWallet
//
//  Created by Zin (noteon.com) on 16/4/10.
//  Copyright © 2016年 Bitmain. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CBWBackup : NSObject

- (NSArray *)getDatas;
- (UIImage *)exportImage;
- (BOOL)saveToLocalPhotoLibrary;

@end
