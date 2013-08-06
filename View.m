//
//  View.m
//  screater
//
//  Created by soyoes on 7/3/13.
//  Copyright (c) 2013 soyoes. All rights reserved.
//

/*
 TASK
 
 * align(layer.contentsGravity?)
 * mask(layer.masksToBounds, layer.mask)
 * gradient test only
 * layer.doubleSided (CATransformLayer)
 * layer.backgroundFilters (CIFilter)
 * animate
 + layerClass   -> core animation layer
 layer CALayer :: Appearance properties
 */

#import "View.h"
#import "NSString+common.h"
#import "NSDictionary+common.h"
#import <objc/runtime.h>
#import <QuartzCore/QuartzCore.h>
#include <math.h>

#define logRect(name,rect) (NSLog(@"--\nRECT:%@ = (%f,%f), (%f,%f) \n--",(name),(rect.origin.x),(rect.origin.y),(rect.size.width),(rect.size.height)))
#define logSize(name,size) (NSLog(@"--\nRECT:%@ = (%f,%f) \n--",(name),(size.width),(size.height)))
#define logPoint(name,p) (NSLog(@"--\nRECT:%@ = (%f,%f) \n--",(name),(p.x),(p.y)))

#define _styles @[@"shadow", @"border",@"borderLeft",@"borderTop",@"borderRight",@"borderBottom", @"bgcolor", @"rotate", @"scale", @"flip", @"alpha", @"font", @"fontSize", @"color"]
#define _events @[@"tap", @"pinch", @"rotation", @"swipe", @"pan", @"longpress"]


#define radians(degrees) (degrees * M_PI/180)

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
        //format : fontname,fontsize
 
    color: text color
        //color format @see bgcolor,
 
    css:class name in styles.json
 
 
 */


static NSDictionary * _stylesheets;

#pragma mark - functions

View* box(ViewTypes type, id subs, NSDictionary*opts, UIView*target){
    View *v = [[View alloc] initWithType:type opts:opts target:target];
    if(subs!=nil){
        if([subs isKindOfClass:[View class]]){
            [(View*)subs appendTo:v];
        }else if([subs isKindOfClass:[NSArray class]]){
            for(View* sub in subs){
                [sub appendTo:v];
            }
        }
    }
    return v;
}
/**
 @example
 vbox(@[
     hbox(nil, @{@"w":@98,@"bgcolor":[UIColor redColor]}, nil),
     hbox(nil, @{@"w":@98,@"bgcolor":[UIColor yellowColor]}, nil),
     hbox(nil, @{@"w":@98,@"bgcolor":[UIColor greenColor]}, nil)
 ], @{@"padding":@10,@"h":@100,@"space":@3},self.view);
 
 vbox(@[
     vbox(nil, @{@"h":@40,@"bgcolor":[UIColor blueColor]}, nil),
     vbox(nil, @{@"h":@40,@"bgcolor":[UIColor orangeColor]}, nil),
     vbox(nil, @{@"h":@40,@"bgcolor":[UIColor purpleColor]}, nil)
 ], @{@"padding":@10,@"h":@140,@"space":@5},self.view);
 
 */
View* vbox(id subs, NSDictionary*opts, UIView*target){
    return box(VBOX, subs, opts, target);
}
/*
 hbox(nil, @{@"w":@320,@"h":30,@"bgcolor":[UIColor yellowColor],
        @"borderBottom":@"5 #000000"} , self.view);
 */
View* hbox(id subs, NSDictionary*opts, UIView*target){
    return box(HBOX, subs, opts, target);
}
/*
 @example
 vbox(@[
    label(@"Its a test", @{@"color":[UIColor redColor], @"css":@"test"}, nil),
 ], @{@"padding":@10,@"w":@320,@"h":@40},self.view);
 */
View* label(NSString*text, NSDictionary*opts, UIView*target){
    View *v = box(VBOX, nil, opts, target);
    [v setText:text];
    return v;
}
/*
 @example
 
 vbox(@[
     [img(@"layout_detail.png", @{}, nil) 
                bind:@"tap" handler:^void (UIGestureRecognizer* o){
                        View *v = (View *)o.view;
                        if([v.src isEqualToString:@"layout_detail.png"])
                            [v setImage:@"layout_detail_b.png"];
                        else
                            [v setImage:@"layout_detail.png"];
                        } options:nil],
     ], @{@"padding":@10,@"w":@100,@"h":@100},self.view);
 
 */
View* img(NSString*src, NSDictionary*opts, UIView*target){
    View *v = box(VBOX, nil, opts, target);
    [v setImage:src];
    return v;
}
/*
 @example
 list(@[@{@"v":@"row 1"},@{@"v":@"row 2"},@{@"v":@"row 3"}], 
        ^void(NSDictionary*d, View* row,int idx){
            [row setText:d[@"v"]];
        }, nil, self.view);
 
 */
View* list(NSArray*data, ViewDrawListRowHandler handler, NSDictionary*opts, UIView*target){
    View *v = vbox(nil, opts, target);
    if(data!=nil){
        int idx = 0;
        NSNumber* rowHeight = opts&&opts[@"rowHeight"]!=nil?opts[@"rowHeight"]:@44;
        for(NSDictionary *d in data){
            View *row = vbox(nil, @{@"h":rowHeight,@"w":@320}, v);
            handler(d, row, idx);
            idx++;
        }
    }
    return v;
}

#pragma mark - View

@implementation View


@synthesize ID, type, opts, data, padding, margin, space, idx, attrs, parent, content, txt, textLayer, src, imgLayer, gestures, defaultStyles, replacedStyles;

-(id)initWithType:(ViewTypes)_type opts:(NSDictionary*)_opts target:(UIView*)target{
    
    _opts = _opts!=nil?_opts: @{};
    
    self = [super initWithFrame:CGRectMake(0, 0, 0, 0)];
    if(_stylesheets==nil)
        [self loadStyles];
    type = _type;
    opts = [[NSMutableDictionary alloc] initWithDictionary:_opts];
    data = [[NSMutableDictionary alloc] init];
    attrs = [[NSMutableArray alloc] initWithArray:[self getAttrs:[self class]]];

    space = (opts[@"space"]==nil) ? 0:[opts[@"space"] intValue];
    ID = (opts[@"id"]==nil) ? nil:[opts[@"id"] stringValue];
    
    
    NSArray *superAttrs =[self getAttrs:[target class]];
    [attrs addObjectsFromArray:superAttrs];
    
    replacedStyles = [[NSMutableDictionary alloc] init];
    
    [self appendTo:target];
    
    return self;
}

-(void)appendTo:(UIView *)_parent{
    if(_parent!=nil){
        margin = [_parent isKindOfClass:[View class]]?((View*)_parent).padding:0;
        idx = [_parent.subviews count];
        
        if(self.parent==nil){
            self.parent = _parent;
            CGRect frame = [self calculateFrame];
            //logRect(@"",frame);
            self.frame = frame;
            [self attr:opts];

            if(self.txt!=nil){
                [self setText:txt];
            }
            if(self.src!=nil){
                [self setImage:src];
            }
            [_parent addSubview:self];
        }
    }
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/
-(NSArray*)getAttrs:(id)target{
    unsigned int outCount, i;
    objc_property_t *properties = class_copyPropertyList(target, &outCount);
    NSMutableArray *_attrs = [[NSMutableArray alloc] init];
    for(i = 0; i < outCount; i++) {
    	objc_property_t property = properties[i];
    	const char *propName = property_getName(property);
    	if(propName) {
    		//const char *propType = getPropertyType(property);
    		NSString *propertyName = [NSString stringWithUTF8String:propName];
    		//NSString *propertyType = [NSString stringWithCString:propType];
            [_attrs addObject:propertyName];
    	}
    }
    free(properties);
    return _attrs;
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
    if(parent!=nil){
        /*
         TODO
         - (CGSize)sizeThatFits:(CGSize)size //calculate a size to make the superview to fit its all subviews
         - (void)sizeToFit //auto adjust super view to fit its all subviews
         */
        UIImage *img = [UIImage imageNamed:imageUrl];
        if(imgLayer == nil)
            imgLayer = [[CALayer alloc] init];
        //TODO adjust image size
        [imgLayer setFrame:self.bounds];
        imgLayer.contentsGravity = kCAGravityCenter;
        imgLayer.contents = (__bridge id)(img.CGImage);
        [self.layer addSublayer:imgLayer];
    }
}

-(void) setText:(NSString *)_text{
    self.txt = _text;
    if(parent!=nil){
        /*
         TODO 
         - (CGSize)sizeThatFits:(CGSize)size //calculate a size to make the superview to fit its all subviews
         - (void)sizeToFit //auto adjust super view to fit its all subviews
         */
        CGRect rect = [self contentFrame];
        //logRect(@"txt",rect);
        if(textLayer==nil)
            textLayer= [[CATextLayer alloc] init];
        if ([textLayer respondsToSelector:@selector(setContentsScale:)]){
            textLayer.contentsScale = [[UIScreen mainScreen] scale];
        }

        [textLayer setFrame:rect];
        [textLayer setString:_text];
    
        [self setFont:opts[@"font"]];
        if(opts[@"fontSize"]!=nil)
            [self setFontSize: [opts[@"fontSize"] floatValue]];

        [self setColor:(opts[@"color"]!=nil)?opts[@"color"]:@"#000000"];
        
        [textLayer setAlignmentMode:kCAAlignmentCenter];
        
        [self.layer addSublayer:textLayer];
    }
}

-(void) setFont:(NSString*)font{
    if(textLayer==nil)
        textLayer= [[CATextLayer alloc] init];
    if(font!=nil && ![font isEqualToString:@"default"]){
        int fontSize = 14;
        if([font contains:@","]){
            NSArray *fs = [font componentsSeparatedByString:@","];
            font = (NSString*)fs[0];
            NSString *fsize = [(NSString*)fs[1] stringByReplacingOccurrencesOfString:@" " withString:@""];
            fontSize = [fsize intValue];
        }
        opts[@"fontName"] = font;
        [textLayer setFont:(__bridge CFTypeRef)(font)];
        [textLayer setFontSize:fontSize];
    }else{
        [self setFontSize:-1];//adjust size auto;
    }

}

-(void) setColor:(id)color{
    if(textLayer==nil)
        textLayer= [[CATextLayer alloc] init];
    if(color!=nil){
        UIColor * cl = ([color isKindOfClass:[UIColor class]])? (UIColor *)color:
                            ([color isKindOfClass:[NSString class]]? [color colorValue]:[UIColor blackColor]);
        [textLayer setForegroundColor:[cl CGColor]];
    }else{
        [textLayer setForegroundColor:[[UIColor blackColor] CGColor]];
    }
}

-(void)setFontSize:(float)s{
    if(textLayer==nil)
        textLayer= [[CATextLayer alloc] init];
    if(s>0)
        [textLayer setFontSize:s];
    else{
        CGRect rect = [self contentFrame];
        NSString *fontName = opts[@"fontName"]!=nil? opts[@"fontName"]:@"Helvetica";;
        int fontSize = [txt sizeToFit:rect.size font:fontName];
        NSLog(@"font-size:%d",fontSize);
        [textLayer setFontSize:fontSize];
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
            [self setBorder:(NSString*)value];
            break;
        case 2://borderLeft
            [self setSideBorder:0 border:value];
            break;
        case 3://borderTop
            [self setSideBorder:1 border:value];
            break;
        case 4://borderRight
            [self setSideBorder:2 border:value];
            break;
        case 5://borderBottom
            [self setSideBorder:3 border:value];
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
            //[self setFont:value];
            break;
        case 12://fontSize
            //[self setFont:value];
            break;
        case 13://color
            //[self setColor:value];
            break;
        */
        default:
            //[self setValue:value forKey:key];
            break;
    }
}

//Private method
-(View*) attr:(NSDictionary*)_opts{
    NSMutableArray * stylesToSet = [NSMutableArray array];
    for(NSString * k in _opts){//set properties first
        id v = _opts[k];
        if([_styles indexOfObject:k]!=NSNotFound){
            [stylesToSet addObject:k];
        }
        if([k isEqualToString:@"css"]){
            [self css:v];
        }else
            [self attr:k value:v];
    }
    for (NSString * k in stylesToSet) {//set styles right now
        id v = _opts[k];
        if(defaultStyles==nil)defaultStyles=[[NSMutableDictionary alloc] init];
        [defaultStyles setValue:v forKey:k];
        [self setStyle:k value:v];
    }
    
    return self;
}
-(View*) attr:(NSString*)key value:(id)value{
    if([attrs indexOfObject:key]!=NSNotFound){
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
    if(gestures==nil){
        gestures=[[NSMutableDictionary alloc] init];
    }
    gestures[event] = (id) handler;
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
    if(gestures!=nil){
        [gestures removeObjectForKey:event];
    }
    return self;
}

-(View*) css:(NSString *)styles{
    if(styles!=nil){
        [self cssClear];
        NSArray *slist = [[styles regexpReplace:@"  +" replace:@""] componentsSeparatedByString:@" "];
        for (NSString *stylename in slist) {
            NSDictionary *style =[_stylesheets objectForKey:stylename];
            if(style!=nil){
                for (NSString *key in style) {
                    [self setStyle:key value:style[key]];
                }
            }
        }
    }else{
        [self cssClear];
    }
    return self;
}

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
            gradient.cornerRadius = self.layer.cornerRadius;
            
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
            [self.layer insertSublayer:gradient atIndex:0];
        }else
            self.backgroundColor = [value colorValue];
        
    }else if([value isKindOfClass:[UIColor class]])
        self.backgroundColor = value;
    
    
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
    NSArray *parts = [shadow componentsSeparatedByString:@" "];
    if([parts count]>=4){
        float x = [parts[0] floatValue];
        float y = [parts[1] floatValue];
        float r = [parts[2] floatValue];
        self.layer.shadowOffset = CGSizeMake(x, y);
        self.layer.shadowRadius = r;
        self.layer.shadowColor = [parts[3] colorValue].CGColor;
        self.layer.shadowOpacity = [parts count]>4? [parts[5] floatValue]:0.7;
    }else{
        self.layer.shadowOffset = CGSizeZero;
        self.layer.shadowRadius = 0;
        self.layer.shadowColor = [UIColor clearColor].CGColor;
        self.layer.shadowOpacity = 0;
    }
    
}
/**
 //format :width color/image corner-radius
 //format(use image) : 1 myline.png 4
 //format(use rgbcolor) : 1 213,204,222
 //format(use hexcolor) : 1 #CCFF33 2
 */
-(void)setBorder:(NSString*)border{
    border = [border regexpReplace:@"  +" replace:@" "];
    NSArray *parts = [border componentsSeparatedByString:@" "];
    float w = [parts[0] floatValue];
    if(w>0){
        self.layer.borderWidth = w;
        if([parts count]>1){
            NSString *cl = parts[1];
            if([cl contains:@","]||[cl contains:@"#"]){//color
                self.layer.borderColor = [cl colorValue].CGColor;
            }else{//image
                [[UIColor colorWithPatternImage:[UIImage imageNamed:cl]] CGColor];
            }
            //TODO radius
            if([parts count]>2){
                int rd = [parts[2] intValue];
                if(rd>0) self.layer.cornerRadius = rd;
            }
        }
    }else{
        self.layer.borderWidth = 0;
        self.layer.borderColor = [UIColor clearColor].CGColor;
        self.layer.cornerRadius = 0;
    }
}

-(void) setSideBorder:(int)side border:(NSString*)border{
    CALayer *bdlayer = [CALayer layer];
    border = [border regexpReplace:@"  +" replace:@" "];
    NSArray *parts = [border componentsSeparatedByString:@" "];
    float w = [parts[0] floatValue];
    if(w>0){
        if([parts count]>1){
            NSString *cl = parts[1];
            UIColor *color;
            if([cl contains:@","]||[cl contains:@"#"]){//color
                color = [cl colorValue];
            }else{//image
                color = [UIColor colorWithPatternImage:[UIImage imageNamed:cl]];
            }
            bdlayer.backgroundColor = color.CGColor;
        }
       
        switch (side) {
            case 0://left
                bdlayer.frame = CGRectMake(0, 0, w, self.frame.size.height);
                break;
            case 1://top
                bdlayer.frame = CGRectMake(0, 0, self.frame.size.width, w);
                break;
            case 2://right
                bdlayer.frame = CGRectMake(self.frame.size.width-w, 0, w, self.frame.size.height);

                break;
            case 3://bottom
                bdlayer.frame = CGRectMake(0, self.frame.size.height-w, self.frame.size.width, w);
                break;
            default:
                break;
        }
        [self.layer addSublayer:bdlayer];
        
    }
    
}

-(void) loadStyles{
    if(_stylesheets==nil){
        _stylesheets = [[NSDictionary alloc] dictionaryFromJSONFile:@"styles.json"];
    }
}

-(void) cssClear{
    if(replacedStyles!=nil){
        for (NSString *k in replacedStyles) {
            [self setStyle:k value:replacedStyles[k]];
        }
        [replacedStyles removeAllObjects];
    }
    if(defaultStyles!=nil){
        for (NSString *k in defaultStyles) {
            [self setStyle:k value:defaultStyles[k]];
        }
    }
    
}


-(CGRect)contentFrame{
    return CGRectMake(padding, padding, self.frame.size.width-2*padding, self.frame.size.height-2*padding);
}


- (CGRect)calculateFrame{
    float x = opts[@"x"]?[opts[@"x"] floatValue]+margin:margin;
    float y = opts[@"y"]?[opts[@"y"] floatValue]+margin:margin;
    float w= opts[@"w"]?[opts[@"w"] floatValue]:0;
    float h= opts[@"h"]?[opts[@"h"] floatValue]:0;
    
    if(parent!=nil){
        float pspace = ([parent isKindOfClass:[View class]])? ((View*)parent).space:0;
        if(type==VBOX){
            w = parent.bounds.size.width-2*margin;
            float top = margin;
            for(UIView* v in parent.subviews)
                top += v.bounds.size.height + pspace;
            y = top;
            if(h==0) h=parent.bounds.size.height-2*margin;
        }else if(type==HBOX){
            h = parent.bounds.size.height-2*margin;
            float left = margin;
            for(UIView* v in parent.subviews)
                left += v.bounds.size.width + pspace;
            x = left;
            if(w==0) h=parent.bounds.size.width-2*margin;
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
    NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:@"(UI|GestureRecognizer)" options:NSRegularExpressionCaseInsensitive error:nil];
    className = [[regex stringByReplacingMatchesInString:className options:0 range:NSMakeRange(0, [className length]) withTemplate:@""] lowercaseString];

    if(gestures!=nil && gestures[className]!=nil){
        ViewGestureHandler handler = gestures[className];
        handler(ges);
    }
    NSLog(@"Gesture :  %@",className);
}
#pragma mark - data methods

- (void) set:(NSString*)keyPath value:(id)value{
    [data setValue:value forKeyPath:keyPath];
}

- (id) get:(NSString*)keyPath{
    return [data valueForKeyPath:keyPath];
}

- (void) del:(NSString*)keyPath{
    [data removeObjectForKey:keyPath];
}





@end
