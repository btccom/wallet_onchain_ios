//
//  ResponderLabel.m
//  CBWallet
//
//  Created by Zin on 16/5/11.
//  Copyright © 2016年 Bitmain. All rights reserved.
//

#import "ResponderLabel.h"

@implementation ResponderLabel

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self initGestureRecognizer];
    }
    return self;
}

- (BOOL)canBecomeFirstResponder {
    return YES;
}

- (BOOL)canPerformAction:(SEL)action withSender:(id)sender {
    return action == @selector(repost:);
}

- (void)initGestureRecognizer {
    self.userInteractionEnabled = YES;
    UILongPressGestureRecognizer *gesture = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(handleGesture:)];
    [self addGestureRecognizer:gesture];
}

- (void)repost:(id)sender {
    UIPasteboard *board = [UIPasteboard generalPasteboard];
    board.string = self.text;
}

- (void)handleGesture:(UIGestureRecognizer *)gesture {
    [self becomeFirstResponder];
    UIMenuItem *copyItem = [[UIMenuItem alloc] initWithTitle:NSLocalizedStringFromTable(@"Copy", @"CBW", nil)
                                                      action:@selector(repost:)];
    
    [[UIMenuController sharedMenuController] setMenuItems:[NSArray arrayWithObjects:copyItem, nil]];
    [[UIMenuController sharedMenuController] setTargetRect:self.frame inView:self.superview];
    [[UIMenuController sharedMenuController] setMenuVisible:YES animated: YES];
}

@end
