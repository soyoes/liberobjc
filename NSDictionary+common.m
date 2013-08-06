//
//  NSDictionary+common.m
//  Todos
//
//  Created by soyoes on 7/6/13.
//  Copyright (c) 2013 Liberhood. All rights reserved.
//

#import "NSDictionary+common.h"
#import "NSString+common.h"

@implementation  NSDictionary (common)
- (NSArray *) dictionaryFromJSONFile:(NSString*)file{
    NSString *filePath = [[NSBundle mainBundle] pathForResource:[file stringByDeletingPathExtension] ofType:@"json"];
    NSData* data = [NSData dataWithContentsOfFile:filePath];
    NSString *str = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    return (NSArray*) [str toJSON];
}
@end
