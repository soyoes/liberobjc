//
//  View.h
//  liberobjc
//
//  Created by soyoes on 7/3/13.
//  Copyright (c) 2013 soyoes. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>

//#import "Styles.h"

typedef struct {
    //Class *isa;
    char * ID;
    char * name;//classname
    
    char * layout;
    
    float x,y,w,h;
    char * border, *borderLeft, *borderRight, *borderTop, *borderBottom;
    float cornerRadius;
    char * outline, *outlineColor;
    float outlineSpace, outlineWidth;
    char * shadow;
    
    float alpha;//1..100
    char * bgcolor;
    
    float padding, paddingLeft, paddingTop, paddingRight, paddingBottom;
    float margin, marginLeft, marginTop, marginRight, marginBottom;
    float space;
    
    float scaleX, scaleY;//<0.00 & <x
    float rotate;
    char * flip; //FIXME
    
    char * font;
    char * fontName;
    char * fontStyle;
    float fontSize;
    char * color;
    char * textAlign;
    bool nowrap;
    bool truncate;
    bool editable;
    
    char *placeHolder;
    
    float rowHeight;
}Styles;

//struct StyleRef;

/*
@interface StylesE
@property NSString* name;//classname
@property NSString * layout;
@property float x,y,w,h;
@property NSString * border, borderLeft, borderRight, borderTop, borderBottom;
@property float cornerRadius;
@property NSString * outline, *outlineColor;
@property float outlineSpace, outlineWidth;
@property NSString * shadow;
@property float alpha;
@property NSString * bgcolor;
@property float padding, paddingLeft, paddingTop, paddingRight, paddingBottom;
@property float margin, marginLeft, marginTop, marginRight, marginBottom;
@property float space;
@property float scaleX, scaleY;
@property float rotate;
@property NSString * flip; //FIXME
@property NSString * fontName;
@property NSString * fontStyle;
@property float fontSize;
@property UIColor * color;
@property NSString * textAlign;
@property bool wrapped;
@property bool truncate;
@property bool editable;
@property float rowHeight;
@end
 */




typedef struct {
    char * left;
    
} AlignMapping;

typedef enum {
    BOX=0,
    HBOX=1,
    VBOX=2,
    LABEL=11,
    IMAGE=12,
    
} ViewTypes;

typedef void(^ViewGestureHandler)(UIGestureRecognizer*);


@class View;

@interface Border : NSObject
@property  UIColor *color;
@property  float width;
@property  float radius;
+(Border*) borderWithStyle:(NSString*)style;

@end

@interface View : UIScrollView <UITextFieldDelegate,UITextViewDelegate>


@property  ViewTypes type;

@property  int idx;
@property  NSString  *ID;
@property  NSMutableDictionary *data;
@property  NSMutableDictionary *gestures;
@property  Styles styles;

@property  BOOL isRoot;
//@property  BOOL editable;

@property  NSString *txt;
@property  CATextLayer *textLayer;
@property  UIView *textField;

@property  NSString *src;
@property  CALayer *backgroundLayer;

@property  CGRect contentRect;
@property Border *borderLeft, *borderRight, *borderTop, *borderBottom;
@property  BOOL isBorderCustomized;

@property  CAShapeLayer *content;

-(void)appendTo:(UIView *)_parent;
-(id)initWithType:(ViewTypes)type styles:(Styles)styles target:(UIView*)target;

-(void) setBackgroundImage:(NSString *)imageUrl;
-(void) setBackgroundImage:(NSString *)imageUrl fitMode:(UIViewContentMode)mode inRect:(CGRect)rect;

-(void) setImage:(NSString *)imageUrl;
//-(void) setStyle:(NSString *)key value:(id)value;
-(void) setText:(NSString *)text;
//-(View*) attr:(NSString*)key value:(id)value;


-(View*) bind:(NSString*)event handler:(ViewGestureHandler)handler options:(NSDictionary*)options;
-(View*) unbind:(NSString*)event;
//-(View*) css:(NSString *)styles;
-(View*) root;

-(id) get:(NSString *)keyPath;
-(void) set:(NSString *)keyPath value:(id)value;
-(void) del:(NSString*)keyPath;

@end

#pragma mark - functions
View* box(ViewTypes type, id subs, Styles styles, UIView*target);
View* vbox(id subs, Styles style, UIView*target);
View* hbox(id subs, Styles style, UIView*target);
View* label(NSString*src, Styles style, UIView*target);
View* img(NSString*src, Styles style, UIView*target);

typedef void(^ViewDrawListRowHandler)(NSDictionary*,View*,int);
View* list(NSArray*data, ViewDrawListRowHandler handler, Styles styles, UIView*target);

void load_style(NSString* style_file);
NSDictionary* style(NSString* style);
NSString * str(char * cs);
char * cstr(NSString * cs);

//View* grids(NSArray*data, NSDictionary*opts, UIView*target);

