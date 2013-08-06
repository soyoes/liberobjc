//
//  UIImage+common.h
//  common
//
//  Created by Tsai on 11/16/12.
//  Copyright (c) 2012 soyoes. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIImage (common)
- (UIImage *)imageAtRect:(CGRect)rect;
+ (UIImage *)imageWithLabel:(UILabel *)label scale:(float)scale;
- (UIImage *)imageWithLabelAtPoint:(UILabel *)label point:(CGPoint)pnt;
- (UIImage *)imageWithBorder:(float)borderWidth color:(UIColor*)borderColor;
- (UIImage *)imageByScalingProportionallyToMinimumSize:(CGSize)targetSize;
- (UIImage *)imageByScalingProportionallyToSize:(CGSize)targetSize;
- (UIImage *)imageByScalingToSize:(CGSize)targetSize;
- (UIImage *)imageRotatedByRadians:(CGFloat)radians;
- (UIImage *)imageRotatedByDegrees:(CGFloat)degrees;
- (UIImage *)imageWithCorner:(CGFloat)radius toBounds:(CGRect)bounds borderWidth:(float)borderWidth borderColor:(CGColorRef)borderColor;
- (UIImage*) merge:(UIImage*)thumb;


@end
