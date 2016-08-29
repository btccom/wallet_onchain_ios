//
//  BlockButtonCell.m
//  wallet
//
//  Created by Zin (noteon.com) on 16/2/29.
//  Copyright © 2016年 Bitmain. All rights reserved.
//

#import "FormControlBlockButtonCell.h"

@interface FormControlBlockButtonCell ()

@property (nonatomic, weak) UIActivityIndicatorView *indicator;

@end

@implementation FormControlBlockButtonCell

- (UIActivityIndicatorView *)indicator {
    if (!_indicator) {
        UIActivityIndicatorView *indicatorView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
        [self.contentView addSubview:indicatorView];
        _indicator = indicatorView;
    }
    return _indicator;
}

- (void)setEnabled:(BOOL)enabled {
    _enabled = enabled;
    self.textLabel.alpha = enabled ? 1.f : CBWDisabledOpacity;
    self.userInteractionEnabled = enabled;
}

- (void)setButtonCellStyle:(BlockButtonCellStyle)buttonCellStyle {
    if (buttonCellStyle == _buttonCellStyle) {
        return;
    }
    _buttonCellStyle = buttonCellStyle;
    switch (buttonCellStyle) {
        case BlockButtonCellStyleProcess: {
            if (1 == self.textLabel.alpha) {
                [UIView animateWithDuration:CBWAnimateDuration animations:^{
                    self.textLabel.alpha = 0;
                }];
            }
            [self.contentView bringSubviewToFront:self.indicator];
            [self.indicator startAnimating];
            break;
        }
        default: {
            if (!_indicator) {
                [self.indicator stopAnimating];
                [self.indicator removeFromSuperview];
            }
            if (0 == self.textLabel.alpha) {
                [UIView animateWithDuration:CBWAnimateDuration animations:^{
                    self.textLabel.alpha = 1;
                }];
            }
            break;
        }
    }
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
            break;
        }
            
        case BlockButtonCellStyleProcess: {
            self.textLabel.backgroundColor = [UIColor clearColor];
            self.indicator.center = self.textLabel.center;
            break;
        }
            
        default:
            self.textLabel.textColor = [UIColor CBWPrimaryColor];
            self.textLabel.backgroundColor = [UIColor clearColor];
            break;
    }
}

@end
