//
//  BlockButtonCell.h
//  wallet
//
//  Created by Zin on 16/2/29.
//  Copyright © 2016年 Bitmain. All rights reserved.
//

#import "FormControlCell.h"

typedef NS_ENUM(NSUInteger, BlockButtonCellStyle) {
    /// default <code>FormControllCellStatusHighlighted</code>
    BlockButtonCellStylePrimary,
    /// <code>FormControllCellStatusDefault</code>
    BlockButtonCellStyleDefault,
    /// <code>FormControllCellStatusSuccess</code>
    BlockButtonCellStyleSuccess,
    /// like <code>FormControllCellStatusError</code>
    BlockButtonCellStyleDanger
};

@interface BlockButtonCell : FormControlCell

@property (nonatomic, assign) BlockButtonCellStyle buttonCellStyle;

@end
