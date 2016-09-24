//
//  SendConfirmationViewController.h
//  CBWallet
//
//  Created by Zin on 16/8/15.
//  Copyright © 2016年 Bitmain. All rights reserved.
//

#import "BaseFormViewController.h"


typedef NS_ENUM(NSUInteger, SendConfirmationViewControllerState) {
    SendConfirmationViewControllerStateIdle,
    SendConfirmationViewControllerStateBroadcasting,
    SendConfirmationViewControllerStateSuccess,
    SendConfirmationViewControllerStateFailed
};

@class SendConfirmationViewController, CBWAddress, CBWFee;

@protocol SendConfirmationViewControllerDelegate <NSObject>

@optional
- (void)sendConfirmationViewController:(SendConfirmationViewController *)viewController didBroadcast:(BOOL)flag;
- (BOOL)sendConfirmationViewControllerWillDismiss:(SendConfirmationViewController *)viewController;

@end

@interface SendConfirmationViewController : BaseFormViewController

/// to broadcast
@property (nonatomic, copy) NSString *txHash;
@property (nonatomic, copy) NSArray <CBWAddress *> *toAddresses;
@property (nonatomic, assign) long long fee;
@property (nonatomic, assign) long long feePerKByte;

@property (nonatomic, weak) id delegate;

@property (nonatomic, assign, readonly) SendConfirmationViewControllerState state;

@end
