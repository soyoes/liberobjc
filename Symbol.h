//
//  Symbol.h
//  common
//
//  Created by @soyoes on 11/1/12.
//  Copyright (c) 2012 Midaslink. All rights reserved.
//


/**
 A view parts which can drag&drop / move / enlarg / rotate / delete
 */


#import <UIKit/UIKit.h>

#define degree2radian(x) ((x) * M_PI / 180.0)
#define radian2degree(x) ((x) * 180.0 / M_PI)
#define SYMBOL_BORDER 20

@class Symbol;

@protocol SymbolCanvasDelegate <NSObject>
-(void)symbolTapped:(Symbol*)symbol;

@end
/*
@interface Line :UIView
-(id) initWithPoints:(CGPoint)start end:(CGPoint)end color:(UIColor*)color width:(float)width;

@end
*/
@interface Knob :UIImageView

@end

@interface Symbol : UIView


@property (nonatomic) CGRect orgFrame; //original rect before editing
@property (nonatomic) BOOL selected; //either a symbol is selected
@property (nonatomic) int angel; //rotate angel  -360 ~ 360
@property (nonatomic) CGPoint knobPoint; //knob button's point
@property (nonatomic) float ratio; //expand/enlarged ratio 0.0 ~ N.0
@property (nonatomic) float borderWidth; //border width when selected
@property (nonatomic,retain) UIColor *borderColor; //border color when selected

@property (nonatomic,retain) id<SymbolCanvasDelegate> delegate;
@property (nonatomic,retain) NSString *type;

@property (nonatomic,assign) BOOL selectable;
@property (nonatomic,assign) BOOL movable;
@property (nonatomic,assign) BOOL expandable;
@property (nonatomic,assign) BOOL rotatable;
@property (nonatomic,assign) BOOL borderFixed;
@property (nonatomic,retain) NSMutableDictionary *data;

//TODO add a dragable bounds
@property (nonatomic, retain) UIView *canvas;
@property (nonatomic, retain) UIView *panel;
@property (nonatomic, retain) UIView *content;
@property (nonatomic, retain) Knob *knobBtn;

- (id) initWithContent:(UIView *) content canvas:(UIView*)canvas delegate:(id<SymbolCanvasDelegate>)delegate type:(NSString*)type;

-(void)move:(UIGestureRecognizer*)sender;
-(void)expand:(UIGestureRecognizer*)sender;

-(void)adjustContentSize:(CGSize)size;
/**
@value : UIImage(UIImageView) / NSString(UIVerticalLabel/UILabel) ...
@newSize : adjust size of image. not work with label
 */
-(void)setContentValue:(id)value toRect:(CGSize)newSize;


-(void)select;
-(void)deselect;

-(void)drawImageAndFitToContetRect:(UIImage*)image;

-(IBAction)remove:(id)sender;


@end
