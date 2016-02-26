//
//  TransactionCell.m
//  wallet
//
//  Created by Zin on 16/2/26.
//  Copyright © 2016年 Bitmain. All rights reserved.
//

#import "TransactionCell.h"

#import "Transaction.h"

static const CGFloat kTransactionCellValueLabelFontSize = 16.f;
static const CGFloat kTransactionCellValueLabelHeight = 20.f;
static const CGFloat kTransactionCellConfirmedLabelFontSize = 10.f;
static const CGFloat kTransactionCellConfirmedLabelHeight = 16.f;
static const CGFloat kTransactionCellAddressLabelFontSize = 14.f;
static const CGFloat kTransactionCellAddressLabelHeight = 16.f;

static const CGFloat kTransactionCellVerticalPadding = BTCCLayoutCommonPadding;
static const CGFloat kTransactionCellHorizontalPadding = BTCCLayoutCommonPadding;

@interface TransactionCell ()

@property (nonatomic, weak, readwrite, nullable) UIImageView *iconView;
@property (nonatomic, weak, readwrite, nullable) UILabel *addressLabel;
@property (nonatomic, weak, readwrite, nullable) UILabel *confirmedLabel;
@property (nonatomic, weak, readwrite, nullable) UILabel *valueLabel;

@property (nonatomic, strong, readonly, nonnull) UIColor *increasingColor;
@property (nonatomic, strong, readonly, nonnull) UIColor *decreasingColor;

@end

@implementation TransactionCell

#pragma mark - Property
- (UIColor *)increasingColor {
    return [UIColor BTCCGreenColor];
}
- (UIColor *)decreasingColor {
    return [UIColor BTCCRedColor];
}

- (void)setTransaction:(Transaction *)transaction {
    if ([_transaction isEqual:transaction]) {
        return;
    }
    
    _transaction = transaction;
    NSLog(@"transaction cell data: %@", transaction);
    
    if (transaction.type == TransactionTypeSend) {
        self.iconView.tintColor = self.decreasingColor;
        [self.iconView setImage:[[UIImage imageNamed:@"icon_send_mini"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate]];
    } else {
        self.iconView.tintColor = self.increasingColor;
        [self.iconView setImage:[[UIImage imageNamed:@"icon_receive_mini"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate]];
    }
    self.valueLabel.text = [NSString stringWithFormat:@"%.8lf", ABS(transaction.value) / 100000000.0];
    self.valueLabel.textColor = self.iconView.tintColor;
    if (transaction.confirmed > 0) {
        self.confirmedLabel.text = [NSString stringWithFormat:NSLocalizedStringFromTable(@"%d Confirmed", @"BTCC", @"Confirmed"), transaction.confirmed];
        self.confirmedLabel.textColor = [UIColor BTCCBlackColor];
        self.confirmedLabel.backgroundColor = [UIColor BTCCExtraLightGrayColor];
    } else {
        self.confirmedLabel.text = NSLocalizedStringFromTable(@"Unconfirmed", @"BTCC", @"Unconfirmed");
        self.confirmedLabel.textColor = [UIColor BTCCWhiteColor];
        self.confirmedLabel.backgroundColor = [UIColor BTCCGrayColor];
    }
    self.addressLabel.text = transaction.relatedAddress;
}

- (UIImageView *)iconView {
    if (!_iconView) {
        UIImageView *imageView = [[UIImageView alloc] init];
        [self.contentView addSubview:imageView];
        _iconView = imageView;
    }
    return _iconView;
}

- (UILabel *)addressLabel {
    if (!_addressLabel) {
        UILabel *label = [[UILabel alloc] init];
        label.font = [UIFont fontWithName:@"Courier" size:kTransactionCellAddressLabelFontSize];
        label.textAlignment = NSTextAlignmentRight;
        [self.contentView addSubview:label];
        _addressLabel = label;
    }
    return _addressLabel;
}

- (UILabel *)confirmedLabel {
    if (!_confirmedLabel) {
        UILabel *label = [[UILabel alloc] init];
        label.font = [UIFont systemFontOfSize:kTransactionCellConfirmedLabelFontSize];
        label.textAlignment = NSTextAlignmentCenter;
        label.layer.cornerRadius = BTCCLayoutInnerSpace / 2.f;
        label.layer.masksToBounds = YES;
        [self.contentView addSubview:label];
        _confirmedLabel = label;
    }
    return _confirmedLabel;
}

- (UILabel *)valueLabel {
    if (!_valueLabel) {
        UILabel *label = [[UILabel alloc] init];
        label.font = [UIFont systemFontOfSize:kTransactionCellValueLabelFontSize weight:UIFontWeightMedium];
        [self.contentView addSubview:label];
        _valueLabel = label;
    }
    return _valueLabel;
}

#pragma mark - Initialization

- (void)layoutSubviews {
    [super layoutSubviews];

    
    CGRect iconFrame = self.iconView.frame;
    iconFrame.size = self.iconView.image.size;
    iconFrame.origin.x = kTransactionCellHorizontalPadding;
    iconFrame.origin.y = kTransactionCellVerticalPadding;
    self.iconView.frame = iconFrame;
    
    CGFloat valueLeft = CGRectGetMaxX(iconFrame) + BTCCLayoutInnerSpace;
    CGFloat valueWidth = CGRectGetWidth(self.contentView.frame) - valueLeft - kTransactionCellHorizontalPadding;
    CGRect valueFrame = CGRectMake(valueLeft, 0, valueWidth, kTransactionCellAddressLabelHeight);
    self.valueLabel.frame = valueFrame;
    self.valueLabel.center = CGPointMake(CGRectGetMidX(valueFrame), CGRectGetMidY(iconFrame));
    
    CGFloat subLabelLeftRightPadding = BTCCLayoutInnerSpace;
    
    CGFloat confirmedTop = CGRectGetHeight(self.contentView.frame) - kTransactionCellVerticalPadding - kTransactionCellConfirmedLabelHeight;
    CGFloat confirmedWidth = [self.confirmedLabel.text sizeWithFont:self.confirmedLabel.font maxSize:CGSizeMake(valueWidth / 2.f - kTransactionCellHorizontalPadding - subLabelLeftRightPadding, kTransactionCellConfirmedLabelHeight)].width + subLabelLeftRightPadding;
    CGRect confirmedFrame = CGRectMake(valueLeft, confirmedTop, confirmedWidth, kTransactionCellConfirmedLabelHeight);
    self.confirmedLabel.frame = confirmedFrame;
    
    CGFloat addressWidth = CGRectGetWidth(valueFrame) - confirmedWidth - kTransactionCellHorizontalPadding;
    CGRect addressFrame = CGRectMake(CGRectGetMaxX(valueFrame) - addressWidth, 0, addressWidth, kTransactionCellValueLabelHeight);
    self.addressLabel.frame = addressFrame;
    self.addressLabel.center = CGPointMake(CGRectGetMidX(addressFrame), CGRectGetMidY(confirmedFrame));
    NSMutableAttributedString *attributedString = [[NSMutableAttributedString alloc] initWithString:self.addressLabel.text];
    NSMutableParagraphStyle *paragraph = [[NSMutableParagraphStyle alloc] init];
    paragraph.alignment = NSTextAlignmentRight;
    paragraph.lineBreakMode = NSLineBreakByTruncatingMiddle;
    [attributedString addAttribute:NSParagraphStyleAttributeName value:paragraph range:NSMakeRange(0, [attributedString length])];
    self.addressLabel.attributedText = attributedString;

    
    UIEdgeInsets inset = self.separatorInset;
    inset.left = CGRectGetMinX(self.valueLabel.frame);
    self.separatorInset = inset;
}

@end
