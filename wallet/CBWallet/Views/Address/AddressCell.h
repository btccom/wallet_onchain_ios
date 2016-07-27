//
//  AddressCell.h
//  wallet
//
//  Created by Zin (noteon.com) on 16/2/27.
//  Copyright © 2016年 Bitmain. All rights reserved.
//

#import "BaseFormControlCell.h"

@class CBWAddress;

@interface AddressCell : BaseFormControlCell

@property (nonatomic, assign, getter=isMetadataHidden) BOOL metadataHidden;

/// UILable to display address label, labelLabel -_-|||
@property (nonatomic, weak, readonly) UILabel * _Nullable labelLabel;
@property (nonatomic, weak, readonly) UILabel * _Nullable addressLabel;
@property (nonatomic, weak, readonly) UILabel * _Nullable txsLabel;
@property (nonatomic, weak, readonly) UILabel * _Nullable balanceLabel;

- (void)setAddress:(nullable CBWAddress *)address;

@end
