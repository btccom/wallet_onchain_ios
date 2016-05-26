//
//  DashboardBalanceTitleView.m
//  CBWallet
//
//  Created by Zin on 16/5/26.
//  Copyright © 2016年 Bitmain. All rights reserved.
//

#import "DashboardBalanceTitleView.h"

@interface DashboardBalanceTitleView ()

@property (nonatomic, weak) UILabel *titleLabel;
@property (nonatomic, weak) UILabel *balanceLabel;

@property (nonatomic, assign) BOOL balanceShown;
@property (nonatomic, assign) BOOL animating;

@end

@implementation DashboardBalanceTitleView

- (UILabel *)titleLabel {
    if (!_titleLabel) {
        UILabel *label = [[UILabel alloc] initWithFrame:self.bounds];
        label.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        label.font = [UIFont systemFontOfSize:[UIFont labelFontSize] weight:UIFontWeightMedium];
        label.textAlignment = NSTextAlignmentCenter;
        [self addSubview:label];
        _titleLabel = label;
    }
    return _titleLabel;
}

- (UILabel *)balanceLabel {
    if (!_balanceLabel) {
        UILabel *label = [[UILabel alloc] initWithFrame:self.bounds];
        label.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        label.font = [UIFont systemFontOfSize:[UIFont labelFontSize] weight:UIFontWeightMedium];
        label.textAlignment = NSTextAlignmentCenter;
        label.alpha = 0;
        [self addSubview:label];
        _balanceLabel = label;
    }
    return _balanceLabel;
}

- (void)setTitle:(NSString *)title {
    _title = [title copy];
    self.titleLabel.text = _title;
}

- (void)setBalance:(NSString *)balance {
    _balance = [balance copy];
    self.balanceLabel.text = _balance;
}

- (void)willMoveToSuperview:(UIView *)newSuperview {
    UITapGestureRecognizer *recognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(p_toggleTitle)];
    [self addGestureRecognizer:recognizer];
}

- (void)p_toggleTitle {
    if (self.animating) {
        return;
    }
    self.animating = YES;
    [UIView animateWithDuration:CBWAnimateDurationFast animations:^{
        if (self.balanceShown) {
            self.balanceLabel.alpha = 0;
            self.titleLabel.alpha = 1;
        } else {
            self.balanceLabel.alpha = 1;
            self.titleLabel.alpha = 0;
        }
    } completion:^(BOOL finished) {
        self.animating = NO;
        self.balanceShown = !self.balanceShown;
    }];
}

@end
