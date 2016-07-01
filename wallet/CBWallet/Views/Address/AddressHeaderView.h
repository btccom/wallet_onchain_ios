//
//  AddressHeaderView.h
//  wallet
//
//  Created by Zin on 16/2/28.
//  Copyright © 2016年 Bitmain. All rights reserved.
//

#import <UIKit/UIKit.h>

@class AddressHeaderView;

@protocol AddressHeaderViewDelegate <NSObject>

@optional

/// end editing address's label
- (void)addressHeaderViewDidEndEditing:(nonnull AddressHeaderView *)view;
- (void)addressHeaderViewDidEditingChanged:(nonnull AddressHeaderView *)view;

@end

@interface AddressHeaderView : UIView

@property (nonatomic, assign, getter=isLabelEditable) BOOL labelEditable;
@property (nonatomic, strong, readonly, nullable) NSString *label;
@property (nonatomic, copy, nullable) NSString *placeholder;
@property (nonatomic, weak, nullable) id<AddressHeaderViewDelegate> delegate;
@property (nonatomic, weak, readonly, nullable) UIImageView *qrcodeImageView;

- (void)setAddress:(nonnull NSString *)address withLabel:(nullable NSString *)label;

@end
