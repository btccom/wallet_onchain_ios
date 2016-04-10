//
//  AddressCell.m
//  wallet
//
//  Created by Zin (noteon.com) on 16/2/27.
//  Copyright © 2016年 Bitmain. All rights reserved.
//
// TODO: Automatic vertical middle layout

#import "AddressCell.h"

#import "CBWAddress.h"

#import "NSString+CBWAddress.h"

static const CGFloat kAddressCellLabelLabelHeight = 20.f;
static const CGFloat kAddressCellAddressLabelHeight = 20.f;
static const CGFloat kAddressCellTxsLabelHeight = 16.f;
static const CGFloat kAddressCellBalanceLabelHeight = 16.f;

@interface AddressCell ()

@property (nonatomic, weak, readwrite) UILabel * _Nullable labelLabel;
@property (nonatomic, weak, readwrite) UILabel * _Nullable addressLabel;
@property (nonatomic, weak, readwrite) UILabel * _Nullable txsLabel;
@property (nonatomic, weak, readwrite) UILabel * _Nullable balanceLabel;

@end

@implementation AddressCell

#pragma mark - Property
- (UILabel *)labelLabel {
    if (!_labelLabel) {
        UILabel *label = [[UILabel alloc] init];
        label.font = [UIFont systemFontOfSize:UIFont.labelFontSize weight:UIFontWeightMedium];
        [self.contentView addSubview:label];
        _labelLabel = label;
    }
    return _labelLabel;
}
- (UILabel *)addressLabel {
    if (!_addressLabel) {
        UILabel *label = [[UILabel alloc] init];
        label.font = [UIFont monospacedFontOfSize:UIFont.labelFontSize];
        label.textColor = [UIColor CBWSubTextColor];
        [self.contentView addSubview:label];
        _addressLabel = label;
    }
    return _addressLabel;
}
- (UILabel *)txsLabel {
    if (!_txsLabel) {
        UILabel *label = [[UILabel alloc] init];
        label.font = [UIFont systemFontOfSize:UIFont.smallSystemFontSize weight:UIFontWeightMedium];
        label.textColor = [UIColor CBWSubTextColor];
        [self.contentView addSubview:label];
        _txsLabel = label;
    }
    return _txsLabel;
}
- (UILabel *)balanceLabel {
    if (!_balanceLabel) {
        UILabel *label = [[UILabel alloc] init];
        label.font = [UIFont systemFontOfSize:UIFont.smallSystemFontSize weight:UIFontWeightMedium];
        label.textAlignment = NSTextAlignmentRight;
        label.textColor = [UIColor CBWSubTextColor];
        [self.contentView addSubview:label];
        _balanceLabel = label;
    }
    return _balanceLabel;
}

#pragma mark - Public Method
- (void)setAddress:(CBWAddress *)address {
    if (!address) {
        return;
    }
    if (address.label) {
        self.labelLabel.text = address.label;
    }
    self.addressLabel.text = address.address;
    if (!self.isMetadataHidden) {
        self.txsLabel.text = [NSString stringWithFormat:@"%lu Txs", (unsigned long)address.txCount];
        self.balanceLabel.text = [@(address.balance) satoshiBTCString];
    }
}

#pragma mark - Override
- (void)layoutSubviews {
    [super layoutSubviews];
    
    CGFloat labelAreaLeft = CBWLayoutCommonHorizontalPadding;
    CGFloat labelAreaWidth = CGRectGetWidth(self.contentView.bounds) - labelAreaLeft * 2.f;
    
    // label
    CGFloat labelWidth = [self.labelLabel.text sizeWithFont:self.labelLabel.font maxSize:CGSizeMake(labelAreaWidth, kAddressCellLabelLabelHeight)].width;
    CGRect labelFrame = CGRectMake(labelAreaLeft, CBWLayoutCommonVerticalPadding, labelWidth, kAddressCellLabelLabelHeight);
    self.labelLabel.frame = labelFrame;
    self.labelLabel.center = CGPointMake(CGRectGetMidX(labelFrame), CGRectGetMidY(self.contentView.bounds));// certical center
    
    // address
    CGFloat addressLeft = labelAreaLeft;
    CGFloat addressWidth = labelAreaWidth;
    if (labelWidth > 0) {
        CGFloat addressOffsetLeft = labelWidth + CBWLayoutInnerSpace;
        addressLeft += addressOffsetLeft;
        addressWidth -= addressOffsetLeft;
    }
    CGRect addressFrame = CGRectMake(addressLeft, CBWLayoutCommonVerticalPadding, addressWidth, kAddressCellAddressLabelHeight);
    self.addressLabel.frame = addressFrame;
    self.addressLabel.center = CGPointMake(CGRectGetMidX(addressFrame), CGRectGetMidY(self.contentView.bounds));
    self.addressLabel.attributedText = [self.addressLabel.text attributedAddressWithAlignment:(labelWidth > 0 ? NSTextAlignmentRight : NSTextAlignmentLeft)];
    self.addressLabel.textColor = labelWidth > 0 ? [UIColor CBWSubTextColor] : [UIColor CBWTextColor];
    
    if (!self.isMetadataHidden) {
        // layout txs and balance labels
        // txs
        CGFloat txsWidth = (labelAreaWidth - CBWLayoutInnerSpace) / 2.f;
        CGFloat txsTop = CGRectGetHeight(self.contentView.frame) - CBWLayoutCommonVerticalPadding - kAddressCellTxsLabelHeight;
        CGRect txsFrame = CGRectMake(labelAreaLeft, txsTop, txsWidth, kAddressCellTxsLabelHeight);
        self.txsLabel.frame = txsFrame;
        
        // balance
        self.balanceLabel.frame = CGRectMake(CGRectGetMaxX(txsFrame) + CBWLayoutInnerSpace, txsTop, txsWidth, kAddressCellBalanceLabelHeight);
        
        // move up label and address labels
        self.labelLabel.frame = labelFrame;
        self.addressLabel.frame = addressFrame;
    }
}

@end
