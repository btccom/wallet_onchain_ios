//
//  FormControlCell.h
//  wallet
//
//  Created by Zin on 16/2/29.
//  Copyright © 2016年 Bitmain. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSUInteger, FormControlCellStatus) {
    FormControlCellStatusDefault,
    FormControlCellStatusHighlighted,
    FormControlCellStatusDisabled,
    FormControlCellStatusProcess,
    FormControlCellStatusSuccess,
    FormControlCellStatusError
};

@interface BaseFormControlCell : UITableViewCell

@property (nonatomic, assign) FormControlCellStatus status;

- (void)setStatus:(FormControlCellStatus)status animated:(BOOL)animated;

@end
