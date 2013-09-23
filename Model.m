//
//  Model.m
//  liberobjc
//
//  Created by soyoes on 9/10/13.
//  Copyright (c) 2013 Liberhood. All rights reserved.
//

#import "Model.h"

@implementation Model

- (id) initWithDictionary:(NSDictionary *)data{
    return nil;
}

- (void) save{

}

- (void) remove{

}

- (void) set:(NSString *)key value:(id)value{
    if(_changes==nil){
        _changes = [[NSMutableDictionary alloc] init];
    }
    _changes[key] = value;
}

@end
