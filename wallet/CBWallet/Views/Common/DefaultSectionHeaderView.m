//
//  ListSectionHeaderView.m
//  wallet
//
//  Created by Zin (noteon.com) on 16/2/27.
//  Copyright © 2016年 Bitmain. All rights reserved.
//

#import "DefaultSectionHeaderView.h"

@implementation DefaultSectionHeaderView
@synthesize detailTextLabel = _detailTextLabel;

//- (instancetype)initWithReuseIdentifier:(NSString *)reuseIdentifier {
//    self = [super initWithReuseIdentifier:reuseIdentifier];
//    if (self) {
//        self.backgroundView = [[UIVisualEffectView alloc] initWithEffect:[UIBlurEffect effectWithStyle:UIBlurEffectStyleExtraLight]];
//    }
//    return self;
//}

- (UILabel *)detailTextLabel {
    if (!_detailTextLabel) {
        UILabel *label = [[UILabel alloc] init];
        label.textAlignment = NSTextAlignmentRight;
        label.font = [UIFont systemFontOfSize:12.f];
        label.textColor = [UIColor CBWSubTextColor];
        [self.contentView addSubview:label];
        _detailTextLabel = label;
    }
    return _detailTextLabel;
}

- (void)willMoveToSuperview:(UIView *)newSuperview {
    self.textLabel.font = [UIFont systemFontOfSize:CBWSectionHeaderFontSize weight:UIFontWeightBold];
    self.textLabel.textColor = [UIColor CBWSubTextColor];
    self.contentView.backgroundColor = [UIColor CBWBackgroundColor];
    
    if (!self.isTopHairlineHidden) {
        CGRect hairlineFrame = newSuperview.bounds;
        hairlineFrame.size.height = 1.f / [UIScreen mainScreen].scale;
        hairlineFrame.origin.y = -CGRectGetHeight(hairlineFrame);
        UIView *hairline = [[UIView alloc] initWithFrame:hairlineFrame];
        hairline.backgroundColor = [UIColor CBWSeparatorColor];
        [self.contentView insertSubview:hairline atIndex:0];
    }
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    self.textLabel.text = self.textLabel.text.uppercaseString;
    self.detailTextLabel.frame = CGRectMake(CGRectGetMaxX(self.textLabel.frame), CGRectGetMinY(self.textLabel.frame), CGRectGetWidth(self.contentView.frame) - CGRectGetMinX(self.textLabel.frame) - CGRectGetMaxX(self.textLabel.frame), CGRectGetHeight(self.textLabel.frame));
}

@end
