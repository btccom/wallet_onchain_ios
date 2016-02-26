//
//  DashboardHeaderActionButton.m
//  wallet
//
//  Created by Zin on 16/2/26.
//  Copyright © 2016年 Bitmain. All rights reserved.
//

#import "DashboardHeaderActionButton.h"

@implementation DashboardHeaderActionButton
- (instancetype)initWithImage:(UIImage *)image title:(NSString *)title {
    self = [super init];
    if (self) {
        [self setImage:image forState:UIControlStateNormal];
        [self setTitle:title.uppercaseString forState:UIControlStateNormal];
        [self setTitleColor:[UIColor BTCCWhiteColor] forState:UIControlStateNormal];
        self.titleLabel.font = [UIFont systemFontOfSize:18.f weight:UIFontWeightLight];
    }
    return self;
}
@end
