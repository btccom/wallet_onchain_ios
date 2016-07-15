//
//  DrawerSectionHeaderView.m
//  CBWallet
//
//  Created by Zin on 16/7/14.
//  Copyright © 2016年 Bitmain. All rights reserved.
//

#import "DrawerSectionHeaderView.h"

@implementation DrawerSectionHeaderView

- (void)willMoveToSuperview:(UIView *)newSuperview {
    [super willMoveToSuperview:newSuperview];
    
    self.textLabel.font = [UIFont systemFontOfSize:UIFont.smallSystemFontSize];
    self.textLabel.textColor = [[UIColor CBWWhiteColor] colorWithAlphaComponent:0.6];
    self.contentView.backgroundColor = [UIColor CBWDrawerBackgroundColor];
}

@end
