//
//  FormControlInputActionCell.m
//  CBWallet
//
//  Created by Zin (noteon.com) on 16/4/5.
//  Copyright © 2016年 Bitmain. All rights reserved.
//

#import "FormControlInputActionCell.h"

@implementation FormControlInputActionCell


- (UIButton *)actionButton {
    if (!_actionButton) {
        UIButton *button = [[UIButton alloc] initWithFrame:CGRectMake(CBWCellHeightDefault, CBWCellHeightDefault, CBWCellHeightDefault, CBWCellHeightDefault)];
        [button setImage:[UIImage imageNamed:@"icon_list_mini"] forState:UIControlStateNormal];
        self.accessoryView = button;
        _actionButton = button;
    }
    return _actionButton;
}

@end
