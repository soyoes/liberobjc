//
//  UIVerticalLabel.m
//  common
//
//  Created by Tsai on 11/20/12.
//  Copyright (c) 2012 soyoes. All rights reserved.
//

#import "UIVerticalLabel.h"
#import "NSString+common.h"

@implementation UIVerticalLabel

@synthesize text = _text;
@synthesize textColor = _textColor;
@synthesize isVertical = _isVertical;

-(id) initWithText:(NSString*)str font:(UIFont *)f center:(CGPoint)c margin:(int)margin{

    NSArray * lines = [str lines];
    
    float lineW=0, lineH=0, charW=0;
    
    int maxChars=0;
    
    for (NSString *line in lines) {
        CGSize size =  [line sizeWithFont:f];
        lineH = lineH<size.height ? size.height : lineH;
        lineW = lineW<size.width ? size.width : lineW;
        int len = [line length];
        maxChars = maxChars<len ? len : maxChars;
        charW = size.width/len > charW ? size.width/len : charW;
    }
    int lineCnt = [lines count];
    lineW = charW>=lineH ? lineW + 2*margin : maxChars * lineH + 2*margin;
    CGSize size = CGSizeMake((lineH)*lineCnt+2*margin, lineW);

    self = [super initWithFrame:CGRectMake(c.x-size.width/2, c.y-size.height/2, size.width, size.height)];
    self.isVertical = YES;
    self.text = str;
    self.lines = lines;
    self.margin = margin;
    self.font = f;
    self.lineBreakMode = NSLineBreakByWordWrapping;
    self.numberOfLines = 0;
    self.textColor = [UIColor blackColor];
    self.backgroundColor = [UIColor clearColor];

    return self;
}

- (void)drawRect:(CGRect)rect{
    [self drawText];
}

-(void)drawTextInRect:(CGRect)rect{
    [self drawText];
}


-(void)drawText{
    CGSize size = self.bounds.size;
    
    NSArray *lines = [self lines];
    int lineCnt = [lines count];
    CGContextSetFillColorWithColor(UIGraphicsGetCurrentContext(), _textColor.CGColor);
    
    if(self.isVertical){
        float lineWidth = (size.width-2*self.margin) / lineCnt;
        float lineHeight = (size.height);
        for (int i = 0;i<lineCnt;i++) {
            NSString *line = lines[i];
            CGRect rect = CGRectMake(self.margin+(lineCnt - i -1)*lineWidth, self.margin, lineWidth-self.margin, lineHeight-self.margin);
            [line drawInRect:rect withFont:self.font lineBreakMode:NSLineBreakByCharWrapping];
        }
    }else{
        float lineWidth = (size.width);
        float lineHeight = (size.height- 2*self.margin)/ lineCnt;
        for (int i = 0;i<lineCnt;i++) {
            NSString *line = lines[i];
            CGRect rect = CGRectMake(self.margin, self.margin+lineHeight*i, lineWidth-self.margin, lineHeight-self.margin);
            [line drawInRect:rect withFont:self.font lineBreakMode:NSLineBreakByCharWrapping];
        }
    }

}

-(void) setTextColor:(UIColor *)textColor{
    _textColor = textColor;
    [self setNeedsDisplay];
}


-(void)setIsVertical:(BOOL)isVertical{
    if (_isVertical!=isVertical) { // ver 2 hor
        float lineW=0, lineH=0 , charW=0;
        int maxChars=0;
        for (NSString *line in self.lines) {
            CGSize size =  [line sizeWithFont:self.font];
            lineH = lineH<size.height ? size.height : lineH;
            lineW = lineW<size.width ? size.width : lineW;
            int len = [line length];
            maxChars = maxChars<len ? len : maxChars;
            charW = size.width/len > charW ? size.width/len : charW;
        }
        int lineCnt = [self.lines count];
        lineW = charW>=lineH||isVertical==NO ? lineW + 2*self.margin : maxChars * lineH + 2*self.margin;
        CGSize size = isVertical ? CGSizeMake((lineH) * lineCnt+ 2*self.margin, lineW):
            CGSizeMake(lineW, (lineH) * lineCnt+ 2*self.margin);
        self.frame = CGRectMake(0, 0, size.width, size.height);
        [self setNeedsDisplay];
    }
    _isVertical = isVertical;
}


-(void) setText:(NSString *)text{
    _text = text;
    self.lines = [_text lines];
    float lineW=0, lineH=0, charW = 0;
    int maxChars=0;
    for (NSString *line in self.lines) {
        CGSize size =  [line sizeWithFont:self.font];
        lineH = lineH<size.height ? size.height : lineH;
        lineW = lineW<size.width ? size.width : lineW;
        int len = [line length];
        maxChars = maxChars<len ? len : maxChars;
        charW = size.width/len > charW ? size.width/len : charW;
    }
    int lineCnt = [self.lines count];
    lineW = charW>=lineH || _isVertical==NO ? lineW + 2*self.margin : maxChars * lineH + 2*self.margin;
    CGSize size = _isVertical ? CGSizeMake((lineH) * lineCnt+ 2*self.margin, lineW):
        CGSizeMake(lineW, (lineH) * lineCnt+ 2*self.margin);
    self.frame = CGRectMake(0, 0, size.width, size.height);
    [self setNeedsDisplay];
}



@end
