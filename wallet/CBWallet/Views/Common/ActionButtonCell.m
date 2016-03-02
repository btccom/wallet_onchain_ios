//
//  ActionCell.m
//  wallet
//
//  Created by Zin on 16/2/28.
//  Copyright © 2016年 Bitmain. All rights reserved.
//

#import "ActionButtonCell.h"

@implementation ActionButtonCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:reuseIdentifier];
    if (self) {
        self.textLabel.textColor = [UIColor CBWPrimaryColor];
    }
    return self;
}

@end
