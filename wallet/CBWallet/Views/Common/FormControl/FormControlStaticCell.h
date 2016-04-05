//
//  FormControlStaticCell.h
//  CBWallet
//
//  Created by Zin (noteon.com) on 16/4/1.
//  Copyright © 2016年 Bitmain. All rights reserved.
//

#import "BaseFormControlCell.h"

/// text label, detail text label on the right, badge, accesory arrow
@interface FormControlStaticCell : BaseFormControlCell

@property (nonatomic, weak, nullable) UIImageView *iconView;

@property (nonatomic, assign, getter=isBadgeEnabled) BOOL badgeEnabled;
@property (nonatomic, assign) NSInteger badgeNumber;

@end
