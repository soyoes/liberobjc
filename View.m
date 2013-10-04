//
//  View.m
//  liberobjc
//
//  Created by soyoes on 7/3/13.
//  Copyright (c) 2013 soyoes. All rights reserved.
//

/*
 TASK
 
 * align(layer.contentsGravity?)
 * vbox auto width, hbox, auto width/height
 * text edit. add new TextField to this view dynamically
 * text edit place holder,
 * border double, border dash
 
 * layer.doubleSided (CATransformLayer)
 * layer.backgroundFilters (CIFilter)
 * animate
 
 * blur / mosaic ... effects on background image.
 
 + layerClass   -> core animation layer
 layer CALayer :: Appearance properties
 */

#import "Categories.h"
#import "View.h"
#import <objc/runtime.h>
#import <QuartzCore/QuartzCore.h>
#include <math.h>

#define logRect(name,rect) (NSLog(@"--\nRECT:%@ = (%f,%f), (%f,%f) \n--",(name),(rect.origin.x),(rect.origin.y),(rect.size.width),(rect.size.height)))
#define logSize(name,size) (NSLog(@"--\nRECT:%@ = (%f,%f) \n--",(name),(size.width),(size.height)))
#define logPoint(name,p) (NSLog(@"--\nRECT:%@ = (%f,%f) \n--",(name),(p.x),(p.y)))

#define _styles @[@"shadow", @"border",@"borderLeft",@"borderTop",@"borderRight",@"borderBottom", @"bgcolor", @"rotate", @"scale", @"flip", @"alpha", @"font", @"fontSize", @"color", @"textAlign", @"align", @"padding", @"paddingLeft",@"paddingTop", @"paddingRight",@"paddingBottom",@"outline"]
#define _events @[@"tap", @"pinch", @"rotation", @"swipe", @"pan", @"longpress"]

#define radians(degrees) (degrees * M_PI/180)

#ifndef STYLE_SHEET_FILE
    #define STYLE_SHEET_FILE "styles.json"
#endif

/*
struct StyleRef {
    int x;
    int y;
    StyleRef():x(1),y(1) {}
};
*/


/*
 @opts
    x,y,w,h : float
    alpha   : 0~1
    shadow  : 
        //format : x y radius colorStr opacity
    border
        //format :width color/image corner-radius
        //format(use image) : 1 myline.png 4        //dash|dot ...
        //format(use rgbcolor) : 1 213,204,222
        //format(use hexcolor) : 1 #CCFF33 2
    borderLeft
    borderRight
    borderTop
    borderBottom
    outline: 
        //format: width space color ...  1 1 #333333
 
    paddingLeft, paddingTop, paddingRight, paddingBottom    
        //works with label only
 
    bgcolor
        //format(use rgbcolor) : 213,204,222,1.0
        //format(use rgbcolor) : 213,204,222
        //format(use hexcolor) : #336699CC //CC=alpha
        //format(use gradient) : #336699 #33CCFF
        //format(use gradient + location) : #336699:0 #3399CC:0.5 #33CCFF:1
    rotate
        //format : int 30,60,90 ....
    scale
        //format : xScale,yScale
    flip
        //format : 'H' | 'V'
 
    space : use in parent, define space between child
        // int
 
    padding :
        // int padding
 
    font: 
        //format : fontsize,fontname
 
    color: text color
        //color format @see bgcolor,
 
    wrapped:  wrap text to multiple row , default=true
        //format : false
 
    truncate:  truncate text to ..., default = no truncate
        //format : true
 
    editable: TODO
        //format : true, if clicked, add dynamical textfield automatically
 
    css:class name in styles.json
 
 
 */


static NSDictionary * _stylesheets;


#pragma mark - functions

View* box(ViewTypes type, id subs, Styles styles, UIView*target){
    View *v = [[View alloc] initWithType:type styles:styles target:nil];
    if(subs!=nil){
        if([subs isKindOfClass:[View class]]){
            [(View*)subs appendTo:v];
        }else if([subs isKindOfClass:[NSArray class]]){
            for (int i=0; i<[subs count]; i++) {
                View* sub = [subs objectAtIndex:i];
                [sub appendTo:v];
            }
        }
    }
    [v appendTo:target];
    return v;
}

View* vbox(id subs, Styles styles, UIView*target){
    return box(VBOX, subs, styles, target);
}
View* hbox(id subs, Styles styles, UIView*target){
    return box(HBOX, subs, styles, target);
}
View* label(NSString*text, Styles styles, UIView*target){
    if (text==nil) text=@"";
    View *v = box(VBOX, nil, styles, target);
    [v setText:text];
    return v;
}
View* img(NSString*src, Styles styles, UIView*target){
    View *v = box(VBOX, nil, styles, target);
    [v setImage:src];
    return v;
}

View* list(NSArray*data, ViewDrawListRowHandler handler, Styles styles, UIView*target){
    View *v = vbox(nil, styles, target);
    if(data!=nil){
        int idx = 0;
        float rh = MAX(styles.rowHeight, 44);
        for(NSDictionary *d in data){
            Styles rowStyle ={.h=rh, .w=320};
            View *row = vbox(nil, rowStyle, nil);
            handler(d, row, idx);
            [row appendTo:v];
            idx++;
        }
    }
    return v;
}

NSString * str(char * cs){return cs!=nil?[NSString stringWithFormat:@"%s",cs]:nil;}
char * cstr(NSString * cs){
    return (char*)[cs UTF8String];
}

NSDictionary* style(NSString* style){
    load_style(nil);
    return _stylesheets[style];
}

void load_style(NSString* style_file){
    if(style_file==nil)
        style_file = [NSString stringWithUTF8String:STYLE_SHEET_FILE];
    if(_stylesheets==nil){
        _stylesheets = [[NSDictionary alloc] dictionaryFromJSONFile:style_file];
    }
}

#pragma mark - Border

@implementation Border

+(Border*) borderWithStyle:(NSString*)style{
    Border *border = [[Border alloc] init];
    if(style!=nil){
        style = [style regexpReplace:@"  +" replace:@" "];
        NSArray *parts = [style componentsSeparatedByString:@" "];
        border.width = [parts[0] floatValue];
        if([parts count]>1){
            NSString *cl = parts[1];
            if([cl contains:@","]||[cl contains:@"#"]){//color
                border.color = [cl colorValue];
            }else{//image
                border.color = [UIColor colorWithPatternImage:[UIImage imageNamed:cl]];
            }
            //TODO radius
            if([parts count]>2){
                int rd = [parts[2] intValue];
                if(rd>0) border.radius = rd;
            }
        }
    }
    return border;
}

@end


#pragma mark - View
@implementation View
@synthesize styles,ID;

-(id)initWithType:(ViewTypes)type styles:(Styles)style target:(UIView *)target{
    
    self = [super initWithFrame:CGRectMake(0, 0, 0, 0)];
    
    load_style(nil);
    
    self.styles = [self mergeStyle:style];
    
    _type = type;
    
    self.backgroundColor = [UIColor clearColor];
    
    _data = [[NSMutableDictionary alloc] init];
    
    ID = [NSString stringWithFormat:@"%s", styles.ID];

    if(target!=nil)
        [self appendTo:target];
    else
        self.frame = [self calculateFrame:target];
    self.contentRect = self.frame;
    //logRect(ID,self.frame);
    
    _content = [CAShapeLayer layer];
    _content.frame = self.bounds;
    _content.masksToBounds = YES;

    self.layer.masksToBounds = NO;

    return self;
}

-(Styles)mergeStyle:(Styles)s{
    
    //NSDictionary * comm = style(@"*");
    
    if(s.scaleX==0)s.scaleX = 1;
    if(s.scaleY==0)s.scaleY = 1;
    if(s.fontSize==0)s.fontSize = 14;
    if(s.color==nil)s.color = "#000000";
    if(s.fontName==NULL)s.fontName = "Helvetica Neue Light";
    
    return s;

}

-(void)appendTo:(UIView *)parent{
    if(parent!=nil){
        _idx = [parent.subviews count];
        CGRect frame = [self calculateFrame:parent];
        self.frame = frame;
        
        if(self.txt!=nil){
            [self setText:_txt];
        }
        if(self.src!=nil){
            [self setImage:_src];
        }
        
        if(![parent isKindOfClass:[View class]])
            self.isRoot = YES;
        [self renderStyles];
        
        [parent addSubview:self];
    }
}


/*

-(NSArray*)getAttrs:(id)target{
    unsigned int outCount, i;
    objc_property_t *properties = class_copyPropertyList(target, &outCount);
    NSMutableArray *org_attrs = [[NSMutableArray alloc] init];
    for(i = 0; i < outCount; i++) {
    	objc_property_t property = properties[i];
    	const char *propName = property_getName(property);
    	if(propName) {
    		//const char *propType = getPropertyType(property);
    		NSString *propertyName = [NSString stringWithUTF8String:propName];
    		//NSString *propertyType = [NSString stringWithCString:propType];
            [org_attrs addObject:propertyName];
    	}
    }
    free(properties);
    return org_attrs;
}
*/
#pragma mark - property methods


-(void) setBackgroundImage:(NSString *)imageUrl{
    //view.layer.contents = yourImage.CGImage;
    //view.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"background.png"]];
}
-(void) setBackgroundImage:(NSString *)imageUrl fitMode:(UIViewContentMode)mode inRect:(CGRect)rect{

}

-(void) setImage:(NSString *)imageUrl{
    self.src = imageUrl;
    //CGRect rect = [self contentFrame];
    //if(_parent!=nil){
        /*
         TODO
         - (CGSize)sizeThatFits:(CGSize)size //calculate a size to make the superview to fit its all subviews
         - (void)sizeToFit //auto adjust super view to fit its all subviews
         */
        UIImage *img = [UIImage imageNamed:imageUrl];
        if(_backgroundLayer == nil)
            _backgroundLayer = [[CALayer alloc] init];
        //TODO adjust image size
        [_backgroundLayer setFrame:self.bounds];
        _backgroundLayer.contentsGravity = kCAGravityCenter;
        _backgroundLayer.contents = (__bridge id)(img.CGImage);
        [self.layer addSublayer:_backgroundLayer];
    //}
}

-(void) setText:(NSString *)_text{
    self.txt = _text;
    /*
     TODO 
     - (CGSize)sizeThatFits:(CGSize)size //calculate a size to make the superview to fit its all subviews
     - (void)sizeToFit //auto adjust super view to fit its all subviews
     */
    CGRect rect = [self contentFrame];
    //logRect(@"txt",rect);
    if(_textLayer==nil)
        _textLayer= [[CATextLayer alloc] init];
    else
        _textLayer.hidden = NO;
    if ([_textLayer respondsToSelector:@selector(setContentsScale:)]){
        _textLayer.contentsScale = [[UIScreen mainScreen] scale];
    }

    [_textLayer setFrame:rect];
    [_textLayer setString:_text];
    [_textLayer setBackgroundColor:[UIColor clearColor].CGColor];

    [self setFont:styles.font];
    
    if(styles.fontSize>0)
        [self setFontSize: styles.fontSize];
    
    if(styles.color)
        [self setColor:str(styles.color)];

    [self setTextAlign:str(styles.textAlign)];

    [_content addSublayer:_textLayer];

}

-(void) setTextAlign:(NSString*)align{
    if(align==nil)
        align = @"left";
    
    const NSDictionary * def = @{@"center":kCAAlignmentCenter,@"left":kCAAlignmentLeft,
                                 @"right":kCAAlignmentRight,@"justified":kCAAlignmentJustified};
    if(align!=nil)
        //_opts[@"textAlign"] = align;
        styles.textAlign = cstr(align);
    
    NSString *a = (align!=nil && def[align]!=nil) ? def[align]:kCAAlignmentNatural;
    if(_textLayer!=nil){
        [_textLayer setAlignmentMode:a];
    }
    _textLayer.wrapped = !styles.nowrap;
    _textLayer.truncationMode = styles.truncate ? kCATruncationEnd:kCATruncationNone;
}

-(void) setFont:(char*)font{
    NSString *f = [NSString stringWithFormat:@"%s",font];
    if(_textLayer==nil)
        _textLayer= [[CATextLayer alloc] init];
    NSDictionary *defaultStyle = style(@"*");
    if(defaultStyle!=nil && f==nil){
        f = defaultStyle[@"font"];
    }
    if(f!=nil && ![f isEqualToString:@"default"]){//FIXME
        float fontSize = styles.fontSize>0?styles.fontSize:14;
        if([f contains:@","]){//@"monaco,12"
            NSArray *fs = [f componentsSeparatedByString:@","];
            f = (NSString*)fs[0];
            NSString *fsize = [(NSString*)fs[1] stringByReplacingOccurrencesOfString:@" " withString:@""];
            fontSize = [fsize floatValue];
        }
        styles.fontName = cstr(f);
        [_textLayer setFont:(__bridge CFTypeRef)(f)];
        [_textLayer setFontSize:fontSize];
    }else{
        [self setFontSize:-1];//adjust size auto;
    }
}


-(void) setColor:(id)color{
    if(_textLayer==nil)
        _textLayer= [[CATextLayer alloc] init];
    if(color!=nil){
        UIColor * cl = ([color isKindOfClass:[UIColor class]])? (UIColor *)color:
                            ([color isKindOfClass:[NSString class]]? [color colorValue]:[UIColor blackColor]);
        [_textLayer setForegroundColor:[cl CGColor]];
    }else{
        NSDictionary *defaultStyle = style(@"*");
        NSString *cl = defaultStyle!=nil && defaultStyle[@"color"]!=nil ? defaultStyle[@"color"]:@"#000000";
        [_textLayer setForegroundColor:[cl colorValue].CGColor];
    }
}

-(void)setFontSize:(float)s{
    if(_textLayer==nil)
        _textLayer= [[CATextLayer alloc] init];
    if(s>0)
        [_textLayer setFontSize:s];
    else{
        CGRect rect = [self contentFrame];
        NSString *fontName = styles.fontName? str(styles.fontName):@"Helvetica";
        int fontSize = ![_txt isEqual:[NSNull null]] ? [_txt sizeToFit:rect.size font:fontName] : 14;
        //NSLog(@"font-size:%d",fontSize);
        [_textLayer setFontSize:fontSize];
    }
}

-(void) setOutline:(NSString*)outline{
    outline = [outline regexpReplace:@"  +" replace:@" "];
    NSArray *parts = [outline componentsSeparatedByString:@" "];
    if([parts count]==3){
        styles.outlineWidth = [parts[0] floatValue];
        styles.outlineSpace = [parts[1] floatValue];
        styles.outlineColor = cstr(parts[2]);
    }
}


/**
 format :width color/image corner-radius
 format(use image) : 1 myline.png 4
 format(use rgbcolor) : 1 213,204,222
 format(use hexcolor) : 1 #CCFF33 2
 */
-(void) setBorder:(NSString*)style side:(int)side{
    if(_isRoot)
        return;
    Border *b= [Border borderWithStyle:style];
    if(b.width>0){
        BOOL custom = YES;
        
        switch (side) {
            case 0:_borderLeft=b;break;
            case 1:_borderTop=b;break;
            case 2:_borderRight=b;break;
            case 3:_borderBottom=b;break;
            default:
                custom = NO;
                _borderLeft = b;
                _borderTop = b;
                _borderRight = b;
                _borderBottom = b;
                break;
        }
        _isBorderCustomized = custom;
        
        if(b.radius>styles.cornerRadius)
            styles.cornerRadius=b.radius;
        [self resizeBorder];
    }
    
}

-(void)resizeBorder{
    float w = _contentRect.size.width;
    float h = _contentRect.size.height;
    float o = styles.outlineWidth+styles.outlineSpace;
    
    //resize frame
    float left = _borderLeft!=nil? _borderLeft.width+o : o;
    float top = _borderTop!=nil? _borderTop.width+o : o;
    float right = _borderRight!=nil? _borderRight.width+o : o;
    float bottom = _borderBottom!=nil? _borderBottom.width+o : o;
    
    self.frame = CGRectMake(_contentRect.origin.x, _contentRect.origin.y,w+left+right, h+top+bottom);
    _content.frame = CGRectMake(left,top,w,h);
}


-(void) renderStyles{
    if(styles.border) [self setBorder:str(styles.border) side:-1];
    if(styles.borderLeft) [self setBorder:str(styles.borderLeft) side:0];
    if(styles.borderTop) [self setBorder:str(styles.borderTop) side:1];
    if(styles.borderRight) [self setBorder:str(styles.borderRight) side:2];
    if(styles.borderBottom) [self setBorder:str(styles.borderBottom) side:3];
    
    //if(styles.shadow)[self setShadow:str(styles.shadow)];
    
    if(styles.bgcolor)[self setBgcolor:str(styles.bgcolor)];
    if(styles.rotate)[self setRotate:[NSNumber numberWithFloat:styles.rotate ]];
    if(styles.scaleX>0 || styles.scaleY>0) [self setScale:[NSString stringWithFormat:@"%f,%f",styles.scaleX,styles.scaleY]];

    if(styles.flip){
        if (styles.flip[0] == 'H') {
            self.transform = CGAffineTransformMake(self.transform.a * -1, 0, 0, 1, self.transform.tx, 0);
        }else if(styles.flip[0] == 'V'){
            self.transform = CGAffineTransformMake(1, 0, 0, self.transform.d * -1, 0, self.transform.ty);
        }
    }
    
    
    
    //self.alpha = styles.alpha;
    
    //TODO align 8 ways
    //TODO padding, paddingLeft .....
    
    
    //[_content removeFromSuperlayer];
    [self.layer addSublayer:_content];

    if(styles.shadow){
        [self drawShadow];
    }
    
    if(_borderLeft!=nil || _isBorderCustomized){
        [self drawBorders];
    }
    
    if(styles.outline){
        [self setOutline:str(styles.outline)];
        [self drawOutline];
    }
}

-(void) drawOutline{
    if(styles.outlineWidth>0){
        NSString *cl = [NSString stringWithUTF8String:styles.outlineColor];
        UIColor *oColor;
        if([cl contains:@","]||[cl contains:@"#"]){//color
            oColor = [cl colorValue];
        }else{//image
            oColor= [UIColor colorWithPatternImage:[UIImage imageNamed:cl]];
        }
        
        float w = styles.outlineWidth + styles.outlineSpace;
        
        CALayer *olayer = [CALayer layer];
        olayer.frame = CGRectMake(-1*w, -1*w,
                                  self.frame.size.width+2*w, self.frame.size.height+2*w);
        
        olayer.borderWidth = styles.outlineWidth;
        olayer.borderColor = oColor.CGColor;
        olayer.cornerRadius = styles.cornerRadius>0? styles.cornerRadius+styles.outlineSpace : 0;
        
        [self.layer addSublayer:olayer];
        olayer = nil;oColor = nil;
    }
}

-(void) drawBorders{

    float left = _borderLeft!=nil? _borderLeft.width : 0;
    float top = _borderTop!=nil? _borderTop.width : 0;
    float right = _borderRight!=nil? _borderRight.width : 0;
    float bottom = _borderBottom!=nil? _borderBottom.width : 0;
    
    float r = styles.cornerRadius;
    float w = self.frame.size.width;
    float h = self.frame.size.height;
    float o = styles.outlineSpace + styles.outlineWidth;
    
    //UIView *borderView = [UIView alloc];
    CALayer *border = [CALayer layer];
    
    border.cornerRadius = r;
    border.masksToBounds = YES;
    border.frame = CGRectMake(o, o, self.bounds.size.width-2*o, self.bounds.size.height-2*o);
    
    if(!_isBorderCustomized){
        Border * b = _borderLeft;
        border.borderColor = b.color.CGColor;
        border.borderWidth = b.width;
        //[self addSubview:_border];
        [self.layer addSublayer:border];
        border = nil;
        return;
    }
    
    //use round & radius
    
    float irs[4] ={
        r > MAX(left, top)     ? r - MAX(left, top):0,
        r > MAX(top,right)     ? r - MAX(top,right):0 ,
        r > MAX(right,bottom)  ? r - MAX(right,bottom):0,
        r > MAX(right,bottom)  ? r - MAX(bottom,left):0
    };
    
    
    float angs[4] = {
        top+irs[0]    > 0? atan((left+irs[0])/(top+irs[0])) : 0,
        right+irs[1]  > 0? atan((top+irs[1])/(right+irs[1])) : 0,
        bottom+irs[2] > 0? atan((right+irs[2])/(bottom+irs[2])) : 0,
        left+irs[3]   > 0? atan((bottom+irs[3])/(left+irs[3])) : 0
    };
    
    //joint points, 7 9 3 1
    float ps[8] = {
        left>0  ? (top>0?   left+irs[0]*(1-sin(angs[0]))    : MAX(left, r))    :0,
        top>0   ? (left>0?  top+irs[0]*(1-cos(angs[0]))     : MAX(top, r))     :0,
        
        right>0 ? (top>0?   w-right-irs[1]*(1-cos(angs[1])) : w-MAX(right, r)) :w,
        top>0   ? (right>0? top+irs[1]*(1-sin(angs[1]))     : MAX(top, r))     :0,
        
        right>0 ? (bottom>0?w-right-irs[2]*(1-sin(angs[2])) : w-MAX(right, r)) :w,
        bottom>0? (right>0? h-bottom-irs[2]*(1-cos(angs[2])): h-MAX(bottom, r)):h,
        
        left>0  ? (bottom>0?left+irs[3]*(1-cos(angs[3]))    : MAX(left, r))    :0,
        bottom>0? (left>0? h-bottom-irs[3]*(1-sin(angs[3])) : h-MAX(bottom, r)):h
    };
    
    float m[4][16]  =  {
        {0,0,   ps[0],ps[1],    left,MAX(r,top),
            left,ps[1]+irs[0]*sin(M_PI/2-angs[0])/2,    left,ps[7]-irs[3]*sin(angs[3])/2,             //ctrl points
            left,h-MAX(r,bottom),      ps[6],ps[7],     0,h},
        {w,0,   ps[2],ps[3],    w-MAX(r,right),top,
            ps[2]-irs[1]*sin(M_PI/2-angs[1])/2,top,     ps[0]+irs[0]*sin(angs[0])/2,top,               //ctrl points
            MAX(r,left),top,           ps[0],ps[1],     0,0},
        {w,h,   ps[4],ps[5],    w-right,h-MAX(r,bottom),
            w-right,ps[5]-irs[2]*sin(M_PI/2-angs[2])/2,    w-right,ps[3]+irs[1]*sin(angs[1])/2,       //ctrl points
            w-right,MAX(r,top),         ps[2],ps[3],     w,0},
        {0,h,   ps[6],ps[7],    MAX(r,left),h-bottom,
            ps[6]+irs[3]*sin(M_PI/2-angs[3])/2,h-bottom,    ps[4]-irs[3]*sin(angs[3])/2,h-bottom,    //ctrl points
            w-MAX(r,right),h-bottom,   ps[4],ps[5],     w,h}
        
    };
    
    for (int side=0;side<=3;side++) {
        Border *this= //(Border*)_borders[side];
            side==0?_borderLeft:(side==1?_borderTop:(side==2?_borderRight:_borderBottom));
        if(this.width>0){
            CGMutablePathRef path = CGPathCreateMutable();
            CGPathMoveToPoint(path, NULL, m[side][0], m[side][1]);
            CGPathAddLineToPoint(path, NULL, m[side][2], m[side][3]);
            if(m[side][2]!=m[side][4] && m[side][3]!=m[side][5]){
                CGPathAddQuadCurveToPoint(path, NULL, m[side][6], m[side][7], m[side][4], m[side][5]);
            }else{
                CGPathAddLineToPoint(path, NULL, m[side][4], m[side][5]);
            }
            
            CGPathAddLineToPoint(path, NULL, m[side][10], m[side][11]);
            
            if(m[side][10]!=m[side][12] && m[side][11]!=m[side][13]){
                CGPathAddQuadCurveToPoint(path, NULL, m[side][8], m[side][9], m[side][12], m[side][13]);
            }else{
                CGPathAddLineToPoint(path, NULL, m[side][12], m[side][13]);
            }
            
            CGPathAddLineToPoint(path, NULL, m[side][14], m[side][15]);
            CGPathAddLineToPoint(path, NULL, m[side][0], m[side][1]);
            CGPathCloseSubpath(path);
            
            CALayer *l = [CALayer layer];
            l.frame =CGRectMake(0, 0, w,h);
            l.backgroundColor = this.color.CGColor;
            
            CAShapeLayer *mask = [CAShapeLayer layer];
            mask.frame = CGRectMake(0, 0, w,h);
            mask.path = path;
            l.mask = mask;
            mask.fillColor = [UIColor blackColor].CGColor;
            //[_border.layer addSublayer:l];
            [border addSublayer:l];
            l = nil;mask=nil;
        }
    }
    //[self addSubview:_border];
    [self.layer addSublayer:border];
    border = nil;
}

/*
//Private method
-(View*) attr:(NSDictionary*)opts{
    NSMutableArray * stylesToSet = [NSMutableArray array];
    for(NSString * k in opts){//set properties first
        id v = opts[k];
        if([_styles indexOfObject:k]!=NSNotFound){
            [stylesToSet addObject:k];
        }else{
            if([k isEqualToString:@"css"]){
                [self css:v];
            }else if([k isEqualToString:@"text"]){
                //[self setText:v];
                self.txt = v;
            }else if([k isEqualToString:@"image"]){
                //[self setImage:v];
                self.src = v;
            }else
                [self attr:k value:v];
        }
        
    }
    for (NSString * k in stylesToSet) {//set styles right now
        id v = opts[k];
        if(_defaultStyles==nil)_defaultStyles=[[NSMutableDictionary alloc] init];
        [_defaultStyles setValue:v forKey:k];
        [self setStyle:k value:v];
    }
    
    return self;
}
-(View*) attr:(NSString*)key value:(id)value{
    if([_attrs indexOfObject:key]!=NSNotFound){
        if([value isKindOfClass:[NSString class]]){
            if([value isEqualToString:@"true"])
                [self setValue:[NSNumber numberWithBool:YES] forKey:key];
            else if([value isEqualToString:@"false"])
                [self setValue:[NSNumber numberWithBool:NO] forKey:key];
        }
        else
            [self setValue:value forKey:key];
        
    }else {
        if(![value isKindOfClass:NSClassFromString(@"NSBlock")]){
            [self set:key value:value];//FIXME check if its function
        }
    }
    return self;
}
*/

/**
 
 event :_events =[ tap, pinch, rotation, swipe, pan, longpress]
 
 handler : void^(UIGestureRecognizer* ges){
                View * v = (View*)ges.view;
           }
 
 
 */
-(View*) bind:(NSString*)event handler:(ViewGestureHandler)handler options:(NSDictionary*)options{
    if([_events indexOfObject:event]==NSNotFound)
        return self;
    if(_gestures==nil){
        _gestures=[[NSMutableDictionary alloc] init];
    }
    _gestures[event] = (id) handler;
    if(handler==NULL){
        return self;
    }
    event = [event stringByReplacingCharactersInRange:NSMakeRange(0,1) withString:[[event substringToIndex:1] uppercaseString]];
    NSString * className = [NSString stringWithFormat:@"UI%@GestureRecognizer",event];
    UIGestureRecognizer *gesture = [[NSClassFromString(className) alloc] initWithTarget:self action:@selector(gestureHandler:)];
    [self setUserInteractionEnabled:YES];
    /*
     TODO multipleTouchEnabled
          exclusiveTouch
     */
    if(options!=nil){
        for(NSString *k in options){
            [gesture setValue:options[k] forKey:k];
        }
    }
    [self addGestureRecognizer:gesture];
    return self;
}

-(View*) unbind:(NSString*)event{
    if(_gestures!=nil){
        [_gestures removeObjectForKey:event];
    }
    return self;
}

/*
-(View*) css:(NSString *)stylename{
    if(stylename!=nil){
        [self cssClear];
        NSArray *slist = [[stylename regexpReplace:@"  +" replace:@""] componentsSeparatedByString:@" "];
        for (NSString *stylename in slist) {
            NSDictionary *css =style(stylename);
            if(css!=nil){
                for (NSString *key in css) {
                    [self setStyle:key value:css[key]];
                }
            }
        }
    }else{
        [self cssClear];
    }
    return self;
}*/


#pragma mark - private methods


/**
 //format(use rgbcolor) : 213,204,222
 //format(use hexcolor) : #336699
 //format(use gradient) : #336699 #33CCFF
 //format(use gradient + location) : #336699:0 #3399CC:0.5 #33CCFF:1
 */
-(void)setBgcolor:(id)value{
    if([value isKindOfClass:[NSString class]]){
        value = [value regexpReplace:@"  +" replace:@" "];
        NSArray *parts = [value componentsSeparatedByString:@" "];
        int size =[parts count];
        if(size>=2){
            CAGradientLayer *gradient = [CAGradientLayer layer];
            gradient.frame = self.bounds;
            gradient.cornerRadius = styles.cornerRadius;
            
            NSMutableArray *colors=[NSMutableArray array];
            NSMutableArray *locations=[NSMutableArray array];
            for (int i=0;i<size; i++) {
                NSString *v = parts[i];
                if([v contains:@":"]){
                    NSArray *vps = [v componentsSeparatedByString:@":"];
                    [colors addObject:(id)[vps[0] colorValue].CGColor];
                    [locations addObject:[NSNumber numberWithFloat:[vps[1] floatValue]]];
                }else{
                    [colors addObject:(id)[v colorValue].CGColor];
                    [locations addObject:[NSNumber numberWithFloat:((float)i/(float)(size-1))]];
                }
            }
            gradient.colors = colors;
            gradient.locations = locations;
            [_content insertSublayer:gradient atIndex:0];
            //FIXME Maybe this should be added to self.layer.
        }else
            [_content setBackgroundColor:[value colorValue].CGColor];
        
    }else if([value isKindOfClass:[UIColor class]])
        [_content setBackgroundColor:((UIColor*)value).CGColor];
    
    
}

-(void)setPadding:(NSString*)v side:(int)side{
    
}

-(void)setRotate:(id)rotate{
    if([rotate isKindOfClass:[NSNumber class]]){
        self.transform = CGAffineTransformMakeRotation(radians([(NSNumber*)rotate floatValue]));
    }else if([rotate isKindOfClass:[NSString class]]){
        //TODO 3d rotate
    }
    
}

/**
 format : xScale,yScale
 */
-(void)setScale:(NSString*)scale{
    NSArray * parts = [[scale regexpReplace:@"\\s" replace:@""] componentsSeparatedByString:@","];
    if([parts count]==2){
        self.transform = CGAffineTransformMakeScale([parts[0] floatValue], [parts[1] floatValue]);
    }
}

/**
 format : x y radius color
 */

-(void)drawShadow{

    //TODO inset
    NSString *shadow = [str(styles.shadow) regexpReplace:@"  +" replace:@" "];
    //_opts[@"shadow"] = shadow;
    NSArray *parts = [shadow componentsSeparatedByString:@" "];
    int psize =[parts count];

    if(psize>=4){
        BOOL isInner = [parts[0] isEqualToString:@"inset"];
        
        int offset = isInner ? 1:0;
        float x = [parts[0+offset] floatValue];
        float y = [parts[1+offset] floatValue];
        float r = [parts[2+offset] floatValue];
        UIColor * cl = ([parts count] >= 4+offset)? [parts[3+offset] colorValue]:[UIColor darkGrayColor];

        self.clipsToBounds = NO;
        
        if(isInner){
            //_innerShadow = [[InnerShadow alloc] initWithTarget:self x:x y:y r:r];
            CALayer * s = [CALayer layer];
            float o = styles.outlineWidth+styles.outlineSpace;
            float left = _borderLeft!=nil? _borderLeft.width+o : o;
            float top = _borderTop!=nil? _borderTop.width+o : o;
            float right = _borderRight!=nil? _borderRight.width+o : o;
            float bottom = _borderBottom!=nil? _borderBottom.width+o : o;
            float mx = MAX(MAX(left, right),MAX(top, bottom));

            s.frame = CGRectMake(left-x, top-y, self.bounds.size.width-left-right+2*x, self.bounds.size.height-top-bottom+2*y);
            s.cornerRadius = styles.cornerRadius>mx ? styles.cornerRadius-mx : 0;
            
            s.borderWidth = MAX(x, y);
            s.borderColor = [UIColor colorWithWhite:1 alpha:1].CGColor;
            s.shadowOffset = CGSizeMake(x/2, y/2);
            s.shadowRadius = r;
            s.shadowOpacity = 0.7;
            s.shadowColor = cl.CGColor;
            s.masksToBounds = YES;
            [self.layer addSublayer:s];
            s = nil;
        }else{
            
            self.layer.shadowOffset = CGSizeMake(x, y);
            self.layer.shadowRadius = r;
            self.layer.shadowColor = cl.CGColor;
            //!!! layer.shadowOpacity is very slow sometime and cost much more memory
            //self.layer.shadowOpacity = [parts count]>4? [parts[5] floatValue]:0.7;
            self.layer.shadowOpacity = 0.7;
        }
    }else{
        self.layer.shadowOffset = CGSizeZero;
        self.layer.shadowRadius = 0;
        self.layer.shadowColor = [UIColor clearColor].CGColor;
        self.layer.shadowOpacity = 0;
    }
    parts = nil;
    
}

-(void) cssClear{
    /*
    if(_replacedStyles!=nil){
        for (NSString *k in _replacedStyles) {
            [self setStyle:k value:_replacedStyles[k]];
        }
        [_replacedStyles removeAllObjects];
    }
    if(_defaultStyles!=nil){
        for (NSString *k in _defaultStyles) {
            [self setStyle:k value:_defaultStyles[k]];
        }
    }*/
    //FIXME
    
}


-(CGRect)contentFrame{
    return CGRectMake(styles.paddingLeft+styles.cornerRadius, styles.paddingTop+styles.cornerRadius,
                      self.frame.size.width-styles.paddingLeft-styles.paddingRight-styles.cornerRadius*2,
                      self.frame.size.height-styles.paddingTop-styles.paddingBottom-styles.cornerRadius*2);
}


- (CGRect)calculateFrame:(UIView*)parent{
    float x = styles.x + styles.marginLeft;
    float y = styles.y + styles.marginTop;
    float w= styles.w;
    float h= styles.h;
    
    if(parent!=nil){
        float pspace = ([parent isKindOfClass:[View class]])? ((View*)parent).styles.space:0;
        if(_type==VBOX){
            w = parent.bounds.size.width-styles.marginLeft-styles.marginRight;
            float top = styles.marginTop;
            for(UIView* v in parent.subviews)
                top += v.bounds.size.height + pspace;
            y = top;
            if(h==0) h=parent.bounds.size.height-styles.marginTop-styles.marginBottom;
        }else if(_type==HBOX){
            h = parent.bounds.size.height-styles.marginTop-styles.marginBottom;
            float left = styles.marginLeft;
            for(UIView* v in parent.subviews)
                left += v.bounds.size.width + pspace;
            x = left;
            if(w==0) h=parent.bounds.size.width-styles.marginLeft-styles.marginRight;
        }
    }else{
        CGRect screen = [[UIScreen mainScreen] applicationFrame];
        if(w==0) w = screen.size.width;
        if(h==0) h = screen.size.height;
    }
    return CGRectMake(x, y, w, h);
}

-(void) gestureHandler:(UIGestureRecognizer*)ges{
    NSString *className = [[ges class] description];
    NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:@"(UI|GestureRecognizer)"
                                                                           options:NSRegularExpressionCaseInsensitive error:nil];
    className = [[regex stringByReplacingMatchesInString:className options:0 range:NSMakeRange(0, [className length]) withTemplate:@""] lowercaseString];
    /*
    if(_editable && [className isEqualToString:@"tap"]){
        [self switchEditingMode];
    }else */
    if(_gestures!=nil && _gestures[className]!=nil){
        ViewGestureHandler handler = _gestures[className];
        handler(ges);
    }
    //NSLog(@"Gesture :  %@",className);
}

-(void) switchEditingMode{
    
    if(_textField!=nil){
        if(_textField.hidden){
            //[self insertSubview:_textField belowSubview:_borders];
            [self addSubview:_textField];//FIXME
            if(_textLayer.wrapped){
                ((UITextView*)_textField).text = _txt;
            }else{
                ((UITextField*)_textField).text = _txt;
            }
            _textField.hidden = NO;
            _textLayer.hidden = YES;
            [_textField becomeFirstResponder];
            
            View *root = [self root];
            if(root){
                [root set:@"orgContentOffset" value:[NSNumber numberWithFloat:root.contentOffset.y]];
                [root setContentOffset:CGPointMake(0, self.frame.origin.y) animated:YES];
                //FIXME , change self.frame.origin.y to height in root
            }
        }else{
            _textField.hidden = YES;
            if(_textLayer.wrapped){
                [self setText:((UITextView*)_textField).text];
            }else{
                [self setText:((UITextField*)_textField).text];
            }
            [_textField resignFirstResponder];
            View *root = [self root];
            if(root){
                float orgOffset = [root get:@"orgContentOffset"]!=nil?[[root get:@"orgContentOffset"] floatValue]:0;
                [root setContentOffset:CGPointMake(0, orgOffset) animated:YES];
            }
        }
    }
}

-(void) setEditable:(BOOL)editable{
    styles.editable = editable;
    if(_textField==nil){
        CGRect rect = CGRectMake(styles.cornerRadius, styles.cornerRadius,
                                 _contentRect.size.width-2*styles.cornerRadius,
                                 _contentRect.size.height-2*styles.cornerRadius);
        
        NSDictionary * orgs = style(@"*");

        NSString *fontName = //_opts[@"fontName"]!=nil? _opts[@"fontName"]:@"Helvetica";
            styles.fontName!=NULL ? str(styles.fontName):@"Helvetica";
        
        float fontSize =// _opts[@"fontSize"]?[_opts[@"fontSize"] floatValue]:
            styles.fontSize>0 ? styles.fontSize:
            (orgs!=nil && orgs[@"fontSize"]!=nil? [orgs[@"fontSize"] floatValue]:14);
        
        const NSArray * aligns = (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) ?
            @[@"left",@"center",@"right", @"justified", @"natrual"]:@[@"left",@"right",@"center", @"justified", @"natrual"];
        //NSString *align = _opts[@"textAlign"]!=nil?_opts[@"textAlign"]:@"left";
        NSString *align = styles.textAlign?str(styles.textAlign):@"left";
        
        if(_textLayer.wrapped ||!styles.nowrap){
            UITextView* t = [[UITextView alloc] initWithFrame:rect];
            t.delegate = self;
            t.textAlignment = (NSTextAlignment)[aligns indexOfObject:align];
            t.font = [UIFont fontWithName:fontName size:fontSize];
            t.editable = YES;
            _textField = t;
        }else{
            UITextField* t = [[UITextField alloc] initWithFrame:rect];
            t.delegate = self;
            if(styles.placeHolder!=nil)
                t.placeholder = str(styles.placeHolder);
            t.textAlignment = (NSTextAlignment)[aligns indexOfObject:align];
            t.font = [UIFont fontWithName:fontName size:fontSize];
            _textField = t;
        }
        _textField.hidden = YES;
    }
    [self bind:@"tap"
        handler:^void (UIGestureRecognizer* o){
            View *v = (View *)o.view;
            [v switchEditingMode];
        } options:nil];
}


-(View*) root{
    if(self.isRoot)
        return self;
    UIView *v = self.superview;
    while (v!=nil) {
        if([v isKindOfClass:[View class]]){
            return [((View*)v) root];
        }else
            v = nil;
    }
    return nil;
}

#pragma mark - data methods

- (void) set:(NSString*)keyPath value:(id)value{
    [_data setValue:value forKeyPath:keyPath];
}

- (id) get:(NSString*)keyPath{
    return [_data valueForKeyPath:keyPath];
}

- (void) del:(NSString*)keyPath{
    [_data removeObjectForKey:keyPath];
}


#pragma mark -- delegate of textField
// may be called if forced even if shouldEndEditing returns NO (e.g. view removed from window) or endEditing:YES called
- (void)textFieldDidEndEditing:(UITextField *)textField{
    //NSLog(@"textFieldDidEndEditing");
    _textField.hidden = YES;
    [self setText:((UITextField*)_textField).text];
    View *root = [self root];
    if(root){
        float orgOffset = [root get:@"orgContentOffset"]!=nil?[[root get:@"orgContentOffset"] floatValue]:0;
        [root setContentOffset:CGPointMake(0, orgOffset) animated:YES];
    }
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField{
    //NSLog(@"textFieldShouldReturn");
    if(_textLayer.wrapped){
        ((UITextField*)_textField).text = [NSString stringWithFormat:@"%@\r\n",((UITextField*)_textField).text ];
        return NO;
    }else{
        [textField resignFirstResponder];
        return YES;
    }
    
}

#pragma mark -- delegate of textView

-(BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text {
    return YES;
}



@end
