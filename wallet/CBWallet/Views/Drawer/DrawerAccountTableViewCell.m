//
//  DrawerAccountTableViewCell.m
//  CBWallet
//
//  Created by Zin on 16/7/14.
//  Copyright © 2016年 Bitmain. All rights reserved.
//

#import "DrawerAccountTableViewCell.h"

@interface DrawerAccountTableViewCell ()

@property (nonatomic, weak, readwrite) UILabel *balanceLabel;
@property (nonatomic, weak) UIImageView *selectedIndicator;

@end

@implementation DrawerAccountTableViewCell

- (UILabel *)balanceLabel {
    if (!_balanceLabel) {
        UILabel *label = [[UILabel alloc] init];
        label.font = [UIFont systemFontOfSize:[UIFont smallSystemFontSize]];
        label.textColor = [[UIColor CBWWhiteColor] colorWithAlphaComponent:0.6];
        label.textAlignment = NSTextAlignmentRight;
        [self.contentView addSubview:label];
        _balanceLabel = label;
    }
    return _balanceLabel;
}

- (UIImageView *)selectedIndicator {
    if (!_selectedIndicator) {
        UIImageView *view = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"image_wallet_selected_indicator"]];
        view.center = CGPointMake(CGRectGetMidX(view.bounds), CGRectGetMidY(self.contentView.bounds));
        view.alpha = 0;
        [self.contentView addSubview:view];
        _selectedIndicator = view;
    }
    return _selectedIndicator;
}

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:reuseIdentifier];
    return self;
}

- (void)becomeCurrent:(BOOL)current animated:(BOOL)animated {
    // Configure the view for the selected state
    if (animated) {
        [UIView animateWithDuration:CBWAnimateDuration delay:0 options:UIViewAnimationOptionBeginFromCurrentState animations:^{
            self.selectedIndicator.alpha = current ? 1.0 : 0;
        } completion:nil];
    } else {
        self.selectedIndicator.alpha = current ? 1.0 : 0;
    }
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
    
}

- (void)willMoveToSuperview:(UIView *)newSuperview {
    [super willMoveToSuperview:newSuperview];
    
    self.selectedBackgroundView = [UIView new];
    self.selectedBackgroundView.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.2];
    self.backgroundColor = [UIColor CBWPrimaryColor];
    self.contentView.backgroundColor = [UIColor CBWPrimaryColor];
    
    self.textLabel.backgroundColor = [UIColor CBWPrimaryColor];
    self.textLabel.textColor = [UIColor whiteColor];
    self.detailTextLabel.backgroundColor = [UIColor CBWPrimaryColor];
    self.detailTextLabel.textColor = [[UIColor CBWWhiteColor] colorWithAlphaComponent:0.6];
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    self.selectedBackgroundView.frame = self.bounds;
    
    CGFloat height = CGRectGetHeight(self.contentView.frame);
    
    CGFloat textHeight = 22;
    CGFloat detailHeight = 16;
    
    CGFloat textDetailMargin = height - textHeight - detailHeight - CBWLayoutCommonVerticalPadding * 2;
    
    CGRect textFrame = self.textLabel.frame;
    textFrame.origin.y = CBWLayoutCommonVerticalPadding;
    self.textLabel.frame = textFrame;
    
    CGRect detailFrame = self.detailTextLabel.frame;
    detailFrame.origin.y = CGRectGetMaxY(self.textLabel.frame) + textDetailMargin;
    self.detailTextLabel.frame = detailFrame;
    
    CGFloat width = CGRectGetWidth(self.contentView.frame);
    CGFloat balanceLeft = CGRectGetMaxX(self.detailTextLabel.frame) + CBWLayoutInnerSpace;
    CGFloat balanceWidth = width - balanceLeft - CGRectGetMinX(self.detailTextLabel.frame);
    self.balanceLabel.frame = CGRectMake(balanceLeft, CGRectGetMinY(self.detailTextLabel.frame), balanceWidth, detailHeight);
}

@end
