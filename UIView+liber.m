//
//  UIView+UIView_liber.m
//  Todos
//
//  Created by soyoes on 9/20/13.
//  Copyright (c) 2013 Liberhood. All rights reserved.
//

#import "UIView+liber.h"
#import <QuartzCore/QuartzCore.h>

@implementation UIView (liber)


-(void)clearPath:(CGMutablePathRef)path{
    CGContextRef context =UIGraphicsGetCurrentContext();
    CGContextSetAllowsAntialiasing(context, YES);
    CGContextSaveGState(context);
    
    //Very important!!!!
    CGContextSetBlendMode(context, kCGBlendModeClear);
    CGContextSetFillColorWithColor(context, [UIColor clearColor].CGColor);

    CGContextAddPath(context, path);
    CGContextFillPath(context);

    CGContextRestoreGState(context);
}


-(void)drawPoints:(float[])points size:(int)size
        fillColor:(UIColor*)fillColor strokeColor:(UIColor*)strokeColor strokeWidth:(float)strokeWidth{
    CGContextRef context =UIGraphicsGetCurrentContext();
    CGContextSetAllowsAntialiasing(context, YES);
    CGContextSaveGState(context);
    
    CGContextBeginPath(context);
    
    CGContextMoveToPoint(context,points[0],points[1]);
    size *= 2;
    for (int i = 2; i < size; i+=2) {
        CGContextAddLineToPoint(context, points[i], points[i+1]);
    }
    CGContextAddLineToPoint(context,points[0],points[1]);
    CGContextClosePath(context);
    
    if (fillColor!=nil){
        CGContextSetFillColorWithColor(context, fillColor.CGColor);
        CGContextFillPath(context);
    }
    if (strokeColor!=nil && strokeWidth>0){
        CGContextSetStrokeColorWithColor(context, strokeColor.CGColor);
        CGContextStrokePath(context);
    }
    CGContextRestoreGState(context);
}

@end
