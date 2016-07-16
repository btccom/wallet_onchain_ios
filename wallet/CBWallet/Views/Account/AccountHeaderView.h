//
//  AccountHeaderView.h
//  wallet
//
//  Created by Zin (noteon.com) on 16/2/26.
//  Copyright © 2016年 Bitmain. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface AccountHeaderView : UIView

@property (nonatomic, weak, readonly, nullable) UIButton *sendButton;
@property (nonatomic, weak, readonly, nullable) UIButton *receiveButton;

@end