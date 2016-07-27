//
//  BlockButtonCell.m
//  wallet
//
//  Created by Zin (noteon.com) on 16/2/29.
//  Copyright © 2016年 Bitmain. All rights reserved.
//

#import "FormControlBlockButtonCell.h"

@implementation FormControlBlockButtonCell

- (void)setEnabled:(BOOL)enabled {
    _enabled = enabled;
    self.textLabel.alpha = enabled ? 1.f : CBWDisabledOpacity;
    self.userInteractionEnabled = enabled;
}

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:UITableViewCellStyleDefault reuseIdentifier:reuseIdentifier];
    if (self) {
        self.textLabel.textAlignment = NSTextAlignmentCenter;
        self.textLabel.layer.cornerRadius = CBWCornerRadiusMini;
        self.textLabel.clipsToBounds = YES;
    }
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    CGRect textLabelFrame = self.textLabel.frame;
    textLabelFrame.size.width = CGRectGetWidth(self.contentView.frame) - CGRectGetMinX(textLabelFrame) * 2.f;
    textLabelFrame.size.height = CGRectGetHeight(textLabelFrame);
    self.textLabel.frame = textLabelFrame;
    self.textLabel.textColor = [UIColor CBWWhiteColor];
    
    switch (self.buttonCellStyle) {
        case BlockButtonCellStylePrimary:
            self.textLabel.backgroundColor = [UIColor CBWPrimaryColor];
            break;
            
        case BlockButtonCellStyleDanger: {
            self.textLabel.backgroundColor = [UIColor CBWDangerColor];
            break;
        }
            
        case BlockButtonCellStyleSuccess: {
            self.textLabel.backgroundColor = [UIColor CBWSuccessColor];
        }
            
        default:
            self.textLabel.textColor = [UIColor CBWPrimaryColor];
            break;
    }
}

@end
