//
//  TransactionIOCell.m
//  CBWallet
//
//  Created by Zin on 16/3/31.
//  Copyright © 2016年 Bitmain. All rights reserved.
//

#import "TransactionIOCell.h"

#import "NSString+CBWAddress.h"

@implementation TransactionIOCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:reuseIdentifier];
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    self.textLabel.font = [UIFont monospacedFontOfSize:16.f];
    self.detailTextLabel.font = [UIFont fontWithName:@"HelveticaNeue" size:15.f];
    
    CGRect addressFrame = self.textLabel.frame;
    
    if (self.detailTextLabel.text.length > 0) {
        CGSize valueSize = [self.detailTextLabel.text sizeWithFont:self.detailTextLabel.font maxSize:CGSizeMake(CGRectGetWidth(self.contentView.frame) / 2.f, CGRectGetHeight(self.contentView.frame))];
        CGRect valueFrame = self.detailTextLabel.frame;
        valueFrame.origin.x = CGRectGetMaxX(valueFrame) - valueSize.width;
        valueFrame.size.width = valueSize.width;
        self.detailTextLabel.frame = valueFrame;
        
        addressFrame.size.width -= (CGRectIntersection(addressFrame, valueFrame).size.width + CBWLayoutInnerSpace);
    } else {
        addressFrame.size.width = [self.textLabel.text sizeWithFont:self.textLabel.font maxSize:self.contentView.frame.size].width;
    }
    
    self.textLabel.frame = addressFrame;
    
    self.textLabel.attributedText = [self.textLabel.text attributedAddressWithAlignment:NSTextAlignmentLeft];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
