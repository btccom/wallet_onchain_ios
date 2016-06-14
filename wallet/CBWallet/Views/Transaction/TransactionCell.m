//
//  TransactionCell.m
//  wallet
//
//  Created by Zin (noteon.com) on 16/2/26.
//  Copyright © 2016年 Bitmain. All rights reserved.
//
// TODO: Automatic vertical middle layout

#import "TransactionCell.h"

#import "CBWTransaction.h"

#import "NSString+CBWAddress.h"
#import "NSDate+Helper.h"

static const CGFloat kTransactionCellDateLabelFontSize = 10.f;
static const CGFloat kTransactionCellDateLabelHeight = 16.f;
static const CGFloat kTransactionCellValueLabelHeight = 20.f;
static const CGFloat kTransactionCellConfirmedLabelFontSize = 10.f;
static const CGFloat kTransactionCellConfirmedLabelHeight = 16.f;
static const CGFloat kTransactionCellAddressLabelFontSize = 14.f;
static const CGFloat kTransactionCellAddressLabelHeight = 16.f;

static const CGFloat kTransactionCellVerticalPadding = CBWLayoutCommonVerticalPadding;

@interface TransactionCell ()

@property (nonatomic, weak, readwrite) UIImageView *iconView;
@property (nonatomic, weak, readwrite) UILabel *dateLabel;
@property (nonatomic, weak, readwrite) UILabel *addressLabel;
@property (nonatomic, weak, readwrite) UILabel *confirmationLabel;
@property (nonatomic, weak, readwrite) UILabel *valueLabel;

@property (nonatomic, strong, readonly) UIColor *increasingColor;
@property (nonatomic, strong, readonly) UIColor *decreasingColor;

@end

@implementation TransactionCell

#pragma mark - Property
- (UIColor *)increasingColor {
    return [UIColor CBWGreenColor];
}
- (UIColor *)decreasingColor {
    return [UIColor CBWRedColor];
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

- (UILabel *)confirmationLabel {
    if (!_confirmationLabel) {
        UILabel *label = [[UILabel alloc] init];
        label.font = [UIFont systemFontOfSize:kTransactionCellConfirmedLabelFontSize];
        label.textAlignment = NSTextAlignmentCenter;
        label.layer.cornerRadius = CBWLayoutInnerSpace / 2.f;
        label.layer.masksToBounds = YES;
        [self.contentView addSubview:label];
        _confirmationLabel = label;
    }
    return _confirmationLabel;
}

- (UILabel *)valueLabel {
    if (!_valueLabel) {
        UILabel *label = [[UILabel alloc] init];
        label.font = [UIFont systemFontOfSize:UIFont.labelFontSize weight:UIFontWeightMedium];
        [self.contentView addSubview:label];
        _valueLabel = label;
    }
    return _valueLabel;
}

- (UILabel *)dateLabel {
    if (!_dateLabel) {
        UILabel *label = [[UILabel alloc] init];
        label.font = [UIFont systemFontOfSize:kTransactionCellDateLabelFontSize];
        label.textColor = [UIColor CBWMutedTextColor];
        [self.contentView addSubview:label];
        _dateLabel = label;
    }
    return _dateLabel;
}

#pragma mark - Initialization

#pragma mark - Public Method

- (void)setTransaction:(CBWTransaction *)transaction {
    switch (transaction.type) {
        case TransactionTypeSend: {
            self.iconView.tintColor = self.decreasingColor;
            [self.iconView setImage:[[UIImage imageNamed:@"icon_send_mini"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate]];
            break;
        }
            
        case TransactionTypeReceive: {
            self.iconView.tintColor = self.increasingColor;
            [self.iconView setImage:[[UIImage imageNamed:@"icon_receive_mini"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate]];
            break;
        }
            
        case TransactionTypeInternal: {
            self.iconView.tintColor = [UIColor CBWPrimaryColor];
            [self.iconView setImage:[[UIImage imageNamed:@"icon_internal_mini"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate]];
            break;
        }
    }
    
    // TODO: today....
    self.dateLabel.text = [transaction.transactionTime stringWithFormat:@"yyyy-MM-dd HH:mm:ss"];
    self.valueLabel.text = transaction.type == TransactionTypeInternal ? [@(transaction.outputsValue) satoshiBTCString] : [@(ABS(transaction.value)) satoshiBTCString];
    self.valueLabel.textColor = self.iconView.tintColor;
    if (transaction.confirmations > 0) {
        self.confirmationLabel.textColor = [UIColor CBWBlackColor];
        self.confirmationLabel.backgroundColor = [UIColor CBWExtraLightGrayColor];
        if (transaction.confirmations == 1) {
            self.confirmationLabel.text = [NSString stringWithFormat:NSLocalizedStringFromTable(@"%d Confirmation", @"CBW", @"Confirmed"), transaction.confirmations];
        } else {
            self.confirmationLabel.text = [NSString stringWithFormat:NSLocalizedStringFromTable(@"%@ Confirmations", @"CBW", @"Confirmed"), [@(transaction.confirmations) groupingString]];
        }
//        if (transaction.confirmations > CBWMaxVisibleConfirmation) {
//            self.confirmationLabel.text = NSLocalizedStringFromTable(@"Confirmed", @"CBW", nil);
//        } else {
//            self.confirmationLabel.text = [NSString stringWithFormat:NSLocalizedStringFromTable(@"%d confirmations", @"CBW", @"Confirmed"), transaction.confirmations];
//        }
    } else {
        self.confirmationLabel.text = NSLocalizedStringFromTable(@"Unconfirmed Transaction!", @"CBW", @"Unconfirmed");
        self.confirmationLabel.textColor = [UIColor CBWWhiteColor];
        self.confirmationLabel.backgroundColor = [UIColor CBWDangerColor];
    }
    NSString *relatedAddress = [transaction.relatedAddresses firstObject];
    if (!relatedAddress) {
        relatedAddress = @"Coinbase";
    }
    self.addressLabel.text = relatedAddress;
}

#pragma mark - Override

- (void)layoutSubviews {
    [super layoutSubviews];

    CGFloat horizontalPadding = CBWLayoutCommonPadding;
    // icon
    CGRect iconFrame = self.iconView.frame;
    iconFrame.size = self.iconView.image.size;
    iconFrame.origin.x = horizontalPadding;
    iconFrame.origin.y = kTransactionCellVerticalPadding;
    self.iconView.frame = iconFrame;
    
    // label area
    CGFloat labelAreaLeft = CGRectGetMaxX(iconFrame) + CBWLayoutInnerSpace;
    CGFloat labelAreaWidth = CGRectGetWidth(self.contentView.frame) - labelAreaLeft - horizontalPadding;
    
    // date
    CGFloat dateWidth = [self.dateLabel.text sizeWithFont:self.dateLabel.font maxSize:CGSizeMake(labelAreaWidth / 2.f - horizontalPadding, kTransactionCellDateLabelHeight)].width;
    CGFloat dateLeft = labelAreaLeft + labelAreaWidth - dateWidth;
    CGRect dateFrame = CGRectMake(dateLeft, 0, dateWidth, kTransactionCellDateLabelHeight);
    self.dateLabel.frame = dateFrame;
    self.dateLabel.center = CGPointMake(CGRectGetMidX(dateFrame), CGRectGetMidY(iconFrame));
    
    // value
    CGFloat valueWidth = labelAreaWidth - dateWidth - horizontalPadding; // - date with - 间隔
    CGRect valueFrame = CGRectMake(labelAreaLeft, 0, valueWidth, kTransactionCellAddressLabelHeight);
    self.valueLabel.frame = valueFrame;
    self.valueLabel.center = CGPointMake(CGRectGetMidX(valueFrame), CGRectGetMidY(iconFrame));
    
    CGFloat subLabelLeftRightPadding = CBWLayoutInnerSpace;
    
    // confirm
    CGFloat confirmedTop = CGRectGetHeight(self.contentView.frame) - kTransactionCellVerticalPadding - kTransactionCellConfirmedLabelHeight;
    CGFloat confirmedWidth = [self.confirmationLabel.text sizeWithFont:self.confirmationLabel.font maxSize:CGSizeMake(labelAreaWidth / 2.f - horizontalPadding - subLabelLeftRightPadding, kTransactionCellConfirmedLabelHeight)].width + subLabelLeftRightPadding; // subLabelLeftRightPadding: 预留内部填充
    CGRect confirmedFrame = CGRectMake(labelAreaLeft, confirmedTop, confirmedWidth, kTransactionCellConfirmedLabelHeight);
    self.confirmationLabel.frame = confirmedFrame;
    
    // address
    CGFloat addressWidth = labelAreaWidth - confirmedWidth - horizontalPadding;
    CGRect addressFrame = CGRectMake(CGRectGetMaxX(confirmedFrame) + horizontalPadding, 0, addressWidth, kTransactionCellValueLabelHeight);
    self.addressLabel.frame = addressFrame;
    self.addressLabel.center = CGPointMake(CGRectGetMidX(addressFrame), CGRectGetMidY(confirmedFrame));
    self.addressLabel.attributedText = [self.addressLabel.text attributedAddressWithAlignment:NSTextAlignmentRight];

    // separator
    UIEdgeInsets inset = self.separatorInset;
    inset.left = CGRectGetMinX(self.valueLabel.frame);
    self.separatorInset = inset;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
    
    // Configure the view for the selected state
}

@end
