//
//  FormControlCell.h
//  wallet
//
//  Created by Zin on 16/2/29.
//  Copyright © 2016年 Bitmain. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSUInteger, BaseFormControlCellStatus) {
    BaseFormControlCellStatusDefault,
    BaseFormControlCellStatusHighlighted,
    BaseFormControlCellStatusDisabled,
    BaseFormControlCellStatusProcess,
    BaseFormControlCellStatusSuccess,
    BaseFormControlCellStatusError
};

@interface BaseFormControlCell : UITableViewCell

@property (nonatomic, assign) BaseFormControlCellStatus status;

- (void)setStatus:(BaseFormControlCellStatus)status animated:(BOOL)animated;

@end
