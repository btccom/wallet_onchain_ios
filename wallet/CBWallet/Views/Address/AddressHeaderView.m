//
//  AddressHeaderView.m
//  wallet
//
//  Created by Zin on 16/2/28.
//  Copyright © 2016年 Bitmain. All rights reserved.
//

#import "AddressHeaderView.h"
#import "ResponderLabel.h"

#import "NSString+CBWAddress.h"

static const CGFloat kAddressHeaderViewVerticalPadding = 48.f;
static const CGFloat kAddressHeaderViewSubviewMargin = 16.f;
static const CGFloat kAddressHeaderViewAddressHeight = 20.f;
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
    self.labelField.placeholder = labelEditable ? NSLocalizedStringFromTable(@"Placeholder add_label_for_address", @"CBW", nil) : nil;
}

- (NSString *)label {
    return self.labelField.text;
}

- (UIImageView *)qrcodeImageView {
    if (!_qrcodeImageView) {
        UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake((SCREEN_WIDTH - HD_IMAGE_PORTRAIT_HEIGHT) / 2.f, kAddressHeaderViewVerticalPadding, HD_IMAGE_PORTRAIT_HEIGHT, HD_IMAGE_PORTRAIT_HEIGHT)];
        [self addSubview:imageView];
        _qrcodeImageView = imageView;
    }
    return _qrcodeImageView;
}

- (UILabel *)addressLabel {
    if (!_addressLabel) {
        ResponderLabel *label = [[ResponderLabel alloc] initWithFrame:CGRectMake(CBWLayoutCommonPadding, kAddressHeaderViewVerticalPadding + HD_IMAGE_PORTRAIT_HEIGHT + kAddressHeaderViewSubviewMargin, SCREEN_WIDTH - CBWLayoutCommonPadding * 2.f, kAddressHeaderViewAddressHeight)];
        label.font = [UIFont fontWithName:@"Courier" size:UIFont.labelFontSize];
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
        field.font = [UIFont systemFontOfSize:UIFont.labelFontSize];
        field.returnKeyType = UIReturnKeyDone;
        field.userInteractionEnabled = NO;
        field.delegate = self;
        [field addTarget:self action:@selector(p_editingChanged:) forControlEvents:UIControlEventEditingChanged];
        [self addSubview:field];
        _labelField = field;
    }
    return _labelField;
}

#pragma mark - Initialization

- (instancetype)initWithFrame:(CGRect)frame {
    CGFloat height = kAddressHeaderViewVerticalPadding + HD_IMAGE_PORTRAIT_HEIGHT + kAddressHeaderViewSubviewMargin + kAddressHeaderViewAddressHeight + kAddressHeaderViewSubviewMargin + kAddressHeaderViewLabelHeight + kAddressHeaderViewVerticalPadding;
    self = [super initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, height)];
    return self;
}

- (void)setAddress:(NSString *)address withLabel:(NSString *)label {
    [self.qrcodeImageView setImage:[address qrcodeImageWithSize:self.qrcodeImageView.frame.size]];
    self.addressLabel.attributedText = [address attributedAddressWithAlignment:NSTextAlignmentCenter];
    self.labelField.text = label;
}

#pragma mark - UITextFieldDelegate
- (void)textFieldDidEndEditing:(UITextField *)textField {
    if ([self.delegate respondsToSelector:@selector(addressHeaderViewDidEndEditing:)]) {
        [self.delegate addressHeaderViewDidEndEditing:self];
    }
}
- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [textField resignFirstResponder];
//    if ([self.delegate respondsToSelector:@selector(addressHeaderViewDidEndEditing:)]) {
//        [self.delegate addressHeaderViewDidEndEditing:self];
//    }
    return YES;
}
- (void)p_editingChanged:(UITextField *)textField {
    if ([self.delegate respondsToSelector:@selector(addressHeaderViewDidEditingChanged:)]) {
        [self.delegate addressHeaderViewDidEditingChanged:self];
    }
}

@end
