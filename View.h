//
//  View.h
//  liberobjc
//
//  Created by soyoes on 7/3/13.
//  Copyright (c) 2013 soyoes. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>

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
@property (nonatomic) UIColor *color;
@property (nonatomic) int width;
@property (nonatomic) int radius;
+(Border*) borderWithStyle:(NSString*)style;
@end

@interface Borders : UIView
@property (nonatomic) NSMutableArray *sides;
@property (nonatomic) int radius;
@property (nonatomic) BOOL customized;
@property (nonatomic) BOOL hasBorder;
@property (nonatomic) View* target;
//@property (nonatomic) int left,top,right,bottom;
-(id) initWithTarget:(View*)v;
-(void) add:(NSString*)style side:(int)side;
//-(CGRect) contentRect;

@end

@interface InnerShadow : UIView
@property (nonatomic) float y;
@property (nonatomic) float x;
@property (nonatomic) float radius;
@property (nonatomic) UIColor *color;
@property (nonatomic) View* target;
-(id) initWithTarget:(View*)v x:(float)x y:(float)y r:(float)r color:(UIColor*)color;
@end


@interface View : UIScrollView <UITextFieldDelegate,UITextViewDelegate>


@property (nonatomic) ViewTypes type;
@property (nonatomic) NSString  *ID;
@property (nonatomic,retain) NSMutableDictionary *opts;
@property (nonatomic,retain) NSMutableDictionary *data;
@property (nonatomic) NSMutableDictionary *gestures;
@property (nonatomic) NSMutableArray  *attrs;
@property (nonatomic) UIView *parent;

@property (nonatomic) BOOL isRoot;
@property (nonatomic) BOOL editable;

@property (nonatomic) NSString *txt;
@property (nonatomic,retain) CATextLayer *textLayer;
@property (nonatomic,retain) UIView *textField;

@property (nonatomic) NSString *src;
@property (nonatomic) CALayer *backgroundLayer;

@property (nonatomic) CGRect contentRect;

//default style options from vbox , hbox ...
@property (nonatomic) NSMutableDictionary* defaultStyles;
//original style values that override by css method
@property (nonatomic) NSMutableDictionary* replacedStyles;

@property (nonatomic) int idx;

@property (nonatomic) Borders *borders;
@property (nonatomic) CAShapeLayer *content;

@property (nonatomic) InnerShadow *innerShadow;
@property (nonatomic) float cornerRadius;
//paddings works only for image|text
@property (nonatomic) float paddingLeft, paddingTop, paddingRight, paddingBottom;
@property (nonatomic) float marginLeft, marginTop, marginRight, marginBottom;

@property (nonatomic) float space; //space between items(subviews)

-(void)appendTo:(UIView *)_parent;
-(id)initWithType:(ViewTypes)type opts:(NSDictionary*)opts target:(UIView*)target;

-(void) setBackgroundImage:(NSString *)imageUrl;
-(void) setBackgroundImage:(NSString *)imageUrl fitMode:(UIViewContentMode)mode inRect:(CGRect)rect;

-(void) setImage:(NSString *)imageUrl;
-(void) setStyle:(NSString *)key value:(id)value;
-(void) setText:(NSString *)text;

-(View*) attr:(NSString*)key value:(id)value;

-(View*) bind:(NSString*)event handler:(ViewGestureHandler)handler options:(NSDictionary*)options;
-(View*) unbind:(NSString*)event;
-(View*) css:(NSString *)styles;
-(View*) root;

-(id) get:(NSString *)keyPath;
-(void) set:(NSString *)keyPath value:(id)value;
-(void) del:(NSString*)keyPath;

@end

#pragma mark - functions

View* vbox(id subs, NSDictionary*opts, UIView*target);
View* hbox(id subs, NSDictionary*opts, UIView*target);
View* label(NSString*src, NSDictionary*opts, UIView*target);
View* img(NSString*src, NSDictionary*opts, UIView*target);

typedef void(^ViewDrawListRowHandler)(NSDictionary*,View*,int);
View* list(NSArray*data, ViewDrawListRowHandler handler, NSDictionary*opts, UIView*target);

void load_style(NSString* style_file);
NSDictionary* style(NSString* style);

//View* grids(NSArray*data, NSDictionary*opts, UIView*target);

