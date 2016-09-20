//
//  BlockButtonCell.h
//  wallet
//
//  Created by Zin (noteon.com) on 16/2/29.
//  Copyright © 2016年 Bitmain. All rights reserved.
//

#import "BaseFormControlCell.h"

typedef NS_ENUM(NSUInteger, BlockButtonCellStyle) {
    /// default <code>BaseFormControlCellStatusHighlighted</code>
    BlockButtonCellStylePrimary,
    /// <code>BaseFormControlCellStatusDefault</code>
    BlockButtonCellStyleDefault,
    /// <code>BaseFormControlCellStatusSuccess</code>
    BlockButtonCellStyleSuccess,
    /// like <code>BaseFormControlCellStatusError</code>
    BlockButtonCellStyleDanger,
    BlockButtonCellStyleProcess
};

/// align center, like sign up button
@interface FormControlBlockButtonCell : BaseFormControlCell

@property (nonatomic, assign) BlockButtonCellStyle buttonCellStyle;

@property (nonatomic, assign) BOOL enabled;

@end
