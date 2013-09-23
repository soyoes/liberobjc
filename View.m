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
#import "NSString+common.h"
#import "NSDictionary+common.h"
#import "UIView+liber.h"
#import <objc/runtime.h>
#import <QuartzCore/QuartzCore.h>
#include <math.h>

#define logRect(name,rect) (NSLog(@"--\nRECT:%@ = (%f,%f), (%f,%f) \n--",(name),(rect.origin.x),(rect.origin.y),(rect.size.width),(rect.size.height)))
#define logSize(name,size) (NSLog(@"--\nRECT:%@ = (%f,%f) \n--",(name),(size.width),(size.height)))
#define logPoint(name,p) (NSLog(@"--\nRECT:%@ = (%f,%f) \n--",(name),(p.x),(p.y)))

#define _styles @[@"shadow", @"border",@"borderLeft",@"borderTop",@"borderRight",@"borderBottom", @"bgcolor", @"rotate", @"scale", @"flip", @"alpha", @"font", @"fontSize", @"color", @"textAlign", @"align", @"padding", @"paddingLeft",@"paddingTop", @"paddingRight",@"paddingBottom"]
#define _events @[@"tap", @"pinch", @"rotation", @"swipe", @"pan", @"longpress"]

#define radians(degrees) (degrees * M_PI/180)

#ifndef STYLE_SHEET_FILE
    #define STYLE_SHEET_FILE "styles.json"
#endif

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

View* box(ViewTypes type, id subs, NSDictionary*opts, UIView*target){
    View *v = [[View alloc] initWithType:type opts:opts target:nil];
    if(subs!=nil){
        if([subs isKindOfClass:[View class]]){
            [(View*)subs appendTo:v];
        }else if([subs isKindOfClass:[NSArray class]]){
            for(View* sub in subs){
                [sub appendTo:v];
            }
        }
    }
    [v appendTo:target];
    return v;
}

View* vbox(id subs, NSDictionary*opts, UIView*target){
    return box(VBOX, subs, opts, target);
}
View* hbox(id subs, NSDictionary*opts, UIView*target){
    return box(HBOX, subs, opts, target);
}
View* label(NSString*text, NSDictionary*opts, UIView*target){
    /*
    if(opts==nil)opts=@{@"font":@"default"};
    NSMutableDictionary *nopts = [[NSMutableDictionary alloc] initWithDictionary:opts copyItems:YES];
    if(opts[@"font"]==nil){
        nopts[@"font"]=@"default";
    }
     */
    if (text==nil) text=@"";
    View *v = box(VBOX, nil, opts, target);
    //NSLog(@"rect %d, %d, %d, %d", v.frame.origin.x,v.frame.origin.y,v.frame.size.width, v.frame.size.height);
    [v setText:text];
    return v;
}
View* img(NSString*src, NSDictionary*opts, UIView*target){
    View *v = box(VBOX, nil, opts, target);
    [v setImage:src];
    return v;
}

View* list(NSArray*data, ViewDrawListRowHandler handler, NSDictionary*opts, UIView*target){
    View *v = vbox(nil, opts, target);
    if(data!=nil){
        int idx = 0;
        NSNumber* rowHeight = opts&&opts[@"rowHeight"]!=nil?opts[@"rowHeight"]:@44;
        for(NSDictionary *d in data){
            View *row = vbox(nil, @{@"h":rowHeight,@"w":@320}, nil);
            handler(d, row, idx);
            [row appendTo:v];
            idx++;
        }
    }
    return v;
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

@implementation Borders

-(id)initWithTarget:(View*)v{
    self = [super initWithFrame:v.bounds];
    //self.bounds = v.bounds;
    Border *dummy = [Border borderWithStyle:@"0"];
    _sides = [[NSMutableArray alloc] initWithArray:@[dummy, dummy, dummy, dummy]];
    _radius = 0;
    _target = v;
    _hasBorder = NO;
    _customized = NO;
    self.opaque = NO;
    return self;
}
/**
 format :width color/image corner-radius
 format(use image) : 1 myline.png 4
 format(use rgbcolor) : 1 213,204,222
 format(use hexcolor) : 1 #CCFF33 2
*/
-(void) add:(NSString*)style side:(int)side{
    if(_target.isRoot)
        return;
    
    Border *b= [Border borderWithStyle:style];
    
    if(b.width>0){_hasBorder = YES;}
    
    float w = _target.contentRect.size.width;
    float h = _target.contentRect.size.height;
    float xOffset=0,yOffset=0;
    
    if(side==-1){
        [self.sides setArray:@[b,b,b,b]];
        yOffset = b.width*2;
        xOffset = b.width*2;
    }else{
        _customized = YES;
        [_sides setObject:b atIndexedSubscript:side];
        xOffset = side%2==0 ? b.width:0;
        yOffset = side%2==1 ? b.width:0;
    }

    //resize frame
    float left = ((Border*)_sides[0]).width;
    float top = ((Border*)_sides[1]).width;
    float right = ((Border*)_sides[2]).width;
    float bottom = ((Border*)_sides[3]).width;

    _target.frame = CGRectMake(_target.contentRect.origin.x, _target.contentRect.origin.y,
                               w+left+right, h+top+bottom);
    _target.content.frame = CGRectMake(left,top,w,h);
    self.frame = _target.bounds;
    
}


-(void)drawRect:(CGRect)rect{
    if(!_hasBorder)
        return;
    
    if(_radius==0)
        _radius = _target.cornerRadius;
    
    //[super drawRect:rect];
    float left = ((Border*)_sides[0]).width;
    float top = ((Border*)_sides[1]).width;
    float right = ((Border*)_sides[2]).width;
    float bottom = ((Border*)_sides[3]).width;
    float w = self.bounds.size.width;
    float h = self.bounds.size.height;
    
    if(!_customized){
        Border *b = ((Border*)_sides[0]);
        self.layer.borderWidth = b.width;
        self.layer.borderColor = b.color.CGColor;
        self.layer.cornerRadius = _radius;
        //_target.layer.masksToBounds = YES;
        _target.content.cornerRadius = _radius;
    }else{
        if(left+right+top+bottom>0){
            //self.layer.masksToBounds = NO;
            float cx = left>0&&right>0 ? left/(left+right)*w: w/2;
            float cy = top>0&&bottom>0 ? top/(top+bottom)*h: h/2;
            
            float m[4][10]  =  {
                {0,0,   _radius,0,    cx,cy,    _radius,h,      0,h},
                {w,0,   w,_radius,    cx,cy,    0,_radius,      0,0},
                {w,h,   w-_radius,h,  cx,cy,    w-_radius,0,    w,0},
                {0,h,   0,h-_radius,  cx,cy,    w,h-_radius,    w,h}
            };
            
            for (int side=0;side<=3;side++) {
                Border* border = _sides[side];
                Border* prev = side==0 ? _sides[3] : _sides[side-1];
                Border* next = side>=3 ? _sides[0]:_sides[side+1];
                
                if(border.width>0){
                    if(_radius>border.width && (prev.width==0 || next.width==0)){
                        if(prev.width==0 && next.width==0){
                            [self drawPoints:m[side] size:5 fillColor:border.color strokeColor:nil strokeWidth:0];
                        }else if(prev.width>0 && next.width==0){
                            float points[] = {m[side][0],m[side][1],m[side][2],m[side][3],m[side][4],m[side][5],m[side][8],m[side][9]};
                            [self drawPoints:points size:4 fillColor:border.color strokeColor:nil strokeWidth:0];
                        }else if(prev.width==0 && next.width>0){
                            float points[] = {m[side][0],m[side][1],m[side][4],m[side][5],m[side][6],m[side][7],m[side][8],m[side][9]};
                            [self drawPoints:points size:4 fillColor:border.color strokeColor:nil strokeWidth:0];
                        }
                    }else{
                        float points[] = {m[side][0],m[side][1],m[side][4],m[side][5],m[side][8],m[side][9]};
                        [self drawPoints:points size:3 fillColor:border.color strokeColor:nil strokeWidth:0];
                    }
                }
            }
            
            
        }
        
        CGMutablePathRef path = CGPathCreateMutable();
        CGPathMoveToPoint(path, NULL, MAX(left,_radius), top);
        CGPathAddLineToPoint(path, NULL, w-MAX(right,_radius), top);
        CGPathAddQuadCurveToPoint(path, NULL, w-right, top, w-right, MAX(top,_radius));
        CGPathAddLineToPoint(path, NULL, w-right, h-MAX(bottom,_radius));
        CGPathAddQuadCurveToPoint(path, NULL, w-right, h-bottom, w-MAX(right,_radius), h-bottom);
        CGPathAddLineToPoint(path, NULL, MAX(left,_radius), h-bottom);
        CGPathAddQuadCurveToPoint(path, NULL, left, h-bottom, left, h-MAX(bottom,_radius));
        CGPathAddLineToPoint(path, NULL, left, MAX(top,_radius));
        CGPathAddQuadCurveToPoint(path, NULL, left, top, MAX(left,_radius), top);
        CGPathCloseSubpath(path);
    
        CAShapeLayer *mask = [CAShapeLayer layer];
        mask.frame = CGRectMake(-1*left, -1*top, self.frame.size.width, self.frame.size.height);
        mask.path = path;
        _target.content.mask = mask;
        mask.fillColor = [UIColor blackColor].CGColor;
    
        [self clearPath:path];
    }

    self.layer.cornerRadius = _radius;
    self.layer.masksToBounds = YES;

}
/*
-(CGRect) contentRect{
    
    float left = MAX(((Border*)_sides[0]).width, _radius);
    float top = MAX(((Border*)_sides[1]).width, _radius);
    float right = MAX(((Border*)_sides[2]).width, _radius);
    float bottom = MAX(((Border*)_sides[3]).width, _radius);
    float w = self.bounds.size.width;
    float h = self.bounds.size.height;

    return CGRectMake(left, top, w-left-right, h-top-bottom);

};
*/

@end


#pragma mark - InnerShadow

@implementation InnerShadow

-(id) initWithTarget:(View*)v x:(float)x y:(float)y r:(float)r color:(UIColor*)color{
    self = [super initWithFrame:v.bounds];
    self.target = v;
    self.x = x;
    self.y = y;
    self.radius = r;
    self.color = color==nil? [UIColor colorWithRed:0 green:0 blue:0 alpha:1]:color;
    self.clipsToBounds = YES;
    self.layer.cornerRadius = v.cornerRadius;
    self.backgroundColor = [UIColor clearColor];
    
    return self;
}


- (void)drawRect:(CGRect)rect {
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetAllowsAntialiasing(context, YES);
    CGContextSaveGState(context);
    // clip context so shadow only shows on the inside
    CGPathRef inner = [UIBezierPath bezierPathWithRoundedRect:rect cornerRadius:_target.cornerRadius].CGPath;
    CGContextAddPath(context, inner);
    CGContextClip(context);
    
    CGContextAddPath(context, inner);
    CGContextSetShadowWithColor(context, CGSizeMake(_x, _y), _radius, _color.CGColor);
    CGContextSetStrokeColorWithColor(context, [UIColor colorWithWhite:1 alpha:1].CGColor);
    CGContextStrokePath(context);
    CGContextRestoreGState(context);
}

@end


#pragma mark - View
@implementation View

-(id)initWithType:(ViewTypes)type opts:(NSDictionary*)opts target:(UIView*)target{
    
    opts = opts!=nil?opts: @{};
    
    self = [super initWithFrame:CGRectMake(0, 0, 0, 0)];
    
    load_style(nil);
    
    _type = type;
    
    self.backgroundColor = [UIColor clearColor];
    
    _opts = [[NSMutableDictionary alloc] initWithDictionary:opts];
    
    _data = [[NSMutableDictionary alloc] init];
    _attrs = [[NSMutableArray alloc] initWithArray:[self getAttrs:[self class]]];
    _space = (opts[@"space"]==nil) ? 0:[opts[@"space"] intValue];
    
    _ID = (opts[@"id"]==nil) ? nil:[opts[@"id"] stringValue];

    NSArray *superAttrs =[self getAttrs:[target class]];
    [_attrs addObjectsFromArray:superAttrs];
    
    _replacedStyles = [[NSMutableDictionary alloc] init];
    if(target!=nil)
        [self appendTo:target];
    else
        self.frame = [self calculateFrame];
    self.contentRect = self.frame;
    logRect(_ID,self.frame);
    _borders = [[Borders alloc] initWithTarget:self];
    _content = [CAShapeLayer layer];
    _content.frame = self.bounds;
    _content.masksToBounds = YES;

    self.layer.masksToBounds = NO;
    return self;
}

-(void)appendTo:(UIView *)parent{
    if(parent!=nil){
        _idx = [parent.subviews count];
        if(_parent==nil){
            _parent = parent;
            CGRect frame = [self calculateFrame];
            //logRect(@"",frame);
            self.frame = frame;
            [self attr:_opts];

            if(self.txt!=nil){
                [self setText:_txt];
            }
            if(self.src!=nil){
                [self setImage:_src];
            }
            [_parent addSubview:self];
            if(![_parent isKindOfClass:[View class]])
                self.isRoot = YES;
            [self setNeedsDisplay];
        }
    }
}


// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect{
   
   // self.backgroundColor = [UIColor clearColor];
    
    logRect(@"drawrect", rect);

    [_content removeFromSuperlayer];
    [self.layer addSublayer:_content];
    
    
    if(_innerShadow!=nil){
        [_innerShadow removeFromSuperview];
        [self addSubview:_innerShadow];
    }
    if(_borders.hasBorder){
        [self addSubview:_borders];
    }

    //FIXME draw Images && text here
    
    NSLog(@"drawRect %@", self.ID);
    
}



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

#pragma mark - property methods
/*
- (void) setType:(ViewTypes)_type{
    if(self.type){
        //TODO
    }
    switch (_type) {
        case (ViewTypes)BOX:
            break;
        case (ViewTypes)HBOX:
            break;
        case (ViewTypes)VBOX:
            break;
        default:
            break;
    }
    
}
 */

-(void) setBackgroundImage:(NSString *)imageUrl{
    //view.layer.contents = yourImage.CGImage;
    //view.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"background.png"]];
}
-(void) setBackgroundImage:(NSString *)imageUrl fitMode:(UIViewContentMode)mode inRect:(CGRect)rect{

}

-(void) setImage:(NSString *)imageUrl{
    self.src = imageUrl;
    //CGRect rect = [self contentFrame];
    if(_parent!=nil){
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
    }
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

    [self setFont:_opts[@"font"]];
    if(_opts[@"fontSize"]!=nil)
        [self setFontSize: [_opts[@"fontSize"] floatValue]];

    [self setColor:(_opts[@"color"]!=nil)?_opts[@"color"]:nil];

    [self setTextAlign:_opts[@"textAlign"]];

    [_content addSublayer:_textLayer];

}

-(void) setTextAlign:(NSString*)align{
    const NSDictionary * def = @{@"center":kCAAlignmentCenter,@"left":kCAAlignmentLeft,
                                 @"right":kCAAlignmentRight,@"justified":kCAAlignmentJustified};
    if(align!=nil)
        _opts[@"textAlign"] = align;
    NSString *a = (align!=nil && def[align]!=nil) ? def[align]:kCAAlignmentNatural;
    if(_textLayer!=nil){
        [_textLayer setAlignmentMode:a];
    }
    _textLayer.wrapped = (_opts[@"wrapped"] == nil || ![[_opts[@"wrapped"] lowercaseString] isEqualToString:@"false"]);
    _textLayer.truncationMode =(_opts[@"truncate"] == nil || ![[_opts[@"truncate"] lowercaseString] isEqualToString:@"true"]) ?
                    kCATruncationNone: kCATruncationEnd;
    
}

-(void) setFont:(NSString*)font{
    if(_textLayer==nil)
        _textLayer= [[CATextLayer alloc] init];
    NSDictionary *defaultStyle = style(@"*");
    if(defaultStyle!=nil && font==nil){
        font = defaultStyle[@"font"];
    }
    if(font!=nil && ![font isEqualToString:@"default"]){
        float fontSize = defaultStyle!=nil && defaultStyle[@"fontSize"]!=nil ? [defaultStyle[@"fontSize"] floatValue]:14;
        if([font contains:@","]){//@"monaco,12"
            NSArray *fs = [font componentsSeparatedByString:@","];
            font = (NSString*)fs[0];
            NSString *fsize = [(NSString*)fs[1] stringByReplacingOccurrencesOfString:@" " withString:@""];
            fontSize = [fsize floatValue];
        }
        _opts[@"fontName"] = font;
        [_textLayer setFont:(__bridge CFTypeRef)(font)];
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
        NSString *fontName = _opts[@"fontName"]!=nil? _opts[@"fontName"]:@"Helvetica";
        int fontSize = ![_txt isEqual:[NSNull null]] ? [_txt sizeToFit:rect.size font:fontName] : 14;
        NSLog(@"font-size:%d",fontSize);
        [_textLayer setFontSize:fontSize];
    }
}


-(void) setStyle:(NSString *)key value:(id)value{
    
    int ix = [_styles indexOfObject:key];
    switch (ix) {
        case 0://shadow
            //format: x y radius color opacity
            [self setShadow:(NSString*)value];
            break;
        case 1://border
            [self setBorder:-1 style:value];
            break;
        case 2://borderLeft
            [self setBorder:0 style:value];
            break;
        case 3://borderTop
            [self setBorder:1 style:value];
            break;
        case 4://borderRight
            [self setBorder:2 style:value];
            break;
        case 5://borderBottom
            [self setBorder:3 style:value];
            break;
        case 6://bgcolor
            [self setBgcolor:value];
            break;
        case 7://rotate
            //format :angel
            [self setRotate:value];
            break;
        case 8://scale:
            //format :x,y
            [self setScale:value];
            break;
        case 9://flip
            //format :@H/@V
            if ([value isEqualToString:@"H"]) {
                self.transform = CGAffineTransformMake(self.transform.a * -1, 0, 0, 1, self.transform.tx, 0);
            }else if([value isEqualToString:@"V"]){
                self.transform = CGAffineTransformMake(1, 0, 0, self.transform.d * -1, 0, self.transform.ty);
            }
            break;
        case 10://alpha
            self.alpha = [(NSNumber*)value floatValue];
            break;
        /*
         text styles have to be set in setText.
        case 11://font
            [self setFont:value];
            break;
        case 12://fontSize
            [self setFont:value];
            break;
        case 13://color
            [self setColor:value];
            break;
        case 14://textAlign
            [self setTextAlign:value];
            break;
        */
        case 15://align
            //TODO 8ways , only set on parent.
            break;
            
        case 16://padding
            
            break;
        case 17://paddingLeft
            break;
        case 18://paddingTop
            break;
        case 19://paddingRight
            break;
        case 20://paddingBottom
            break;
        default:
            //[self setValue:value forKey:key];
            break;
    }
}

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

-(View*) css:(NSString *)styles{
    if(styles!=nil){
        [self cssClear];
        NSArray *slist = [[styles regexpReplace:@"  +" replace:@""] componentsSeparatedByString:@" "];
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
}

#pragma mark - private methods

-(void)setBorder:(int)side style:(NSString*)style{
    [_borders add:style side:side];
}

-(void)setCornerRadius:(float)radius{
    _cornerRadius = radius;
    _borders.radius = radius;
    //_content.cornerRadius = radius;
}

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
            gradient.cornerRadius = _cornerRadius;
            
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
 format : x y radius colorStr opacity
 */

-(void)setShadow:(NSString*)shadow{
    //TODO inset
    shadow = [shadow regexpReplace:@"  +" replace:@" "];
    //_opts[@"shadow"] = shadow;
    NSArray *parts = [shadow componentsSeparatedByString:@" "];
    int psize =[parts count];
    if(psize>=4){
        BOOL isInner = [parts[0] isEqualToString:@"inset"];
        
        int offset = isInner ? 1:0;
        float x = [parts[0+offset] floatValue];
        float y = [parts[1+offset] floatValue];
        float r = [parts[2+offset] floatValue];

        UIColor *color = psize>=4+offset? [parts[3+offset] colorValue]:[UIColor colorWithWhite:0 alpha:0.3];
    
        if(isInner){
            _innerShadow = [[InnerShadow alloc] initWithTarget:self x:x y:y r:r color:color];
        }else{
            self.layer.shadowOffset = CGSizeMake(x, y);
            self.layer.shadowRadius = r;
            self.layer.shadowColor = color.CGColor;
            self.layer.shadowOpacity = [parts count]>4? [parts[5] floatValue]:0.7;
        }
        
        self.clipsToBounds = NO;

    }else{
        self.layer.shadowOffset = CGSizeZero;
        self.layer.shadowRadius = 0;
        self.layer.shadowColor = [UIColor clearColor].CGColor;
        self.layer.shadowOpacity = 0;
    }

    
}

-(void) cssClear{
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
    }
    
}


-(CGRect)contentFrame{
    return CGRectMake(_paddingLeft+_cornerRadius, _paddingTop+_cornerRadius,
                      self.frame.size.width-_paddingLeft-_paddingRight-_cornerRadius*2,
                      self.frame.size.height-_paddingTop-_paddingBottom-_cornerRadius*2);
}


- (CGRect)calculateFrame{
    float x = _opts[@"x"]?[_opts[@"x"] floatValue]+_marginLeft:_marginLeft;
    float y = _opts[@"y"]?[_opts[@"y"] floatValue]+_marginTop:_marginTop;
    float w= _opts[@"w"]?[_opts[@"w"] floatValue]:0;
    float h= _opts[@"h"]?[_opts[@"h"] floatValue]:0;
    
    if(_parent!=nil){
        float pspace = ([_parent isKindOfClass:[View class]])? ((View*)_parent).space:0;
        if(_type==VBOX){
            w = _parent.bounds.size.width-_marginLeft-_marginRight;
            float top = _marginTop;
            for(UIView* v in _parent.subviews)
                top += v.bounds.size.height + pspace;
            y = top;
            if(h==0) h=_parent.bounds.size.height-_marginTop-_marginBottom;
        }else if(_type==HBOX){
            h = _parent.bounds.size.height-_marginTop-_marginBottom;
            float left = _marginLeft;
            for(UIView* v in _parent.subviews)
                left += v.bounds.size.width + pspace;
            x = left;
            if(w==0) h=_parent.bounds.size.width-_marginLeft-_marginRight;
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
    NSLog(@"Gesture :  %@",className);
}

-(void) switchEditingMode{
    
    if(_textField!=nil){
        if(_textField.hidden){
            [self insertSubview:_textField belowSubview:_borders];
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
    _editable = editable;
    if(_textField==nil){
        CGRect rect = CGRectMake(_cornerRadius, _cornerRadius,
                                 _contentRect.size.width-2*_cornerRadius,
                                 _contentRect.size.height-2*_cornerRadius);
        
        NSDictionary * styles = style(@"*");
        NSString *fontName = _opts[@"fontName"]!=nil? _opts[@"fontName"]:@"Helvetica";
        float fontSize = _opts[@"fontSize"]?[_opts[@"fontSize"] floatValue]:
            (styles!=nil && styles[@"fontSize"]!=nil? [styles[@"fontSize"] floatValue]:14);
        const NSArray * aligns = (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) ?
            @[@"left",@"center",@"right", @"justified", @"natrual"]:@[@"left",@"right",@"center", @"justified", @"natrual"];
        NSString *align = _opts[@"textAlign"]!=nil?_opts[@"textAlign"]:@"left";
        
        if(_textLayer.wrapped ||![@"false" isEqualToString:_opts[@"wrapped"]]){
            UITextView* t = [[UITextView alloc] initWithFrame:rect];
            t.delegate = self;
            t.textAlignment = [aligns indexOfObject:align];
            t.font = [UIFont fontWithName:fontName size:fontSize];
            t.editable = YES;
            _textField = t;
        }else{
            UITextField* t = [[UITextField alloc] initWithFrame:rect];
            t.delegate = self;
            if(_opts[@"placeHolder"]!=nil)
                t.placeholder = _opts[@"placeHolder"];
            t.textAlignment = [aligns indexOfObject:align];
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
    UIView *v = _parent;
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
    NSLog(@"textFieldDidEndEditing");
    _textField.hidden = YES;
    [self setText:((UITextField*)_textField).text];
    View *root = [self root];
    if(root){
        float orgOffset = [root get:@"orgContentOffset"]!=nil?[[root get:@"orgContentOffset"] floatValue]:0;
        [root setContentOffset:CGPointMake(0, orgOffset) animated:YES];
    }
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField{
    NSLog(@"textFieldShouldReturn");
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
