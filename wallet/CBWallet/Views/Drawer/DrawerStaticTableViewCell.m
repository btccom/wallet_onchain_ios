//
//  DrawerStaticTableViewCell.m
//  CBWallet
//
//  Created by Zin on 16/7/14.
//  Copyright © 2016年 Bitmain. All rights reserved.
//

#import "DrawerStaticTableViewCell.h"

@implementation DrawerStaticTableViewCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:reuseIdentifier];
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)willMoveToSuperview:(UIView *)newSuperview {
    [super willMoveToSuperview:newSuperview];
    
    self.selectedBackgroundView = [UIView new];
    self.selectedBackgroundView.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.2];
    self.backgroundColor = [UIColor CBWPrimaryDarkColor];
    self.contentView.backgroundColor = [UIColor CBWPrimaryDarkColor];
    
    self.textLabel.backgroundColor = [UIColor CBWPrimaryDarkColor];
    self.textLabel.textColor = [UIColor CBWWhiteColor];
    self.detailTextLabel.backgroundColor = [UIColor CBWPrimaryDarkColor];
    self.detailTextLabel.font = [UIFont systemFontOfSize:[UIFont smallSystemFontSize]];
    self.detailTextLabel.textColor = [[UIColor CBWWhiteColor] colorWithAlphaComponent:0.6];
}

@end
