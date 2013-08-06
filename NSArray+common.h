//
//  NSArray+common.h
//  common
//
//  Created by Soyoes on 11/6/12.
//  Copyright (c) 2012 soyoes. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSArray (common)
- (double) sum:(NSString *)key;
- (NSArray *) arrayFromJSONFile:(NSString*)file;

@end


@interface NSMutableArray (common)
- (double) sum:(NSString *)key;
- (NSMutableArray*) initWithFill:(int)length value:(id)value rows:(int)rows;
@end