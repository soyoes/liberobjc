//
//  Model.h
//  liberobjc
//
//  Created by soyoes on 9/10/13.
//  Copyright (c) 2013 Liberhood. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Model : NSObject

@property(nonatomic, assign) id ID;
@property(nonatomic, retain) NSMutableDictionary *changes;

- (id) initWithDictionary:(NSDictionary *)data;

- (void) save;
- (void) remove;
- (void) set:(NSString *)key value:(id)value;


@end

__attribute__((constructor))
void model_set(Model* self, SEL _cmd);
