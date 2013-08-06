//
//  View.h
//  screater
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



@interface View : UIScrollView


@property ViewTypes type;
@property NSString  *ID;
@property NSMutableDictionary *opts;
@property NSMutableDictionary *data;
@property NSMutableDictionary *gestures;
@property NSMutableArray  *attrs;
@property (nonatomic) UIView *parent;
@property (nonatomic) UIView *content;

@property NSString *txt;
@property CATextLayer *textLayer;
@property NSString *src;
@property CALayer *imgLayer;

//default style options from vbox , hbox ...
@property NSMutableDictionary* defaultStyles;
//original style values that override by css method
@property NSMutableDictionary* replacedStyles;

@property int idx;
@property float padding;
@property float space; //space between items(subviews)

@property (readonly) float margin;

-(void)appendTo:(UIView *)_parent;
-(id)initWithType:(ViewTypes)type opts:(NSDictionary*)opts target:(UIView*)target;

-(void) setBackgroundImage:(NSString *)imageUrl;
-(void) setBackgroundImage:(NSString *)imageUrl fitMode:(UIViewContentMode)mode inRect:(CGRect)rect;

-(void) setImage:(NSString *)imageUrl;
-(void) setText:(NSString *)text;
-(void) setStyle:(NSString *)key value:(id)value;

-(View*) attr:(NSString*)key value:(id)value;

-(View*) bind:(NSString*)event handler:(ViewGestureHandler)handler options:(NSDictionary*)options;
-(View*) unbind:(NSString*)event;
-(View*) css:(NSString *)styles;


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
//View* grids(NSArray*data, NSDictionary*opts, UIView*target);

