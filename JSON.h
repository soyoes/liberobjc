//
//  JSON.h
//  Todos
//
//  Created by soyoes on 9/10/13.
//  Copyright (c) 2013 Liberhood. All rights reserved.
//

#import <Foundation/Foundation.h>

/*
@protocol JSON_methods<NSObject>

-(NSString *) getString;
-(int) getInt;
+(NSString *) someStaticMethod;

@end

typedef id<JSON_methods> JSON;
*/

typedef id JSON;
extern Class JSON_class;

__attribute__((constructor))
void JSON_initialize();

JSON JSON_alloc(id self, SEL _cmd);
JSON JSON_new(id self, SEL _cmd);
JSON JSON_init(JSON self, SEL _cmd);

/*
NSString *JSON_someStaticMethod(id self, SEL _cmd);
int JSON_getInt(JSON self, SEL _cmd);
NSString *JSON_getString(JSON self, SEL _cmd);
*/