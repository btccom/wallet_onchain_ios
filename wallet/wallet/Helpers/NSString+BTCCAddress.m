//
//  NSString+BTCCAddress.m
//  wallet
//
//  Created by Zin on 16/2/27.
//  Copyright © 2016年 Bitmain. All rights reserved.
//

#import "NSString+BTCCAddress.h"
//#import <CoreImage/CoreImage.h>
//#import <AVFoundation/AVFoundation.h>

@implementation NSString (BTCCAddress)

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

@end
