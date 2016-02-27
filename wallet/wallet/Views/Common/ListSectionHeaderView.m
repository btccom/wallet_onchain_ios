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
    self.textLabel.font = [UIFont systemFontOfSize:BTCCSectionHeaderFontSize];
    self.textLabel.textColor = [UIColor BTCCSubTextColor];
    self.contentView.backgroundColor = [UIColor BTCCBackgroundColor];
}

@end
