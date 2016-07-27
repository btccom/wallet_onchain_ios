//
//  AddressCardView.h
//  CBWallet
//
//  Created by Zin on 16/7/1.
//  Copyright © 2016年 Bitmain. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface AddressCardView : UIView

@property (nonatomic, weak, readonly) UITextField *addressLabelField;
@property (nonatomic, weak, readonly) UILabel *addressLabel;
@property (nonatomic, weak, readonly) UIButton *qrcodeButton;
@property (nonatomic, weak, readonly) UILabel *balanceLabel;
@property (nonatomic, weak, readonly) UILabel *receivedLabel;
@property (nonatomic, weak, readonly) UILabel *txLabel;

@end
