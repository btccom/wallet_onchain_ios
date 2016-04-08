//
//  SendFromAddressCell.m
//  CBWallet
//
//  Created by Zin on 16/4/6.
//  Copyright © 2016年 Bitmain. All rights reserved.
//

#import "SendFromAddressCell.h"

#import "NSString+CBWAddress.h"

@interface SendFromAddressCell ()

@property (nonatomic, weak) UILabel *badgeLabel;

@end

@implementation SendFromAddressCell

- (UILabel *)badgeLabel {
    if (!_badgeLabel) {
        UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(CGRectGetWidth(self.contentView.frame) - CBWLayoutCommonHorizontalPadding, (CGRectGetHeight(self.contentView.frame) - CBWLayoutCommonHorizontalPadding) / 2.f, CBWLayoutCommonHorizontalPadding, CBWLayoutCommonHorizontalPadding)];
        label.font = [UIFont systemFontOfSize:UIFont.smallSystemFontSize];
        label.layer.cornerRadius = CBWLayoutCommonHorizontalPadding / 2.f;
        label.clipsToBounds = YES;
        label.backgroundColor = [UIColor CBWPrimaryColor];
        label.textColor = [UIColor CBWWhiteColor];
        label.textAlignment = NSTextAlignmentCenter;
        [self.contentView addSubview:label];
        _badgeLabel = label;
    }
    return _badgeLabel;
}


#pragma mark - Public Method
- (void)setAddresses:(NSArray *)addresses {
    if (!addresses) {
        return;
    }
    self.badgeLabel.hidden = addresses.count == 0;
    self.badgeLabel.text = [@(addresses.count) stringValue];
    self.detailTextLabel.text = [addresses componentsJoinedByString:@", "];
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    if (self.badgeLabel.text.length > 1) {
        CGSize badgeTextSize = [self.badgeLabel.text sizeWithFont:self.badgeLabel.font maxSize:self.contentView.bounds.size];
        self.badgeLabel.frame = CGRectMake(CGRectGetWidth(self.contentView.frame) - CBWLayoutCommonHorizontalPadding - badgeTextSize.width, (CGRectGetHeight(self.contentView.frame) - CBWLayoutCommonHorizontalPadding) / 2.f, CBWLayoutCommonHorizontalPadding + badgeTextSize.width, CBWLayoutCommonHorizontalPadding);
    } else {
        self.badgeLabel.frame = CGRectMake(CGRectGetWidth(self.contentView.frame) - CBWLayoutCommonHorizontalPadding, (CGRectGetHeight(self.contentView.frame) - CBWLayoutCommonHorizontalPadding) / 2.f, CBWLayoutCommonHorizontalPadding, CBWLayoutCommonHorizontalPadding);
    }
    
    CGRect detailFrame = self.detailTextLabel.frame;
    detailFrame.size.width -= CGRectGetWidth(self.badgeLabel.frame) + CBWLayoutInnerSpace;
    self.detailTextLabel.frame = detailFrame;
    self.detailTextLabel.font = [UIFont monospacedFontOfSize:UIFont.labelFontSize];
    self.detailTextLabel.attributedText = [self.detailTextLabel.text attributedAddressWithAlignment:(self.textLabel.text.length > 0 ? NSTextAlignmentRight : NSTextAlignmentLeft)];
    self.detailTextLabel.textColor = self.textLabel.text.length > 0 ? [UIColor CBWSubTextColor] : [UIColor CBWTextColor];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
    
    self.badgeLabel.backgroundColor = [UIColor CBWPrimaryColor];
}

@end
