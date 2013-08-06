//
//  NSString+common.h
//  iSeal
//
//  Created by @soyoes on 10/30/12.
//  Copyright (c) 2012 Midaslink. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSString (common)

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
