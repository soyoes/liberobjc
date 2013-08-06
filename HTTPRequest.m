//
//  HTTPRequest.m
//  common
//
//  Created by @soyoes on 10/29/12.
//  Copyright (c) 2012 soyoes. All rights reserved.
//

#import "HTTPRequest.h"
#import "Categories.h"

@implementation HTTPRequest

- (id)init{
    self = [super init];
    self.raw = [[NSMutableData alloc] init];
    return self;
}

/**
 
 @example
    HTTPRequestHandler handler =^id (NSArray* o){
        NSLog(@"%@",o);
        return o;
    };
    [HTTPRequest get:@"http://soyoes.com/seal/api/orders" handler:handler];
 
 **/
+ (void)get:(NSString *)url handler:(HTTPRequestHandler)handler{
    NSURLRequest * request = [[NSMutableURLRequest alloc] initWithURL:[NSURL URLWithString:url]];
    HTTPRequest *req = [[HTTPRequest alloc] init];
    req.handler = handler;
    NSURLConnection * conn = [[NSURLConnection alloc] initWithRequest:request delegate:req startImmediately:NO];
    [conn start];
}

/**
 @example
     HTTPRequestHandler handler =^id (NSArray* o){
        NSLog(@"%@",o);
        return o;
     };
     [HTTPRequest post:@"http://soyoes.com/seal/api/orders/test" params:@{
         @"firstname":@"ゆ",
         @"lastname":@"そう",
         @"email":@"soyoes@gmail.com",
         @"zipcode":@"220-0041",
         @"address":@"横浜市西区戸部本町38-5",
         @"data":[UIImage imageNamed:@"ico_fb.png"]
     } handler:handler];
 
 **/

+ (void)post:(NSString *)url params:(NSDictionary*)params handler:(HTTPRequestHandler)handler{
    NSData *postData;
    NSString *queryStr = [HTTPRequest makeQueryStr:params];
    //NSLog(@"query = \n%@",queryStr);
    postData = [ NSData dataWithBytes:[queryStr UTF8String] length:strlen([queryStr UTF8String])];
    NSMutableURLRequest * request = [[NSMutableURLRequest alloc] initWithURL:[NSURL URLWithString:url]];
    [request setHTTPMethod: @"POST" ];
    [request setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"content-type"];
    [request setHTTPBody: postData ];
    HTTPRequest *req = [[HTTPRequest alloc] init];
    req.handler = handler;
    NSURLConnection *conn = [[NSURLConnection alloc] initWithRequest:request delegate:req startImmediately:NO];
    [conn start];
}

#pragma mark -- private

+ (NSString *) makeQueryStr:(NSDictionary *)param{
    NSMutableString *query = [NSMutableString stringWithFormat:@""];
    for (NSString *key in param) {
        NSString *format = [query length] == 0 ? @"%@=%@":@"&%@=%@";
        NSObject *v = [param valueForKey:key];
        NSString *value = [v isKindOfClass:[NSDictionary class]] || [v isKindOfClass:[NSArray class]] || [v isKindOfClass:[NSData class]] ||[v isKindOfClass:[UIImage class]] ?
                        [HTTPRequest pack:(NSArray *)v] : (NSString*)v;
        [query appendFormat:format, key, value];
    }
    return query;
}


+ (NSString *) pack:(NSObject *)data{
    if([data isKindOfClass:[UIImage class]]){
        //FIXME support JPG
        NSString *hex = [self packImage:(UIImage *)data];
        return hex;
    }else{
        NSData *byteData = nil;
        if ([data isKindOfClass:[NSDictionary class]] || [data isKindOfClass:[NSArray class]]) {
            NSString *json = [[NSString alloc] initWithData:[NSJSONSerialization dataWithJSONObject:data options:NSJSONWritingPrettyPrinted error:nil] encoding:NSUTF8StringEncoding ];
            byteData= [json dataUsingEncoding:NSUTF8StringEncoding];
        }else if([data isKindOfClass:[NSData class]]){
            byteData= (NSData *)data;
        }else{
            byteData= [(NSString*)data dataUsingEncoding:NSUTF8StringEncoding];
        }
        
        NSMutableString *hex = [NSMutableString string];
        unsigned char *bytes = (unsigned char *)[byteData bytes];
        char temp[3];
        for (int i = 0; i < [byteData length]; i++) {
            temp[0] = temp[1] = temp[2] = 0;
            (void)sprintf(temp, "%02x", bytes[i]);
            [hex appendString:[NSString stringWithUTF8String: temp]];
        }
        return hex;
    }
}

+ (NSString *)packImage :(UIImage *)image{
    NSData * imageData = UIImagePNGRepresentation(image);
    NSString *hex = [[imageData base64Encoding] stringByReplacingOccurrencesOfString:@"+" withString:@"%2B"];
    return hex;
}


#pragma mark -- NSURLConnection delegate

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSHTTPURLResponse *)response {
    [self.raw setLength:0];
    //NSLog(@"Response Code: %d", [response statusCode]);
    if (!([response statusCode] >= 200 && [response statusCode] < 300 && [response statusCode] != 204)) {
        NSLog(@"Failed to get Data.");
    }
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data {
    [self.raw appendData:data];
}

- (void) connectionDidFinishLoading: (NSURLConnection*) connection {
    //NSLog (@"HTTP Conn closed");
    NSError * err = nil;
    id res = [NSJSONSerialization JSONObjectWithData:self.raw options:NSJSONReadingMutableContainers error:&err];
    self.handler(res);
}


-(void) connection:(NSURLConnection *)connection didFailWithError: (NSError *)error {
    //[activityIndicator stopAnimating];
    NSLog (@"Connection Failed with Error");
    self.handler(nil);
}



@end
