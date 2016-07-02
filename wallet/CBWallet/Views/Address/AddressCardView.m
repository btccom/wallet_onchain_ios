//
//  AddressCardView.m
//  CBWallet
//
//  Created by Zin on 16/7/1.
//  Copyright © 2016年 Bitmain. All rights reserved.
//

#import "AddressCardView.h"

@interface AddressCardView ()

@property (nonatomic, weak, readwrite) UITextField *addressLabelField;
@property (nonatomic, weak, readwrite) UILabel *addressLabel;
@property (nonatomic, weak, readwrite) UIButton *qrcodeButton;
@property (nonatomic, weak, readwrite) UILabel *balanceLabel;
@property (nonatomic, weak, readwrite) UILabel *receivedLabel;
@property (nonatomic, weak, readwrite) UILabel *txLabel;

@property (nonatomic, weak) UIView *statView;
@property (nonatomic, weak) UILabel *statBalanceLabel;
@property (nonatomic, weak) UILabel *statReceivedLabel;
@property (nonatomic, weak) UILabel *statTXLabel;

@property (nonatomic, weak) UIView *backgroundView;

@end

@implementation AddressCardView

- (UITextField *)addressLabelField {
    if (!_addressLabelField) {
        CGFloat areaHeight = CGRectGetHeight(self.bounds) - 64;
        UITextField *field = [[UITextField alloc] initWithFrame:CGRectMake(CBWLayoutCommonPadding, areaHeight * 0.618 - 44, CGRectGetWidth(self.bounds) - CBWLayoutCommonPadding * 2, 44)];
        field.placeholder = NSLocalizedStringFromTable(@"Placeholder add_label_for_address", @"CBW", nil);
        field.font = [UIFont systemFontOfSize:32];
        field.textColor = [UIColor CBWWhiteColor];
        [self addSubview:field];
        _addressLabelField = field;
    }
    return _addressLabelField;
}

- (UILabel *)addressLabel {
    if (!_addressLabel) {
        UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(CGRectGetMinX(self.addressLabelField.frame), CGRectGetMaxY(self.addressLabelField.frame), CGRectGetWidth(self.addressLabelField.frame), 18)];
        label.font = [UIFont monospacedFontOfSize:14];
        label.textColor = [UIColor CBWWhiteColor];
        [self addSubview:label];
        _addressLabel = label;
    }
    return _addressLabel;
}

- (UIView *)statView {
    if (!_statView) {
        UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, CGRectGetHeight(self.bounds) - 64, CGRectGetWidth(self.bounds), 64)];
        view.backgroundColor = [[UIColor CBWBlackColor] colorWithAlphaComponent:.1];
        [self addSubview:view];
        _statView = view;
    }
    return _statView;
}

- (UILabel *)statBalanceLabel {
    if (!_statBalanceLabel) {
        UILabel *label = [[UILabel alloc] init];
        label.font = [UIFont systemFontOfSize:11];
        label.textColor = [UIColor CBWWhiteColor];
        label.text = NSLocalizedStringFromTable(@"Balance", @"CBW", nil).uppercaseString;
        [self.statView addSubview:label];
        _statBalanceLabel = label;
    }
    return _statBalanceLabel;
}

- (UILabel *)statReceivedLabel {
    if (!_statReceivedLabel) {
        UILabel *label = [[UILabel alloc] init];
        label.font = [UIFont systemFontOfSize:11];
        label.textColor = [UIColor CBWWhiteColor];
        label.text = NSLocalizedStringFromTable(@"Received", @"CBW", nil).uppercaseString;
        [self.statView addSubview:label];
        _statReceivedLabel = label;
    }
    return _statReceivedLabel;
}

- (UILabel *)statTXLabel {
    if (!_statTXLabel) {
        UILabel *label = [[UILabel alloc] init];
        label.font = [UIFont systemFontOfSize:11];
        label.textColor = [UIColor CBWWhiteColor];
        label.textAlignment = NSTextAlignmentRight;
        label.text = NSLocalizedStringFromTable(@"TX", @"CBW", nil).uppercaseString;
        [self.statView addSubview:label];
        _statTXLabel = label;
    }
    return _statTXLabel;
}

- (UILabel *)balanceLabel {
    if (!_balanceLabel) {
        UILabel *label = [[UILabel alloc] init];
        label.font = [UIFont systemFontOfSize:16];
        label.textColor = [UIColor CBWWhiteColor];
        [self.statView addSubview:label];
        _balanceLabel = label;
    }
    return _balanceLabel;
}

- (UILabel *)receivedLabel {
    if (!_receivedLabel) {
        UILabel *label = [[UILabel alloc] init];
        label.font = [UIFont systemFontOfSize:16];
        label.textColor = [UIColor CBWWhiteColor];
        [self.statView addSubview:label];
        _receivedLabel = label;
    }
    return _receivedLabel;
}

- (UILabel *)txLabel {
    if (!_txLabel) {
        UILabel *label = [[UILabel alloc] init];
        label.font = [UIFont systemFontOfSize:16];
        label.textColor = [UIColor CBWWhiteColor];
        label.textAlignment = NSTextAlignmentRight;
        [self.statView addSubview:label];
        _txLabel = label;
    }
    return _txLabel;
}

- (UIButton *)qrcodeButton {
    if (!_qrcodeButton) {
        UIButton *button = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 56, 56)];
        [button setImage:[UIImage imageNamed:@"icon_qrcode"] forState:UIControlStateNormal];
        [self addSubview:button];
        _qrcodeButton = button;
    }
    return _qrcodeButton;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    CGSize maxSize = CGSizeMake(floor((CGRectGetWidth(self.statView.frame) - CBWLayoutCommonPadding * 2) / 3), 64);
    
    CGFloat txWidth = MAX([self.statTXLabel.text sizeWithFont:self.statTXLabel.font maxSize:maxSize].width, [self.txLabel.text sizeWithFont:self.txLabel.font maxSize:maxSize].width);
    
    CGFloat otherWidth = floor(CGRectGetWidth(self.statView.frame) - CBWLayoutCommonPadding * 2 - txWidth - 8 * 2) / 2;
    
    CGRect balanceLabelFrame = CGRectMake(CBWLayoutCommonPadding, 10, otherWidth, 16);
    self.statBalanceLabel.frame = balanceLabelFrame;
    self.statReceivedLabel.frame = CGRectOffset(self.statBalanceLabel.frame, otherWidth + 8, 0);
    
    CGRect txLabelFrame = CGRectMake(CGRectGetWidth(self.statView.frame) - CBWLayoutCommonPadding - txWidth, 10, txWidth, 16);
    self.statTXLabel.frame = txLabelFrame;
    
    CGRect balanceFrame = CGRectOffset(balanceLabelFrame, 0, CGRectGetHeight(balanceLabelFrame));
    balanceFrame.size.height = 22;
    self.balanceLabel.frame = balanceFrame;
    self.receivedLabel.frame = CGRectOffset(balanceFrame, otherWidth + 8, 0);
    
    CGRect txFrame = CGRectOffset(txLabelFrame, 0, CGRectGetHeight(txLabelFrame));
    txFrame.size.height = 22;
    self.txLabel.frame = txFrame;
    
    self.qrcodeButton.center = CGPointMake(CGRectGetWidth(self.frame) - CGRectGetWidth(self.qrcodeButton.frame) / 2.0, CGRectGetMidY(self.addressLabel.frame));
    
    if (!_backgroundView) {
        UIImageView *backgroundImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT)];
        [backgroundImageView setImage:[UIImage imageNamed:@"background"]];
        [self insertSubview:backgroundImageView atIndex:0];
        self.clipsToBounds = YES;
        _backgroundView = backgroundImageView;
    }
}

@end
