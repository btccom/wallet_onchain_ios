//
//  SendToAddressCell.h
//  CBWallet
//
//  Created by Zin (noteon.com) on 16/4/6.
//  Copyright © 2016年 Bitmain. All rights reserved.
//

#import "AddressCell.h"

@class SendToAddressCellDeleteButton;

@interface SendToAddressCell : AddressCell

@property (nonatomic, weak, readonly) SendToAddressCellDeleteButton *deleteButton;

@end

@interface SendToAddressCellDeleteButton : UIButton;

@property (nonatomic, weak) SendToAddressCell *cell;

@end
