//
//  CBWiCloudDocument.m
//  CBWallet
//
//  Created by Zin (noteon.com) on 16/4/10.
//  Copyright © 2016年 Bitmain. All rights reserved.
//

#import "CBWiCloudDocument.h"

@implementation CBWiCloudDocument

- (BOOL)loadFromContents:(id)contents ofType:(NSString *)typeName error:(NSError *__autoreleasing *)outError {
    if ([contents length] > 0) {
        self.contents = [[NSString alloc] initWithBytes:[contents bytes]
                                                 length:[contents length]
                                               encoding:NSUTF8StringEncoding];
    } else {
        self.contents = @"";
    }
    return YES;
}

- (id)contentsForType:(NSString *)typeName error:(NSError *__autoreleasing *)outError {
    if (_contents.length == 0) {
        self.contents = @"";
    }
    NSData *data = [_contents dataUsingEncoding:NSUTF8StringEncoding];
    
    return data;
}

@end
