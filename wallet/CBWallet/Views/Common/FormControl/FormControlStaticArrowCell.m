//
//  FormControlStaticArrowCell.m
//  CBWallet
//
//  Created by Zin (noteon.com) on 16/4/6.
//  Copyright © 2016年 Bitmain. All rights reserved.
//

#import "FormControlStaticArrowCell.h"

@implementation FormControlStaticArrowCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:reuseIdentifier];
    if (self) {
        self.accessoryView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"accessory_arrow_right"]];
    }
    return self;
}

@end
