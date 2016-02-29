//
//  AddressHeaderView.m
//  wallet
//
//  Created by Zin on 16/2/28.
//  Copyright © 2016年 Bitmain. All rights reserved.
//

#import "AddressHeaderView.h"

#import "NSString+CBWAddress.h"

static const CGFloat kAddressHeaderViewVerticalPadding = 48.f;
static const CGFloat kAddressHeaderViewHorizontalPadding = CBWLayoutCommonHorizontalPadding;
static const CGFloat kAddressHeaderViewSubviewMargin = 16.f;
static const CGFloat kAddressHeaderViewAddressFontSize = 16.f;
static const CGFloat kAddressHeaderViewAddressHeight = 20.f;
static const CGFloat kAddressHeaderViewLabelFontSize = 16.f;
static const CGFloat kAddressHeaderViewLabelHeight = 20.f;

@interface AddressHeaderView()<UITextFieldDelegate>

@property (nonatomic, weak) UIImageView * _Nullable qrcodeImageView;
@property (nonatomic, weak) UILabel * _Nullable addressLabel;
@property (nonatomic, weak, readwrite) UITextField * _Nullable labelField;

@end

@implementation AddressHeaderView

#pragma mark - Property
- (void)setLabelEditable:(BOOL)labelEditable {
    _labelEditable = labelEditable;
    self.labelField.userInteractionEnabled = labelEditable;
}

- (NSString *)label {
    return self.labelField.text;
}

- (UIImageView *)qrcodeImageView {
    if (!_qrcodeImageView) {
        UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake((ScreenWidth - HDImagePortraitHeight) / 2.f, kAddressHeaderViewVerticalPadding, HDImagePortraitHeight, HDImagePortraitHeight)];
        [self addSubview:imageView];
        _qrcodeImageView = imageView;
    }
    return _qrcodeImageView;
}

- (UILabel *)addressLabel {
    if (!_addressLabel) {
        UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(kAddressHeaderViewHorizontalPadding, kAddressHeaderViewVerticalPadding + HDImagePortraitHeight + kAddressHeaderViewSubviewMargin, ScreenWidth - kAddressHeaderViewHorizontalPadding * 2.f, kAddressHeaderViewAddressHeight)];
        label.font = [UIFont fontWithName:@"Courier" size:kAddressHeaderViewAddressFontSize];
        label.textAlignment = NSTextAlignmentCenter;
        [self addSubview:label];
        _addressLabel = label;
    }
    return _addressLabel;
}

- (UITextField *)labelField {
    if (!_labelField) {
        CGRect fieldFrame = CGRectOffset(self.addressLabel.frame, 0, kAddressHeaderViewAddressHeight + kAddressHeaderViewSubviewMargin);
        fieldFrame.size.height = kAddressHeaderViewLabelHeight;
        UITextField *field = [[UITextField alloc] initWithFrame:fieldFrame];
        field.textAlignment = NSTextAlignmentCenter;
        field.font = [UIFont systemFontOfSize:kAddressHeaderViewLabelFontSize];
        field.returnKeyType = UIReturnKeyDone;
        field.userInteractionEnabled = NO;
        field.delegate = self;
        [self addSubview:field];
        _labelField = field;
    }
    return _labelField;
}

#pragma mark - Initialization

- (instancetype)initWithFrame:(CGRect)frame {
    CGFloat height = kAddressHeaderViewVerticalPadding + HDImagePortraitHeight + kAddressHeaderViewSubviewMargin + kAddressHeaderViewAddressHeight + kAddressHeaderViewSubviewMargin + kAddressHeaderViewLabelHeight + kAddressHeaderViewVerticalPadding;
    self = [super initWithFrame:CGRectMake(0, 0, ScreenWidth, height)];
    return self;
}

- (void)setAddress:(NSString *)address withLabel:(NSString *)label {
    [self.qrcodeImageView setImage:[address qrcodeImageWithSize:self.qrcodeImageView.frame.size]];
    self.addressLabel.attributedText = [address attributedAddressWithAlignment:NSTextAlignmentCenter];
    self.labelField.text = label;
}

#pragma mark - UITextFieldDelegate
- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [textField resignFirstResponder];
    if ([self.delegate respondsToSelector:@selector(addressHeaderViewDidEndEditing:)]) {
        [self.delegate addressHeaderViewDidEndEditing:self];
    }
    return YES;
}

@end
