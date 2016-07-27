//
//  InputTableViewCell.h
//  CBWallet
//
//  Created by Zin (noteon.com) on 16/3/21.
//  Copyright © 2016年 Bitmain. All rights reserved.
//

#import "BaseFormControlCell.h"


typedef NS_ENUM(NSUInteger, FormControlInputType) {
    FormControlInputTypeDefault,
    /// monospace font
    FormControlInputTypeBitcoinAddress,
    /// format automatically
    FormControlInputTypeBitcoinAmount
};

@interface FormControlInputCell : BaseFormControlCell

@property (nonatomic, weak, nullable, readonly) UITextField *textField;

@property (nonatomic, assign) FormControlInputType inputType;

@end
