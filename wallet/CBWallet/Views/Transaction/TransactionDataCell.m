//
//  TransactionDataCell.m
//  CBWallet
//
//  Created by Zin on 16/3/31.
//  Copyright © 2016年 Bitmain. All rights reserved.
//

#import "TransactionDataCell.h"

@implementation TransactionDataCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:reuseIdentifier];
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    if (self.isHashEnabled) {
        self.detailTextLabel.font = [UIFont monospacedFontOfSize:13.f];
        self.detailTextLabel.lineBreakMode = NSLineBreakByCharWrapping;
        self.detailTextLabel.numberOfLines = 2;
        CGFloat width = 250.f;
        CGRect frame = self.detailTextLabel.frame;
        frame.origin.x += CGRectGetWidth(frame) - width;
        frame.origin.y = 0;
        frame.size.width = width;
        frame.size.height = CGRectGetHeight(self.contentView.frame);
        self.detailTextLabel.frame = frame;
    } else {
        self.detailTextLabel.font = [UIFont fontWithName:@"HelveticaNeue" size:15.f];
        self.detailTextLabel.lineBreakMode = NSLineBreakByClipping;
        self.detailTextLabel.numberOfLines = 1;
    }
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
