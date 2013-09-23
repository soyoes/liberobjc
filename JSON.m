//
//  JSON.m
//  Todos
//
//  Created by soyoes on 9/10/13.
//  Copyright (c) 2013 Liberhood. All rights reserved.
//

#import "JSON.h"
#import <objc/runtime.h>


static Class staticClass;
Class JSON_class;


//void JSON_initialize(void);
__attribute__((constructor))
void JSON_initialize(){
    JSON_class = objc_allocateClassPair([NSObject class], "JSON", 0);
    objc_registerClassPair(JSON_class);
    
    staticClass = object_getClass(JSON_class);
    
    class_addMethod(JSON_class, @selector(init),      (IMP)JSON_init,        "@@:");
    
    class_addMethod(staticClass, @selector(alloc),            (IMP)JSON_alloc, "@@:");
    class_addMethod(staticClass, @selector(new),              (IMP)JSON_new,   "@@:");
    
    /*
    class_addMethod(JSON_class, @selector(getString), (IMP)JSON_getString,   "@@:");
    class_addMethod(JSON_class, @selector(getInt),    (IMP)JSON_getInt,      "i@:");
    class_addMethod(staticClass, @selector(someStaticMethod), (IMP)JSON_someStaticMethod, "@@:");
    */
}

JSON JSON_alloc(id self, SEL _cmd){
    return (JSON) [[NSClassFromString(@"JSON_class") alloc] init];
    //return (JSON) class_createInstance(JSON_class, sizeof(JSON_t) - sizeof(Class));
}

JSON JSON_new(id self, SEL _cmd){
    return (JSON) [[JSON_class alloc] init];
}

NSString *JSON_someStaticMethod(id self, SEL _cmd){
    return @"Some Static Method";
}

JSON JSON_init(JSON self, SEL _cmd){
    struct objc_super super = { .receiver = self, .super_class = [NSObject class] };
    self = (JSON) objc_msgSendSuper(&super, _cmd);
    return self;
}
