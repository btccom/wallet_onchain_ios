//
//  AddressHeaderView.h
//  wallet
//
//  Created by Zin on 16/2/28.
//  Copyright © 2016年 Bitmain. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface AddressHeaderView : UIView

@property (nonatomic, assign, getter=isLabelEditable) BOOL labelEditable;
@property (nonatomic, strong, readonly) NSString * _Nullable label;

- (void)setAddress:(nonnull NSString *)address withLabel:(nullable NSString *)label;

@end
