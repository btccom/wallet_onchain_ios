//
//  InputTableViewCell.m
//  CBWallet
//
//  Created by Zin (noteon.com) on 16/3/21.
//  Copyright © 2016年 Bitmain. All rights reserved.
//

#import "FormControlInputCell.h"

@interface FormControlInputCell ()

@property (nonatomic, weak, readwrite) UITextField *textField;

@end

@implementation FormControlInputCell

- (void)setInputType:(FormControlInputType)inputType {
    _inputType = inputType;
    
    self.textField.font = [UIFont systemFontOfSize:UIFont.labelFontSize];
    self.textField.keyboardType = UIKeyboardTypeDefault;
    switch (inputType) {
        case FormControlInputTypeBitcoinAddress: {
            self.textField.font = [UIFont monospacedFontOfSize:UIFont.labelFontSize];
            break;
        }
        case FormControlInputTypeBitcoinAmount: {
            self.textField.keyboardType = UIKeyboardTypeDecimalPad;
            break;
        }
            
        default:
            break;
    }
}

- (UITextField *)textField {
    if (_textField) {
        return _textField;
    }
    
    UITextField *textField = [[UITextField alloc] initWithFrame:self.contentView.bounds];
    [self.contentView addSubview:textField];
    _textField = textField;
    return _textField;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
    if (selected) {
        [self setSelected:NO animated:YES];
        [self.textField becomeFirstResponder];
    }
}

- (void)willMoveToSuperview:(UIView *)newSuperview {
    [super willMoveToSuperview:newSuperview];
    
    if (self.textLabel.text.length == 0) {
        self.textLabel.text = @" ";
    }
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    CGFloat left = CGRectGetMinX(self.textLabel.frame);
    CGFloat width = CGRectGetWidth(self.contentView.frame) - left - self.contentView.layoutMargins.left;
    CGRect textFieldFrame = CGRectMake(left, 0, width, CGRectGetHeight(self.contentView.frame));
    self.textField.frame = textFieldFrame;
    [self.contentView bringSubviewToFront:self.textField];
}

@end
