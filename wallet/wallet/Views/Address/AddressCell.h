//
//  AddressCell.h
//  wallet
//
//  Created by Zin on 16/2/27.
//  Copyright © 2016年 Bitmain. All rights reserved.
//

#import <UIKit/UIKit.h>

@class Address;

@interface AddressCell : UITableViewCell

@property (nonatomic, assign, getter=isMetadataHidden) BOOL metadataHidden;

/// UILable to display address label, labelLabel -_-|||
@property (nonatomic, weak, readonly) UILabel * _Nullable labelLabel;
@property (nonatomic, weak, readonly) UILabel * _Nullable addressLabel;
@property (nonatomic, weak, readonly) UILabel * _Nullable txsLabel;
@property (nonatomic, weak, readonly) UILabel * _Nullable balanceLabel;

- (void)setAddress:(nonnull Address *)address;

@end
