//
//  AccountHeaderActionButton.m
//  wallet
//
//  Created by Zin (noteon.com) on 16/2/26.
//  Copyright © 2016年 Bitmain. All rights reserved.
//

#import "AccountHeaderActionButton.h"

@implementation AccountHeaderActionButton
- (instancetype)initWithImage:(UIImage *)image title:(NSString *)title {
    self = [super init];
    if (self) {
        [self setImage:image forState:UIControlStateNormal];
        [self setTitle:title.uppercaseString forState:UIControlStateNormal];
        self.titleLabel.font = [UIFont systemFontOfSize:UIFont.buttonFontSize];
    }
    return self;
}
@end
