//
//  NSString+common.m
//  iSeal
//
//  Created by @soyoes on 10/30/12.
//  Copyright (c) 2012 Midaslink. All rights reserved.
//

#import "NSString+common.h"

@implementation NSString (common)


- (BOOL)isValidEmail{
    NSString *emailRegex = @"[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,4}";
    NSPredicate *emailTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", emailRegex];
    return [emailTest evaluateWithObject:self];
}

-(BOOL) isValidMobileNumberOfJP{
    NSString *regex = @"0[0-9]{2}[-]{0,1}[0-9]{4}[-]{0,1}[0-9]{4}";
    NSPredicate *test = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", regex];
    return [test evaluateWithObject:self];
}

-(BOOL) isValidZipcodeOfJP{
    NSString *regex = @"[0-9]{3}[-]{0,1}[0-9]{4}";
    UIButton *btn = [UIButton buttonWithType:UIButtonTypeContactAdd];
    NSPredicate *test = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", regex];
    return [test evaluateWithObject:self];
}

-(NSArray *) lines{
    unsigned length = [self length];
    unsigned paraStart = 0, paraEnd = 0, contentsEnd = 0;
    NSMutableArray *array = [NSMutableArray array];
    NSRange currentRange;
    while (paraEnd<length){
        [self getParagraphStart:&paraStart end:&paraEnd
                      contentsEnd:&contentsEnd forRange:NSMakeRange(paraEnd, 0)];
        currentRange = NSMakeRange(paraStart, contentsEnd - paraStart);
        [array addObject:[self substringWithRange:currentRange]];
    }
    return array;
}

-(UIColor*)colorValue{
    if([self contains:@","]){
        NSString *target = [self regexpReplace:@"(rgb\(|\))" replace:@""];
        NSArray *rgbs = [target componentsSeparatedByString:@","];
        if([rgbs count]>=3){
            float alpha = [rgbs count]==4 ? [rgbs[3] floatValue]:1;
            return [UIColor colorWithRed:[rgbs[0] floatValue]/255
                                     green:[rgbs[0] floatValue]/255 blue:[rgbs[0] floatValue]/255 alpha:alpha];
        }
        return [UIColor blackColor];
    }else if([self contains:@"#"]){
        assert('#' == [self characterAtIndex:0]);
        
        NSString *redHex = [NSString stringWithFormat:@"0x%@", [self substringWithRange:NSMakeRange(1, 2)]];
        NSString *greenHex = [NSString stringWithFormat:@"0x%@", [self substringWithRange:NSMakeRange(3, 2)]];
        NSString *blueHex = [NSString stringWithFormat:@"0x%@", [self substringWithRange:NSMakeRange(5, 2)]];
        NSString *alphaHex = ([self length]==9)?[NSString stringWithFormat:@"0x%@", [self substringWithRange:NSMakeRange(7, 2)]]:@"FF";
        
        unsigned redInt = 0;
        NSScanner *rScanner = [NSScanner scannerWithString:redHex];
        [rScanner scanHexInt:&redInt];
        
        unsigned greenInt = 0;
        NSScanner *gScanner = [NSScanner scannerWithString:greenHex];
        [gScanner scanHexInt:&greenInt];
        
        unsigned blueInt = 0;
        NSScanner *bScanner = [NSScanner scannerWithString:blueHex];
        [bScanner scanHexInt:&blueInt];
        
        unsigned alpha = 0;
        NSScanner *aScanner = [NSScanner scannerWithString:alphaHex];
        [aScanner scanHexInt:&alpha];
        return [UIColor colorWithRed:(float)redInt/255 green:(float)greenInt/255 blue:(float)blueInt/255 alpha:(float)alpha/255];
    }else
        return [UIColor clearColor];
}
- (NSString *)regexpReplace:(NSString *)pattern replace:(NSString*)replace{
    NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:pattern options:NSRegularExpressionCaseInsensitive error:nil];
    return [regex stringByReplacingMatchesInString:self options:0 range:NSMakeRange(0, [self length]) withTemplate:replace];
}
- (BOOL)contains:(NSString *)string
               options:(NSStringCompareOptions)options {
    NSRange rng = [self rangeOfString:string options:options];
    return rng.location != NSNotFound;
}

- (BOOL)contains:(NSString *)string {
    return [self contains:string options:0];
}

-(id)toJSON{
    NSString *str =[self regexpReplace:@"\n" replace:@""];
    NSData *data = [str dataUsingEncoding:NSUTF8StringEncoding];
    return [NSJSONSerialization JSONObjectWithData:data options: NSJSONReadingMutableContainers error: nil];
}

- (float) sizeToFit:(CGSize)size font:(NSString*)fontName{
    float baseFont=7;
    float fsize = baseFont;
    CGFloat step=1.0f;
    
    BOOL found=NO;
    while (!found) {
        UIFont * f =[UIFont fontWithName:fontName size:fsize];
        CGSize tSize=[self sizeWithFont:f constrainedToSize:size lineBreakMode:NSLineBreakByWordWrapping];
        if(tSize.height+f.lineHeight>size.height){
            found=YES;
        }else {
            fsize+=step;
        }
    }
    return fsize;
};


@end
