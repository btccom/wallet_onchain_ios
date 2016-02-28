//
//  DashboardHeaderView.h
//  wallet
//
//  Created by Zin on 16/2/26.
//  Copyright © 2016年 Bitmain. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface DashboardHeaderView : UIView

@property (nonatomic, weak, readonly, nullable) UIButton *sendButton;
@property (nonatomic, weak, readonly, nullable) UIButton *receiveButton;

@end