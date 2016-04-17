//
//  NSString+CBWAddress.m
//  wallet
//
//  Created by Zin on 16/2/27.
//  Copyright © 2016年 Bitmain. All rights reserved.
//

#import "NSString+CBWAddress.h"
//#import <CoreImage/CoreImage.h>
//#import <AVFoundation/AVFoundation.h>

NSString *const CBWAddressInfoAddressKey = @"address";
NSString *const CBWAddressInfoLabelKey = @"label";
NSString *const CBWAddressInfoAmountKey = @"amount";

@implementation NSString (CBWAddress)

- (NSAttributedString *)attributedAddressWithAlignment:(NSTextAlignment)alignment {
    NSMutableAttributedString *attributedString = [[NSMutableAttributedString alloc] initWithString:self];
    NSMutableParagraphStyle *paragraph = [[NSMutableParagraphStyle alloc] init];
    paragraph.alignment = alignment;
    paragraph.lineBreakMode = NSLineBreakByTruncatingMiddle;
    [attributedString addAttribute:NSParagraphStyleAttributeName value:paragraph range:NSMakeRange(0, [attributedString length])];
    return attributedString;
}

- (UIImage *)qrcodeImageWithSize:(CGSize)size {
    if (self.length == 0) {
        return nil;
    }
    // TODO: in background thread
    // CIQRCodeGenerator filter
    CIFilter *filter = [CIFilter filterWithName:@"CIQRCodeGenerator"];
    [filter setDefaults];
    
    // data
    NSData *data = [self dataUsingEncoding:NSUTF8StringEncoding];
    [filter setValue:data forKey:@"inputMessage"];
    
    // out image
    CIImage *outImage = [filter outputImage];
    
    // cg image
    CIContext *context = [CIContext contextWithOptions:nil];
    CGImageRef cgImage = [context createCGImage:outImage
                                       fromRect:[outImage extent]];
    
    // image
    UIImage *image = [UIImage imageWithCGImage:cgImage
                                         scale:1.
                                   orientation:UIImageOrientationUp];
    
    // resize image
    UIGraphicsBeginImageContext(size);
    CGContextRef graphicsContext = UIGraphicsGetCurrentContext();
    CGContextSetInterpolationQuality(graphicsContext, kCGInterpolationNone);
    [image drawInRect:CGRectMake(0, 0, size.width, size.height)];
    image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    CGImageRelease(cgImage);
    
    return image;
}

- (NSDictionary *)addressInfo {
    NSString *address = [self stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    address = [address stringByRemovingPercentEncoding];
    address = [address stringByReplacingOccurrencesOfString:@" " withString:@""];
    address = [address stringByReplacingOccurrencesOfString:@"bitcoin://" withString:@""];
    address = [address stringByReplacingOccurrencesOfString:@"bitcoin:" withString:@""];
    
    // get address string
    NSURL *addressURL = [NSURL URLWithString:[NSString stringWithFormat:@"http://getbitcard.com/%@", address]];
    NSString *addressString = [addressURL.path stringByReplacingOccurrencesOfString:@"/" withString:@""];
    
    // valid address
    NSString *pattern = @"^[1|3][a-zA-Z1-9]{26,33}$";// not including 0
    NSError *error = nil;
    NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:pattern options:NSRegularExpressionCaseInsensitive error:&error];
    NSAssert(regex, @"Unable to create regular expression");
    NSRange textRange = NSMakeRange(0, addressString.length);
    NSRange matchRange = [regex rangeOfFirstMatchInString:addressString options:NSMatchingReportProgress range:textRange];
    if (matchRange.location == NSNotFound) {
        return nil;
    }
    if ([addressString rangeOfString:@"I"].location != NSNotFound) return nil;
    if ([addressString rangeOfString:@"l"].location != NSNotFound) return nil;
    if ([addressString rangeOfString:@"O"].location != NSNotFound) return nil;
    
    // get label
    __block NSString *label = @"";
    __block NSString *amount = @"";
    NSArray *queries = [addressURL.query componentsSeparatedByString:@"&"];
    [queries enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        NSArray *kvPair = [obj componentsSeparatedByString:@"="];
        if (kvPair.count > 1) {
            if ([kvPair[0] isEqualToString:CBWAddressInfoLabelKey]) {
                label = kvPair[1];//[kvPair[1] stringByRemovingPercentEncoding];
            } else if ([kvPair[0] isEqualToString:CBWAddressInfoAmountKey]) {
                amount = kvPair[1];
            }
        }
    }];
    
    return @{CBWAddressInfoAddressKey: addressString, CBWAddressInfoLabelKey: label, CBWAddressInfoAmountKey: amount};
}

@end
