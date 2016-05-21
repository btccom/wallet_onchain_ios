//
//  DefaultSectionFooterView.m
//  CBWallet
//
//  Created by Zin on 16/5/21.
//  Copyright © 2016年 Bitmain. All rights reserved.
//

#import "DefaultSectionFooterView.h"

@implementation DefaultSectionFooterView

- (instancetype)initWithReuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithReuseIdentifier:reuseIdentifier];
    if (self) {
        self.textLabel.textColor = [UIColor CBWSubTextColor];
        self.textLabel.font = [UIFont systemFontOfSize:[UIFont smallSystemFontSize]];
        self.textLabel.lineBreakMode = NSLineBreakByWordWrapping;
        self.textLabel.numberOfLines = 0;
    }
    return self;
}

- (CGFloat)preferredHeightForText:(NSString *)text {
    if (text.length > 0) {
        CGSize maxSize = CGSizeMake(SCREEN_WIDTH, CGFLOAT_MAX);
        return [text sizeWithFont:self.textLabel.font maxSize:maxSize].height + 2 * CBWLayoutCommonVerticalPadding;
    }
    return 0;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    self.textLabel.center = self.contentView.center;
}

@end
