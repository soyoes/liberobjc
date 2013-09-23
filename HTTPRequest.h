//
//  HTTPRequest.h
//  common
//
//  Created by @soyoes on 10/29/12.
//  Copyright (c) 2012 soyoes. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef id(^HTTPRequestHandler)(id);

@interface HTTPRequest : NSObject <NSURLConnectionDelegate,NSURLConnectionDataDelegate>

@property (nonatomic, retain)   NSMutableData       *raw;
@property (nonatomic, copy)     HTTPRequestHandler  handler;

+ (void)get:(NSString *)url handler:(HTTPRequestHandler)handler;
+ (void)post:(NSString *)url params:(NSDictionary*)params handler:(HTTPRequestHandler)handler;

//+ (NSString *)packImage :(UIImage *)image;

@end


