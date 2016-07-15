//
//  UIViewControllerUserInteractionSetable.h
//  CBWallet
//
//  Created by Zin on 16/7/15.
//  Copyright © 2016年 Bitmain. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol UIViewControllerUserInteractionSetable <NSObject>

@optional
@property (nonatomic, assign) BOOL userInteractionDisabled;

@end
