//
//  UIView+Yoyo.m
//  CBWallet
//
//  Created by Zin on 16/6/1.
//  Copyright © 2016年 Bitmain. All rights reserved.
//

#import "UIView+Yoyo.h"

@implementation UIView (Yoyo)

- (void)yoyoWithOffset:(CGSize)offset animateDuration:(NSTimeInterval)duration {
    CAKeyframeAnimation *yoyo = [CAKeyframeAnimation animationWithKeyPath:@"position"];
    CGPoint start = self.layer.position;
    NSMutableArray *positions = [NSMutableArray array];
    [positions addObject:[NSValue valueWithCGPoint:start]];
    [positions addObject:[NSValue valueWithCGPoint:CGPointMake(start.x - offset.width, start.y - offset.height)]];
    [positions addObject:[NSValue valueWithCGPoint:CGPointMake(start.x + 0.8 * offset.width, start.y + 0.8 * offset.height)]];
    [positions addObject:[NSValue valueWithCGPoint:CGPointMake(start.x - 0.5 * offset.width, start.y - 0.5 * offset.height)]];
    [positions addObject:[NSValue valueWithCGPoint:CGPointMake(start.x +  0.1 * offset.width, start.y + 0.1 * offset.height)]];
    [positions addObject:[NSValue valueWithCGPoint:start]];
    [yoyo setValues:positions];
    [yoyo setCalculationMode:kCAAnimationCubic];
    [yoyo setTimingFunction:[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseOut]];
    [yoyo setDuration:duration];
    [self.layer addAnimation:yoyo forKey:@"yoyo"];
//    [UIView animateWithDuration:duration / 4.0 animations:^{
//        self.frame = CGRectOffset(self.frame, -offset.width, -offset.height);
//    } completion:^(BOOL finished) {
//        [UIView animateWithDuration:duration / 2.0 animations:^{
//            self.frame = CGRectOffset(self.frame, 2 * offset.width, 2 * offset.height);
//        } completion:^(BOOL finished) {
//            [UIView animateWithDuration:duration / 4.0 animations:^{
//                self.frame = CGRectOffset(self.frame, -offset.width, -offset.height);
//            }];
//        }];
//    }];
}

@end
