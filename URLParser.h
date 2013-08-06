//
//  URLParser.h
//  common
//
//  Created by Tsai on 11/13/12.
//  Copyright (c) 2012 soyoes. All rights reserved.
//

#import <Foundation/Foundation.h>
@interface URLParser : NSObject 
@property (nonatomic, retain) NSArray *variables;
- (id)initWithURLString:(NSString *)url;
- (NSString *)valueForVariable:(NSString *)varName;

@end
