#import "Categories.h"

@implementation NSArray (liber)
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


@implementation NSMutableArray (liber)
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


@implementation  NSDictionary (liber)
- (NSArray *) dictionaryFromJSONFile:(NSString*)file{
    NSString *filePath = [[NSBundle mainBundle] pathForResource:[file stringByDeletingPathExtension] ofType:@"json"];
    NSData* data = [NSData dataWithContentsOfFile:filePath];
    NSString *str = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    return (NSArray*) [str toJSON];
}
@end



@implementation NSData (liber)

static char base64[] = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/";
- (NSString *)base64Encoding {
    if ([self length] == 0)
        return @"";
    char* characters = malloc((([self length] + 2) / 3) *4);
    if (characters == NULL)
        return nil;
    NSUInteger length = 0;
    NSUInteger i = 0;
    while (i < [self length]) {
        char buffer[3] = {0,0,0};
        short bufferLength = 0;
        while (bufferLength < 3 && i < [self length])
            buffer[bufferLength++] = ((char *)[self bytes])[i++];
        // Encode the bytes in the buffer to four characters, including padding "=" characters if necessary.
        characters[length++] = base64[(buffer[0] & 0xFC) >> 2];
        characters[length++] = base64[((buffer[0] & 0x03) << 4) | ((buffer[1] & 0xF0) >> 4)];
        if (bufferLength > 1)
            characters[length++] = base64[((buffer[1] & 0x0F) << 2) | ((buffer[2] & 0xC0) >> 6)];
        else
            characters[length++] = '=';
        
        if (bufferLength > 2)
            characters[length++] = base64[buffer[2] & 0x3F];
        else characters[length++] = '=';
    }
    return [[NSString alloc] initWithBytesNoCopy:characters length:length encoding:NSASCIIStringEncoding freeWhenDone:YES];
}

@end



@implementation NSString (liber)


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



CGFloat DegreesToRadians(CGFloat degrees) {return degrees * M_PI / 180;};
CGFloat RadiansToDegrees(CGFloat radians) {return radians * 180/M_PI;};
@implementation UIImage (liber)


-(UIImage *)imageAtRect:(CGRect)rect{
    CGImageRef imageRef = CGImageCreateWithImageInRect([self CGImage], rect);
    UIImage* subImage = [UIImage imageWithCGImage: imageRef];
    CGImageRelease(imageRef);
    return subImage;
}

+ (UIImage *)imageWithLabel:(UILabel *)label scale:(float)scale{
    CGRect bounds = CGRectMake(0,0,label.frame.size.width*scale, label.frame.size.height * scale);
    UIGraphicsBeginImageContext(bounds.size);
    //NSLog(@"fontsize=%f",label.font.pointSize);
    
    UIFont *f = [UIFont fontWithName:label.font.fontName size:label.font.pointSize*scale];
    /*
    
    if([label isKindOfClass:[UIVerticalLabel class]]){
        UIVerticalLabel *lb = [[UIVerticalLabel alloc] initWithText:label.text font:f center:CGPointMake(0, 0) margin:5];
        lb.isVertical = ((UIVerticalLabel *)label).isVertical;
        lb.textColor = label.textColor;
        lb.bounds = bounds;
        
        [lb drawTextInRect:bounds];
    }else{
    */
        UILabel *lb = [[UILabel alloc] initWithFrame:bounds];
        lb.text = label.text;
        lb.font = f;
        lb.textColor = label.textColor;
        [lb drawTextInRect:bounds];
    //}
    UIImage *img= UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return img;
}

- (UIImage *)imageWithLabelAtPoint:(UILabel *)label point:(CGPoint)pnt{
    UIGraphicsBeginImageContext(self.size);
    [self drawAtPoint:CGPointMake(0, 0)];
    
    CGRect textRect = CGRectMake(pnt.x, pnt.y, label.frame.size.width,label.frame.size.height);
    if(label.backgroundColor != [UIColor clearColor]){
        CGContextRef context = UIGraphicsGetCurrentContext();
        CGContextSetFillColorWithColor(context, label.backgroundColor.CGColor);
        CGContextFillRect(context, textRect);
    }
    
    [label drawTextInRect:textRect];
    UIImage *img= UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return img;
}

- (UIImage *)imageWithBorder:(float)borderWidth color:(UIColor*)borderColor{
    CGRect rect = CGRectMake(0, 0, self.size.width+2*borderWidth,self.size.height+2*borderWidth);
    UIGraphicsBeginImageContext(rect.size);
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetFillColorWithColor(context, borderColor.CGColor);
    CGContextFillRect(context, rect);
    [self drawAtPoint:CGPointMake(borderWidth, borderWidth)];
    UIImage *img= UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return img;
}

- (UIImage *)imageByScalingProportionallyToMinimumSize:(CGSize)targetSize {
    
    UIImage *sourceImage = self;
    UIImage *newImage = nil;
    
    CGSize imageSize = sourceImage.size;
    CGFloat width = imageSize.width;
    CGFloat height = imageSize.height;
    
    CGFloat targetWidth = targetSize.width;
    CGFloat targetHeight = targetSize.height;
    
    CGFloat scaleFactor = 0.0;
    CGFloat scaledWidth = targetWidth;
    CGFloat scaledHeight = targetHeight;
    
    CGPoint thumbnailPoint = CGPointMake(0.0,0.0);
    
    if (CGSizeEqualToSize(imageSize, targetSize) == NO) {
        
        CGFloat widthFactor = targetWidth / width;
        CGFloat heightFactor = targetHeight / height;
        
        if (widthFactor > heightFactor)
            scaleFactor = widthFactor;
        else
            scaleFactor = heightFactor;
        
        scaledWidth  = width * scaleFactor;
        scaledHeight = height * scaleFactor;
        
        // center the image
        
        if (widthFactor > heightFactor) {
            thumbnailPoint.y = (targetHeight - scaledHeight) * 0.5;
        } else if (widthFactor < heightFactor) {
            thumbnailPoint.x = (targetWidth - scaledWidth) * 0.5;
        }
    }
    
    
    // this is actually the interesting part:
    
    UIGraphicsBeginImageContext(targetSize);
    
    CGRect thumbnailRect = CGRectZero;
    thumbnailRect.origin = thumbnailPoint;
    thumbnailRect.size.width  = scaledWidth;
    thumbnailRect.size.height = scaledHeight;
    
    [sourceImage drawInRect:thumbnailRect];
    
    newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    if(newImage == nil) NSLog(@"could not scale image");
    
    
    return newImage ;
}


- (UIImage *)imageByScalingProportionallyToSize:(CGSize)targetSize {
    
    UIImage *sourceImage = self;
    UIImage *newImage = nil;
    
    CGSize imageSize = sourceImage.size;
    CGFloat width = imageSize.width;
    CGFloat height = imageSize.height;
    
    CGFloat targetWidth = targetSize.width;
    CGFloat targetHeight = targetSize.height;
    
    CGFloat scaleFactor = 0.0;
    CGFloat scaledWidth = targetWidth;
    CGFloat scaledHeight = targetHeight;
    
    CGPoint thumbnailPoint = CGPointMake(0.0,0.0);
    
    if (CGSizeEqualToSize(imageSize, targetSize) == NO) {
        
        CGFloat widthFactor = targetWidth / width;
        CGFloat heightFactor = targetHeight / height;
        
        if (widthFactor < heightFactor)
            scaleFactor = widthFactor;
        else
            scaleFactor = heightFactor;
        
        scaledWidth  = width * scaleFactor;
        scaledHeight = height * scaleFactor;
        
        // center the image
        
        if (widthFactor < heightFactor) {
            thumbnailPoint.y = (targetHeight - scaledHeight) * 0.5;
        } else if (widthFactor > heightFactor) {
            thumbnailPoint.x = (targetWidth - scaledWidth) * 0.5;
        }
    }
    
    
    // this is actually the interesting part:
    
    UIGraphicsBeginImageContext(targetSize);
    
    CGRect thumbnailRect = CGRectZero;
    thumbnailRect.origin = thumbnailPoint;
    thumbnailRect.size.width  = scaledWidth;
    thumbnailRect.size.height = scaledHeight;
    
    [sourceImage drawInRect:thumbnailRect];
    
    newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    if(newImage == nil) NSLog(@"could not scale image");
    
    
    return newImage ;
}


- (UIImage *)imageByScalingToSize:(CGSize)targetSize {
    
    UIImage *sourceImage = self;
    UIImage *newImage = nil;
    
    //   CGSize imageSize = sourceImage.size;
    //   CGFloat width = imageSize.width;
    //   CGFloat height = imageSize.height;
    
    CGFloat targetWidth = targetSize.width;
    CGFloat targetHeight = targetSize.height;
    
    //   CGFloat scaleFactor = 0.0;
    CGFloat scaledWidth = targetWidth;
    CGFloat scaledHeight = targetHeight;
    
    CGPoint thumbnailPoint = CGPointMake(0.0,0.0);
    
    // this is actually the interesting part:
    
    UIGraphicsBeginImageContext(targetSize);
    
    CGRect thumbnailRect = CGRectZero;
    thumbnailRect.origin = thumbnailPoint;
    thumbnailRect.size.width  = scaledWidth;
    thumbnailRect.size.height = scaledHeight;
    
    [sourceImage drawInRect:thumbnailRect];
    
    newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    if(newImage == nil) NSLog(@"could not scale image");
    
    
    return newImage ;
}


- (UIImage *)imageRotatedByRadians:(CGFloat)radians{
    return [self imageRotatedByDegrees:RadiansToDegrees(radians)];
}

- (UIImage *)imageRotatedByDegrees:(CGFloat)degrees
{
    // calculate the size of the rotated view's containing box for our drawing space
    UIView *rotatedViewBox = [[UIView alloc] initWithFrame:CGRectMake(0,0,self.size.width, self.size.height)];
    CGAffineTransform t = CGAffineTransformMakeRotation(DegreesToRadians(degrees));
    rotatedViewBox.transform = t;
    CGSize rotatedSize = rotatedViewBox.frame.size;
    
    // Create the bitmap context
    UIGraphicsBeginImageContext(rotatedSize);
    CGContextRef bitmap = UIGraphicsGetCurrentContext();
    
    // Move the origin to the middle of the image so we will rotate and scale around the center.
    CGContextTranslateCTM(bitmap, rotatedSize.width/2, rotatedSize.height/2);
    
    //   // Rotate the image context
    CGContextRotateCTM(bitmap, DegreesToRadians(degrees));
    
    // Now, draw the rotated/scaled image into the context
    CGContextScaleCTM(bitmap, 1.0, -1.0);
    CGContextDrawImage(bitmap, CGRectMake(-self.size.width / 2, -self.size.height / 2, self.size.width, self.size.height), [self CGImage]);
    
    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return newImage;
    
}

- (UIImage *)imageWithCorner:(CGFloat)radius toBounds:(CGRect)bounds borderWidth:(float)borderWidth borderColor:(CGColorRef)borderColor{
    UIGraphicsBeginImageContextWithOptions(bounds.size, NO, 1.0);
    
    [[UIBezierPath bezierPathWithRoundedRect:bounds
                                cornerRadius:radius] addClip];
    if(borderWidth>0){
        CGContextRef context = UIGraphicsGetCurrentContext();
        CGContextSetFillColorWithColor(context, borderColor);
        CGContextFillRect(context, bounds);
        bounds = CGRectMake(borderWidth, borderWidth, bounds.size.width-2*borderWidth, bounds.size.height-2*borderWidth);
        [[UIBezierPath bezierPathWithRoundedRect:bounds
                                    cornerRadius:radius] addClip];
    }
    
    [self drawInRect:bounds];
    UIImage *img = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return img;
}

- (UIImage*) merge:(UIImage*)thumb{
    UIGraphicsBeginImageContext(self.size);
    
    [self drawAtPoint:CGPointMake(0, 0)];
    [thumb drawAtPoint:CGPointMake(0, 0)];
    
    UIImage* result = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return result;
}


@end

