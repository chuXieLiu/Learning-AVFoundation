//
//  CXPlayerButton.m
//  AudioPlayer
//
//  Created by c_xie on 16/3/21.
//  Copyright © 2016年 CX. All rights reserved.
//

#import "CXPlayerButton.h"
#import "UIColor+Extension.h"

@implementation CXPlayerButton

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self setupView];
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)coder {
    self = [super initWithCoder:coder];
    if (self) {
        [self setupView];
    }
    return self;
}

- (void)setupView {
    self.backgroundColor = [UIColor clearColor];
    self.tintColor = [UIColor clearColor];
}

- (void)setHighlighted:(BOOL)highlighted {
    [super setHighlighted:highlighted];

    [self setNeedsDisplay];
}



- (void)drawRect:(CGRect)rect {
    
    // 创建色彩空间
    CGColorSpaceRef colorRef = CGColorSpaceCreateDeviceRGB();
    
    // 创建上下文
    CGContextRef contextRef = UIGraphicsGetCurrentContext();
    
    // 创建渐变色
    UIColor *lightColor = [UIColor colorWithRed:0.101 green:0.100 blue:0.103 alpha:1.000];
    UIColor *darkColor =  [UIColor colorWithRed:0.237 green:0.242 blue:0.242 alpha:1.000];
    // 高亮时渐变色
    if (self.highlighted) {
        lightColor = [lightColor darkerColor];
        darkColor = [darkColor darkerColor];
    }
    
    
    NSArray *gradientColors = @[
                                (id)lightColor.CGColor,
                                (id)darkColor.CGColor
                                ];
    // 设置起点颜色对象与终点颜色对象
    CGFloat locations[] = {0,1};
    
    // 创建渐变色彩梯度对象
    CGGradientRef gradientRef = CGGradientCreateWithColors(colorRef, (__bridge CFArrayRef)gradientColors, locations);
    
    // 在上下文剪裁圆角边框
    CGRect insetRect = CGRectInset(rect, 2.0f, 2.0f);// 内边距2.0
    
    // 绘制外边框
    UIColor *strokeColor = [UIColor colorWithWhite:0.06 alpha:1.0f];
    // 设置路径内填充色
    CGContextSetFillColorWithColor(contextRef, strokeColor.CGColor);
    UIBezierPath *outPath = [UIBezierPath bezierPathWithRoundedRect:insetRect cornerRadius:6.0f];
    
    // 将路径添加到上下文
    CGContextAddPath(contextRef, outPath.CGPath);
    
    // 绘制阴影
    CGSize offset = CGSizeMake(0.f, 0.5f);
    CGContextSetShadowWithColor(contextRef, offset, 2.0f, [UIColor darkGrayColor].CGColor);
    // 先将将路径绘制到上下文
    CGContextDrawPath(contextRef, kCGPathFill);
    
    // 保存当前上下文状态
    CGContextSaveGState(contextRef);
    
    // 绘制内边距
    insetRect = CGRectInset(insetRect, 3.0f, 3.0f);
    
    UIBezierPath *insetPath = [UIBezierPath bezierPathWithRoundedRect:insetRect cornerRadius:4.0f];
    CGContextAddPath(contextRef, insetPath.CGPath);
    
    // 剪裁
    CGContextClip(contextRef);
    
    // 设置起点颜色与终点颜色
    CGPoint start = CGPointMake(CGRectGetMidX(insetRect), CGRectGetMaxY(insetRect));
    
    CGPoint end = CGPointMake(CGRectGetMidX(insetRect), CGRectGetMinY(insetRect));
    
    // 将渐变色绘制到按钮上
    CGContextDrawLinearGradient(contextRef, gradientRef, start, end, kCGGradientDrawsBeforeStartLocation);
    
    // 释放渐变色对象
    CGGradientRelease(gradientRef);
    
    // 释放颜色空间上下文
    CGColorSpaceRelease(colorRef);
    
    // 重置上下文栈顶状态，开始新的绘制
    CGContextRestoreGState(contextRef);
    
    // 绘制开始播放三角形与暂停正方形
    
    UIColor *fillColor = [UIColor colorWithWhite:0.9f alpha:1.0f];
    CGContextSetFillColorWithColor(contextRef, fillColor.CGColor);
    CGContextSetStrokeColorWithColor(contextRef, [fillColor darkerColor].CGColor);
    
    // 边长
    CGFloat side = 24.0;
    if (!self.selected) {   // 三角形
        CGContextSaveGState(contextRef);
        // 设置上下文矩阵的起点
        CGFloat tx = CGRectGetMidX(rect) - (side - 3) * 0.5;
        CGFloat ty = CGRectGetMidY(rect) - side * 0.5;
        CGContextTranslateCTM(contextRef, tx, ty);
        CGContextMoveToPoint(contextRef, 0.f, 0.f);
        CGContextAddLineToPoint(contextRef, 0, side);
        CGContextAddLineToPoint(contextRef, side, side * 0.5);
        CGContextClosePath(contextRef);
        CGContextDrawPath(contextRef, kCGPathFill);
        CGContextRestoreGState(contextRef);
    } else {        // 正方形
        CGContextSaveGState(contextRef);
        CGFloat tx = (CGRectGetWidth(rect) - side) * 0.5;
        CGFloat ty = (CGRectGetHeight(rect) - side) * 0.5;
        CGContextTranslateCTM(contextRef, tx, ty);
        CGRect rect = CGRectMake(0, 0, side, side);
        UIBezierPath *path = [UIBezierPath bezierPathWithRoundedRect:rect cornerRadius:2.0f];
        CGContextAddPath(contextRef, path.CGPath);
        CGContextDrawPath(contextRef, kCGPathFill);
        CGContextRestoreGState(contextRef);
    }

}


@end
