//
//  Categories.h
//
//  Created by @soyoes on 10/30/12.
//  Copyright (c) 2012 Liberhood. All rights reserved.
//


#import <UIKit/UIKit.h>

#ifndef common_Categories_h
#define common_Categories_h

@interface NSArray (liber)
- (double) sum:(NSString *)key;
- (NSArray *) arrayFromJSONFile:(NSString*)file;
//- (BOOL) same;

@end


@interface NSMutableArray (liber)
//- (BOOL) same;
- (double) sum:(NSString *)key;
- (NSMutableArray*) initWithFill:(int)length value:(id)value rows:(int)rows;
@end


@interface NSDictionary (liber)
- (NSDictionary *) dictionaryFromJSONFile:(NSString*)file;

@end


@interface NSData (liber)
- (NSString *)base64Encoding;
@end


@interface NSString (liber)
- (BOOL)isValidEmail;
- (BOOL)isValidMobileNumberOfJP;
- (BOOL)isValidZipcodeOfJP;
- (BOOL)contains:(NSString *)string;
- (BOOL)contains:(NSString *)string options:(NSStringCompareOptions) options;
- (NSString *)regexpReplace:(NSString *)pattern replace:(NSString*)replace;
- (UIColor*) colorValue;
- (NSArray *) lines;
- (float) sizeToFit:(CGSize)size font:(NSString*)fontName;
- (id)toJSON;
@end


@interface UIImage(liber)
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


#endif
