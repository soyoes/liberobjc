//
//  UIView+UIView_liber.h
//  Todos
//
//  Created by soyoes on 9/20/13.
//  Copyright (c) 2013 Liberhood. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>

@interface UIView (liber)

-(void)clearPath:(CGMutablePathRef)path;


-(void)drawPoints:(float[])points size:(int)size
        fillColor:(UIColor*)fillColor strokeColor:(UIColor*)strokeColor strokeWidth:(float)strokeWidth;

@end
