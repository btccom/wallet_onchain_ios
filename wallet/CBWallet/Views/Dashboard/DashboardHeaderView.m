//
//  DashboardHeaderView.m
//  wallet
//
//  Created by Zin on 16/2/26.
//  Copyright © 2016年 Bitmain. All rights reserved.
//

#import "DashboardHeaderView.h"
#import "DashboardHeaderActionButton.h"

#import "UIButton+VerticalLayout.h"

@interface DashboardHeaderView ()

@property (nonatomic, weak, readwrite) UIButton * _Nullable sendButton;
@property (nonatomic, weak, readwrite) UIButton * _Nullable receiveButton;

@property (nonatomic, weak) UIView * _Nullable overlayBackgroundView;

@end

@implementation DashboardHeaderView

- (UIButton *)sendButton {
    if (!_sendButton) {
        UIButton *button = [[DashboardHeaderActionButton alloc] initWithImage:[UIImage imageNamed:@"icon_send"] title:NSLocalizedStringFromTable(@"Button send", @"CBW", @"Send")];
        [button setTitleColor:[UIColor CBWRedColor] forState:UIControlStateNormal];
        [button setTitleColor:[[UIColor CBWRedColor] colorWithAlphaComponent:.5]  forState:UIControlStateDisabled];
        [self addSubview:button];
        _sendButton = button;
    }
    return _sendButton;
}


- (UIButton *)receiveButton {
    if (!_receiveButton) {
        UIButton *button = [[DashboardHeaderActionButton alloc] initWithImage:[UIImage imageNamed:@"icon_receive"] title:NSLocalizedStringFromTable(@"Button receive", @"CBW", @"Receive")];
        [button setTitleColor:[UIColor CBWGreenColor] forState:UIControlStateNormal];
        [button setTitleColor:[[UIColor CBWGreenColor] colorWithAlphaComponent:.5]  forState:UIControlStateDisabled];
        [self addSubview:button];
        _receiveButton = button;
    }
    return _receiveButton;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    CGRect frame = self.bounds;
    frame.size.width = CGRectGetWidth(frame) / 2.f;
    
    self.sendButton.frame = frame;
    [self.sendButton centerVerticallyWithPadding:CBWLayoutInnerSpace];
    
    self.receiveButton.frame = CGRectOffset(frame, CGRectGetWidth(frame), 0);
    [self.receiveButton centerVerticallyWithPadding:CBWLayoutInnerSpace];
    
    if (!_overlayBackgroundView) {
        CGFloat screenHeight = CGRectGetHeight([UIScreen mainScreen].bounds);
        UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, -screenHeight, CGRectGetWidth(self.bounds), screenHeight + CGRectGetHeight(self.bounds))];
        view.backgroundColor = [UIColor CBWSeparatorColor];
        [self insertSubview:view atIndex:0];
        _overlayBackgroundView = view;
    }
}

@end
