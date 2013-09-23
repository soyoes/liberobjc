//
//  UIViewController+common.h
//  common
//
//  Created by Tsai on 11/7/12.
//  Copyright (c) 2012 soyoes. All rights reserved.
//

#import <UIKit/UIKit.h>


#define RECT_ICON_PICKER_TAG 1001001
#define RECT_GROUND_BUTTON_MENU_TAG 1001002
#define TEXT_INPUT_MENU_TAG 1001003
#define TEXT_INPUT_VIEW_TAG 1002003
#define SOME_MENU_TAG 1001004
#define COLOR_PALETTE_TAG 1001005

#define logRect(name,rect) (NSLog(@"--\nRECT:%@ = (%f,%f), (%f,%f) \n--",(name),(rect.origin.x),(rect.origin.y),(rect.size.width),(rect.size.height)))
#define logSize(name,size) (NSLog(@"--\nRECT:%@ = (%f,%f) \n--",(name),(size.width),(size.height)))
#define logPoint(name,p) (NSLog(@"--\nRECT:%@ = (%f,%f) \n--",(name),(p.x),(p.y)))

@class AppDelegate;
@interface UIViewController (common)
- (AppDelegate*) app;
- (void) setData:(NSString*)keyPath value:(id)value;
- (id) getData:(NSString*)keyPath;
- (void) delData:(NSString*)keyPath;
- (UIViewController *) getController:(NSString *)storyboardId;//storyboard ID
- (void) alert:(NSString *)msg;
- (int) screenHeight;
- (BOOL) isModal;


- (void) showSubView:(UIView*)subview to:(UIView*)containerView animationOption:(UIViewAnimationOptions)opt withAnimation:(void (^)(void))animation;

-(void) logRect:(CGRect)rect name:(NSString *)name;
-(void) logSize:(CGSize)size name:(NSString *)name;


- (void) makeShadow:(UIView*)v;
- (void) makeGradient:(UIView*)v colors:(NSArray*)colors locations:(NSArray*)locations;

- (void)hideRectIconPicker;
- (void)showRectIconPicker:(NSArray *)items itemSize:(CGSize)size windowRect:(CGRect)rect handler:(SEL)handler onto:(UIView*)subview;


- (void)hideGroundButtonMenu;
- (void)showGroundButtonMenu:(NSArray*)buttons handler:(SEL)handler onto:(UIView*)subview;

- (void)hideTextInputMenu;
- (void)showTextInputMenu:(int)windowHeight initText:(NSString*)defaultText onto:(UIView*)subview initFunc:(void (^)(UIView*))initFunc;

- (void)hideSomeMenu;
- (void)drawSomeMenu:(int)windowHeight bgColor:(UIColor*)bgcolor drawingHandler:(void (^)(UIView*))drawingHandler;

+(NSArray*) defaultColorPallete;
- (void)hideColorPalette;
- (void)showColorPalette:(int)windowHeight bgColor:(UIColor*)bgcolor palette:(NSArray *)palette selectedHandler:(SEL)handler;


@end
