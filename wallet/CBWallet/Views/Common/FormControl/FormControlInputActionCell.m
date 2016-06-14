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
        UIButton *button = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, CBWCellHeightDefault, CBWCellHeightDefault)];
        [button setTitleColor:[UIColor CBWPrimaryColor] forState:UIControlStateNormal];
        [button setTitleColor:[[UIColor CBWPrimaryColor] colorWithAlphaComponent:0.5] forState:UIControlStateDisabled];
//        [button setImage:[UIImage imageNamed:@"icon_list_mini"] forState:UIControlStateNormal];
        self.accessoryView = button;
        _actionButton = button;
    }
    return _actionButton;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    // action button
    CGFloat cellWidth = CGRectGetWidth(self.frame);
    CGFloat cellHeight = CGRectGetHeight(self.frame);
    if (self.actionButton.currentTitle.length > 0) {
        CGSize textSize = [self.actionButton.currentTitle sizeWithFont:self.actionButton.titleLabel.font maxSize:CGSizeMake(CGRectGetWidth(self.frame) / 2.f, cellHeight)];
        CGFloat width = textSize.width;
        if (self.actionButton.currentImage) {
            width += CBWCellHeightDefault;
        } else {
            width += 32.f;
        }
        self.actionButton.frame = CGRectMake(cellWidth - width, 0, width, cellHeight);
    } else {
        self.actionButton.frame = CGRectMake(cellWidth - CBWCellHeightDefault, 0, CBWCellHeightDefault, cellHeight);
    }
    
    CGRect textFieldFrame = self.textField.frame;
    textFieldFrame.size.width = CGRectGetMinX(self.actionButton.frame) - CGRectGetMinX(textFieldFrame);
    self.textField.frame = textFieldFrame;
}

@end
