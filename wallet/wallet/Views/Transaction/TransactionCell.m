//
//  TransactionCell.m
//  wallet
//
//  Created by Zin on 16/2/26.
//  Copyright © 2016年 Bitmain. All rights reserved.
//

#import "TransactionCell.h"

#import "Transaction.h"

#import "NSString+BTCCAddress.h"

static const CGFloat kTransactionCellDateLabelFontSize = 10.f;
static const CGFloat kTransactionCellDateLabelHeight = 16.f;
static const CGFloat kTransactionCellValueLabelFontSize = 16.f;
static const CGFloat kTransactionCellValueLabelHeight = 20.f;
static const CGFloat kTransactionCellConfirmedLabelFontSize = 10.f;
static const CGFloat kTransactionCellConfirmedLabelHeight = 16.f;
static const CGFloat kTransactionCellAddressLabelFontSize = 14.f;
static const CGFloat kTransactionCellAddressLabelHeight = 16.f;

static const CGFloat kTransactionCellVerticalPadding = BTCCLayoutCommonPadding;
static const CGFloat kTransactionCellHorizontalPadding = BTCCLayoutCommonPadding;

@interface TransactionCell ()

@property (nonatomic, weak, readwrite) UIImageView * _Nullable iconView;
@property (nonatomic, weak, readwrite) UILabel * _Nullable dateLabel;
@property (nonatomic, weak, readwrite) UILabel * _Nullable addressLabel;
@property (nonatomic, weak, readwrite) UILabel * _Nullable confirmedLabel;
@property (nonatomic, weak, readwrite) UILabel * _Nullable valueLabel;

@property (nonatomic, strong, readonly) UIColor * _Nonnull increasingColor;
@property (nonatomic, strong, readonly) UIColor * _Nonnull decreasingColor;

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
    
    if (transaction.type == TransactionTypeSend) {
        self.iconView.tintColor = self.decreasingColor;
        [self.iconView setImage:[[UIImage imageNamed:@"icon_send_mini"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate]];
    } else {
        self.iconView.tintColor = self.increasingColor;
        [self.iconView setImage:[[UIImage imageNamed:@"icon_receive_mini"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate]];
    }
    self.dateLabel.text = @"12:00";
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
        label.font = [UIFont systemFontOfSize:kTransactionCellValueLabelFontSize];
        [self.contentView addSubview:label];
        _valueLabel = label;
    }
    return _valueLabel;
}

- (UILabel *)dateLabel {
    if (!_dateLabel) {
        UILabel *label = [[UILabel alloc] init];
        label.font = [UIFont systemFontOfSize:kTransactionCellDateLabelFontSize];
        label.textColor = [UIColor BTCCMutedTextColor];
        [self.contentView addSubview:label];
        _dateLabel = label;
    }
    return _dateLabel;
}

#pragma mark - Initialization

- (void)layoutSubviews {
    [super layoutSubviews];

    // icon
    CGRect iconFrame = self.iconView.frame;
    iconFrame.size = self.iconView.image.size;
    iconFrame.origin.x = kTransactionCellHorizontalPadding;
    iconFrame.origin.y = kTransactionCellVerticalPadding;
    self.iconView.frame = iconFrame;
    
    // label area
    CGFloat labelAreaLeft = CGRectGetMaxX(iconFrame) + BTCCLayoutInnerSpace;
    CGFloat labelAreaWidth = CGRectGetWidth(self.contentView.frame) - labelAreaLeft - kTransactionCellHorizontalPadding;
    
    // date
    CGFloat dateWidth = [self.dateLabel.text sizeWithFont:self.dateLabel.font maxSize:CGSizeMake(labelAreaWidth / 2.f - kTransactionCellHorizontalPadding, kTransactionCellDateLabelHeight)].width;
    CGFloat dateLeft = labelAreaLeft + labelAreaWidth - dateWidth;
    CGRect dateFrame = CGRectMake(dateLeft, 0, dateWidth, kTransactionCellDateLabelHeight);
    self.dateLabel.frame = dateFrame;
    self.dateLabel.center = CGPointMake(CGRectGetMidX(dateFrame), CGRectGetMidY(iconFrame));
    
    // value
    CGFloat valueWidth = labelAreaWidth - dateWidth - kTransactionCellHorizontalPadding; // - date with - 间隔
    CGRect valueFrame = CGRectMake(labelAreaLeft, 0, valueWidth, kTransactionCellAddressLabelHeight);
    self.valueLabel.frame = valueFrame;
    self.valueLabel.center = CGPointMake(CGRectGetMidX(valueFrame), CGRectGetMidY(iconFrame));
    
    CGFloat subLabelLeftRightPadding = BTCCLayoutInnerSpace;
    
    // confirm
    CGFloat confirmedTop = CGRectGetHeight(self.contentView.frame) - kTransactionCellVerticalPadding - kTransactionCellConfirmedLabelHeight;
    CGFloat confirmedWidth = [self.confirmedLabel.text sizeWithFont:self.confirmedLabel.font maxSize:CGSizeMake(labelAreaWidth / 2.f - kTransactionCellHorizontalPadding - subLabelLeftRightPadding, kTransactionCellConfirmedLabelHeight)].width + subLabelLeftRightPadding; // subLabelLeftRightPadding: 预留内部填充
    CGRect confirmedFrame = CGRectMake(labelAreaLeft, confirmedTop, confirmedWidth, kTransactionCellConfirmedLabelHeight);
    self.confirmedLabel.frame = confirmedFrame;
    
    // address
    CGFloat addressWidth = labelAreaWidth - confirmedWidth - kTransactionCellHorizontalPadding;
    CGRect addressFrame = CGRectMake(CGRectGetMaxX(confirmedFrame) + kTransactionCellHorizontalPadding, 0, addressWidth, kTransactionCellValueLabelHeight);
    self.addressLabel.frame = addressFrame;
    self.addressLabel.center = CGPointMake(CGRectGetMidX(addressFrame), CGRectGetMidY(confirmedFrame));
    self.addressLabel.attributedText = [self.addressLabel.text attributedAddressWithAlignment:NSTextAlignmentRight];

    // separator
    UIEdgeInsets inset = self.separatorInset;
    inset.left = CGRectGetMinX(self.valueLabel.frame);
    self.separatorInset = inset;
}

@end
