//
//  InputTableViewCell.m
//  CBWallet
//
//  Created by Zin on 16/3/21.
//  Copyright © 2016年 Bitmain. All rights reserved.
//

#import "InputTableViewCell.h"

@interface InputTableViewCell ()

@property (nonatomic, weak, readwrite) UITextField *textField;

@end

@implementation InputTableViewCell

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
    CGFloat width = CGRectGetWidth(self.contentView.frame) - left * 2.f;
    CGRect textFieldFrame = CGRectMake(left, 0, width, CGRectGetHeight(self.contentView.frame));
    self.textField.frame = textFieldFrame;
    [self.contentView bringSubviewToFront:self.textField];
}

@end
