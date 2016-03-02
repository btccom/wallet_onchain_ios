//
//  ListSectionHeaderView.m
//  wallet
//
//  Created by Zin on 16/2/27.
//  Copyright © 2016年 Bitmain. All rights reserved.
//

#import "ListSectionHeaderView.h"

@implementation ListSectionHeaderView

//- (instancetype)initWithReuseIdentifier:(NSString *)reuseIdentifier {
//    self = [super initWithReuseIdentifier:reuseIdentifier];
//    if (self) {
//        self.backgroundView = [[UIVisualEffectView alloc] initWithEffect:[UIBlurEffect effectWithStyle:UIBlurEffectStyleExtraLight]];
//    }
//    return self;
//}

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
}

@end
