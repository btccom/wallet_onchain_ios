//
//  DrawerStaticCellModel.h
//  CBWallet
//
//  Created by Zin on 16/7/14.
//  Copyright © 2016年 Bitmain. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface DrawerStaticCellModel : NSObject

@property (nonatomic, copy, nullable) NSString *iconName;
@property (nonatomic, copy, nullable) NSString *text;
@property (nonatomic, copy, nullable) NSString *detail;

@property (nonatomic, copy, nullable) NSString *controllerClassName;

@property (nonatomic, weak, nullable) UITableViewCell *cell;

@end
