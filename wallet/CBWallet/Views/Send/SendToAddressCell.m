//
//  SendToAddressCell.m
//  CBWallet
//
//  Created by Zin (noteon.com) on 16/4/6.
//  Copyright © 2016年 Bitmain. All rights reserved.
//

#import "SendToAddressCell.h"

@interface SendToAddressCell ()

@property (nonatomic, weak, readwrite) SendToAddressCellDeleteButton *deleteButton;

@end

@implementation SendToAddressCell

- (SendToAddressCellDeleteButton *)deleteButton {
    if (!_deleteButton) {
        SendToAddressCellDeleteButton *button = [[SendToAddressCellDeleteButton alloc] init];
        button.cell = self;
        [self.contentView addSubview:button];
        _deleteButton = button;
    }
    return _deleteButton;
}

- (void)willMoveToSuperview:(UIView *)newSuperview {
    [super willMoveToSuperview:newSuperview];
    
    self.txsLabel.hidden = YES;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    [self.contentView bringSubviewToFront:self.deleteButton];
    self.deleteButton.frame = CGRectMake(0, 0, CGRectGetMaxX(self.imageView.frame) + CBWLayoutInnerSpace, CGRectGetHeight(self.contentView.frame));
    
    self.imageView.center = CGPointMake(self.imageView.center.x, CGRectGetMidY(self.addressLabel.frame));
    
    CGRect labelFrame = self.labelLabel.frame;
    labelFrame.origin.x = CGRectGetMaxX(self.deleteButton.frame);
    CGFloat deltaX = CGRectGetMinX(labelFrame) - CGRectGetMinX(self.labelLabel.frame);
    self.labelLabel.frame = labelFrame;
    
    CGRect addressFrame = self.addressLabel.frame;
    addressFrame.origin.x += deltaX;
    addressFrame.size.width -= deltaX;
    self.addressLabel.frame = addressFrame;
    
}

@end

@implementation SendToAddressCellDeleteButton

@end
