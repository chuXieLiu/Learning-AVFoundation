//
//  UIColor+Extension.m
//  AudioPlayer
//
//  Created by c_xie on 16/3/21.
//  Copyright © 2016年 CX. All rights reserved.
//

#import "UIColor+Extension.h"

@implementation UIColor (Extension)

- (UIColor *)lighterColor
{
    // 柔和度，饱和度，亮度
    CGFloat hue , saturation , brightness , alpha;
    if ([self getHue:&hue saturation:&saturation brightness:&brightness alpha:&alpha]) {
        return  [UIColor colorWithHue:hue saturation:saturation brightness:MIN(brightness * 1.3, 1.0) alpha:0.5];
    }
    return self;
}

- (UIColor *)darkerColor
{
    // 柔和度，饱和度，亮度
    CGFloat hue , saturation , brightness , alpha;
    if ([self getHue:&hue saturation:&saturation brightness:&brightness alpha:&alpha]) {
        return  [UIColor colorWithHue:hue saturation:saturation brightness:brightness *0.8 alpha:alpha];
    }
    return self;
}


@end
