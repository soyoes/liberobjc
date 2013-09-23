//
//  NSArray+common.m
//  common
//
//  Created by Soyoes on 11/6/12.
//  Copyright (c) 2012 soyoes. All rights reserved.
//

#import "NSArray+common.h"
#import "NSString+common.h"

@implementation NSArray (common)
- (double) sum:(NSString *)key{
    double res = 0;
    for (id ele in self) {
        if(key!=nil ){
            if([ele isKindOfClass:[NSDictionary class]] && [[(NSDictionary*)ele allKeys] containsObject:key] ){
                res += [ele[key] doubleValue];
            }
        }else{
            if([ele isKindOfClass:[NSNumber class]]){
                res += [ele doubleValue];
            }
        }
    }
    return res;
}
- (NSArray *) arrayFromJSONFile:(NSString*)file{
    NSString *str = [[NSString alloc] initWithContentsOfFile:file encoding:NSUTF8StringEncoding error:NULL];
    return (NSArray*) [str toJSON];
}

- (BOOL) same{
    id prev = nil;
    for (id o in self) {
        if (prev==nil) {
            prev = o;
        }
        if(![prev isEqual:o]){
            return NO;
        }
        prev = o;
    }
    return YES;
}

@end


@implementation NSMutableArray (common)
- (double) sum:(NSString *)key{
    NSArray *arr = [NSArray arrayWithArray:self];
    return [arr sum:key];
}
- (NSMutableArray*) initWithFill:(int)length value:(id)value rows:(int)rows{
    if(rows>1){
        NSMutableArray *element = [[NSMutableArray alloc] initWithFill:length value:value rows:1];
        return [[NSMutableArray alloc] initWithFill:length value:[NSMutableArray arrayWithArray:element] rows:1];
    }else{
        NSMutableArray *arr = [NSMutableArray arrayWithCapacity:length];
        for (int i=0; i<length; i++) {
            [arr addObject:value];
        }
        return arr;
    }
}
- (BOOL) same{
    NSArray *arr = [NSArray arrayWithArray:self];
    return [arr same];
}

@end
