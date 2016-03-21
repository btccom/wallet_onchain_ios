//
//  BlockButtonCell.h
//  wallet
//
//  Created by Zin on 16/2/29.
//  Copyright © 2016年 Bitmain. All rights reserved.
//

#import "BaseFormControlCell.h"

typedef NS_ENUM(NSUInteger, BlockButtonCellStyle) {
    /// default <code>BaseFormControllCellStatusHighlighted</code>
    BlockButtonCellStylePrimary,
    /// <code>BaseFormControllCellStatusDefault</code>
    BlockButtonCellStyleDefault,
    /// <code>BaseFormControllCellStatusSuccess</code>
    BlockButtonCellStyleSuccess,
    /// like <code>BaseFormControllCellStatusError</code>
    BlockButtonCellStyleDanger
};

/// align center, like sign up button
@interface BlockButtonCell : BaseFormControlCell

@property (nonatomic, assign) BlockButtonCellStyle buttonCellStyle;

@end
