//
//  UIViewController+common.m
//  common
//
//  Created by Tsai on 11/7/12.
//  Copyright (c) 2012 soyoes. All rights reserved.
//

#import "UIViewController+common.h"
#import "AppDelegate.h"
#import <QuartzCore/QuartzCore.h>


@implementation UIViewController (common)

+(NSArray*) defaultColorPallete{
    return @[
    @[  @[@0,@0,@0],          @[@148,@155,@161],  @[@89,@37,@0],      @[@189,@133,@74]  ],
    @[  @[@106,@117,@123],    @[@178,@183,@187],  @[@156,@95,@12],    @[@231,@195,@159] ],
    @[  @[@178,@183,@187],    @[@208,@211,@216],  @[@240,@216,@190],  @[@240,@216,@190] ],
    @[  @[@255,@255,@255],    @[@243,@243,@243],  @[@249,@239,@227],  @[@246,@229,@209] ],
    @[  @[@241,@149,@190],    @[@245,@197,@221],  @[@252,@210,@194],  @[@252,@210,@194] ],
    @[  @[@231,@61,@150],     @[@248,@185,@212],  @[@248,@157,@136],  @[@249,@182,@166] ],
    @[  @[@178,@1,@92],       @[@209,@60,@90],    @[@179,@32,@24],    @[@238,@45,@36]   ],
    @[  @[@119,@29,@125],     @[@183,@107,@109],  @[@205,@102,@25],   @[@250,@166,@52]  ],
    @[  @[@127,@62,@152],     @[@154,@90,@164],   @[@242,@137,@30],   @[@220,@154,@31]  ],
    @[  @[@27,@63,@149],      @[@185,@179,@217],  @[@229,@181,@57],   @[@254,@210,@77]  ],
    @[  @[@8,@35,@102],       @[@140,@164,@212],  @[@254,@228,@144],  @[@255,@226,@146] ],
    @[  @[@72,@99,@176],      @[@177,@202,@232],  @[@102,@144,@68],   @[@211,@226,@125] ],
    @[  @[@0,@154,@200],      @[@205,@235,@235],  @[@71,@127,@64],    @[@101,@181,@96]  ],
    @[  @[@0,@162,@177],      @[@0,@162,@177],    @[@53,@102,@57],    @[@151,@206,@138] ],
    @[  @[@0,@106,@94],       @[@0,@125,@109],    @[@0,@115,@134],    @[@0,@138,@174]   ]
    ];
}


-(AppDelegate *)app{
    AppDelegate *app = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    return app;
}

- (void) setData:(NSString*)keyPath value:(id)value{
    AppDelegate *app = [self app];
    [app.data setValue:value forKeyPath:keyPath];
}

- (id) getData:(NSString*)keyPath{
    AppDelegate *app = [self app];
    return [app.data valueForKeyPath:keyPath];
}

- (void) delData:(NSString*)keyPath{
    AppDelegate *app = [self app];
    [app.data removeObjectForKey:keyPath];
}

- (UIViewController *) getController:(NSString *)storyboardId{
    UIStoryboard* board = [UIStoryboard storyboardWithName:@"MainStoryboard" bundle: nil];
    return [board instantiateViewControllerWithIdentifier:storyboardId];
}



-(void) alert:(NSString *)msg{
    NSString *message = (msg==nil || [msg length] == 0)? @"ERROR happens":msg;
	UIAlertView *alertView = [[UIAlertView alloc] initWithTitle: @"Notice" message:message  delegate: self cancelButtonTitle: @"Ok" otherButtonTitles: nil];
	[alertView show];
}

-(BOOL)isModal {
    BOOL isModal = ((self.parentViewController && self.parentViewController.modalViewController == self) ||
                    //or if I have a navigation controller, check if its parent modal view controller is self navigation controller
                    ( self.navigationController && self.navigationController.parentViewController && self.navigationController.parentViewController.modalViewController == self.navigationController) ||
                    //or if the parent of my UITabBarController is also a UITabBarController class, then there is no way to do that, except by using a modal presentation
                    [[[self tabBarController] parentViewController] isKindOfClass:[UITabBarController class]]);
    
    //iOS 5+
    if (!isModal && [self respondsToSelector:@selector(presentingViewController)]) {
        
        isModal = ((self.presentingViewController && self.presentingViewController.modalViewController == self) ||
                   //or if I have a navigation controller, check if its parent modal view controller is self navigation controller
                   (self.navigationController && self.navigationController.presentingViewController && self.navigationController.presentingViewController.modalViewController == self.navigationController) ||
                   //or if the parent of my UITabBarController is also a UITabBarController class, then there is no way to do that, except by using a modal presentation
                   [[[self tabBarController] presentingViewController] isKindOfClass:[UITabBarController class]]);
        
    }
    return isModal;
}
- (int) screenHeight{
    CGRect screen = [[UIScreen mainScreen] bounds];
    return screen.size.height;
}

- (void) showSubView:(UIView*)subview to:(UIView*)containerView animationOption:(UIViewAnimationOptions)opt withAnimation:(void (^)(void))animation{
    [UIView transitionWithView:containerView duration:0.5
                       options:opt
                    animations:^ {
                        //[containerView addSubview:subview];
                        animation();
                    }
                    completion:nil];
    
}

-(void) logRect:(CGRect)rect name:(NSString *)name{
    NSLog(@"--\nRECT:%@ = (%f,%f), (%f,%f) \n--",name,rect.origin.x,rect.origin.y,rect.size.width,rect.size.height);
    
}

-(void) logSize:(CGSize)size name:(NSString *)name{
    NSLog(@"--\nSIZE:%@ = (%f,%f) \n--",name,size.width,size.height);
}

- (void) makeShadow:(UIView*)v{
    v.layer.shadowColor = [UIColor blackColor].CGColor;
    v.layer.shadowOffset = CGSizeMake(2, 2);
    v.layer.shadowOpacity = 0.5;

    if([v isKindOfClass:[UILabel class]]){
        v.layer.shadowRadius = 20.0;
        v.layer.masksToBounds = NO;
    }
}


/**
 @example
 [self makeGradient:self.view colors:@[
                (id)[UIColor colorWithRed:0 green:0 blue:0 alpha:0.8].CGColor,
                (id)[UIColor colorWithRed:0 green:0 blue:0 alpha:0.8].CGColor,
                (id)[UIColor colorWithRed:1 green:0.67 blue:0.77 alpha:1.0].CGColor
                ] locations:@[@0.0,@0.4,@0.7] ];
 [self makeGradient:self.view colors:@[
     (id)[UIColor colorWithRed:0 green:0 blue:0 alpha:0.8].CGColor,
     (id)[UIColor colorWithRed:0 green:0 blue:0 alpha:0.8].CGColor,
     (id)[UIColor colorWithRed:1 green:0.67 blue:0.77 alpha:1.0].CGColor
     ] locations:nil ];
 
 */


- (void) makeGradient:(UIView*)v colors:(NSArray*)colors locations:(NSArray*)locations{
    CAGradientLayer *gradient = [CAGradientLayer layer];
    gradient.frame = v.bounds;
    gradient.cornerRadius = v.layer.cornerRadius;
    gradient.colors = colors;
    gradient.locations = locations;
    [v.layer insertSublayer:gradient atIndex:0];
}


- (void)hideRectIconPicker{
    [[self.view viewWithTag:RECT_ICON_PICKER_TAG] removeFromSuperview];
}


/**
@example 
 
 in your viewController
 --- //init your items
 static NSArray * items = @[
    @{@"image":@"a.png"},
    @{@"image":@"b"}
 ];
 
 --- //display
 [self showRectIconPicker:items
        itemSize:CGSizeMake(90, 133) 
        windowRect:CGRectMake(0, 92, 320, [self screenHeight]-92-20) 
        handler:@selector(itemSelected:) onto:self.canvas];
 
 --- //handle tap event
 -(void)itemSelected:(UITapGestureRecognizer*)rec{
    [self hideRectIconPicker];
    int idx =rec.view.tag-1;
    NSDictionary *item = items[idx];
    [self DO_SOMETHING:item];
 }
 
 
 **/

- (void)showRectIconPicker:(NSArray *)items itemSize:(CGSize)size windowRect:(CGRect)rect handler:(SEL)handler onto:(UIView*)subview{
    int count = [items count];
    int cols = (int)floor(320/size.width);
    int rows = (int)ceil(count / cols);
    
    int margin = (320/cols-size.width)/2;
    
    //    CGRect screenRect = [[UIScreen mainScreen] bounds];
    UIScrollView *window = [[UIScrollView alloc] initWithFrame:rect];
    window.backgroundColor = [UIColor scrollViewTexturedBackgroundColor];
    window.center = CGPointMake(160, -240);
    [window setContentSize:CGSizeMake(320, rows*(size.height+2*margin))];
    for(int r=0;r<rows;r++){
        for (int c=0; c<cols; c++) {
            int idx = r * cols + c;
            if(idx<count){

                NSDictionary *o = items[idx];
                if(o[@"image"]!=nil){
                    UITapGestureRecognizer *recognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:handler];
                    UIImageView *v = [[UIImageView alloc] initWithFrame:CGRectMake(c*(size.width+2*margin)+margin,r*(size.height+2*margin)+margin,size.width,size.height)];
                    v.image = [UIImage imageNamed: o[@"image"]];
                    v.contentMode = UIViewContentModeScaleAspectFit;
                    v.userInteractionEnabled = YES;
                    v.tag = idx+1;
                    //v.backgroundColor = [UIColor blackColor];
                    v.backgroundColor = [UIColor whiteColor];
                    [v addGestureRecognizer:recognizer];
                    [window addSubview:v];
                }else if(o[@"bgColor"]!=nil){
                    UIButton *b = [UIButton buttonWithType:UIButtonTypeCustom];
                    b.frame = CGRectMake(c*(size.width+2*margin)+margin,r*(size.height+2*margin)+margin,size.width,size.height);
                    b.backgroundColor = o[@"bgColor"];
                    b.layer.borderColor = [UIColor lightGrayColor].CGColor;
                    b.layer.borderWidth = 1;
                    [b addTarget:self action:handler forControlEvents:UIControlEventTouchUpInside];
                    [window addSubview:b];
                }
            }else{
                
            }
        }
    }
    window.tag = RECT_ICON_PICKER_TAG;
    if(subview!=nil){
        [self.view insertSubview:window aboveSubview:subview];
    }else
        [self.view addSubview:window];
    [self showSubView:window to:self.view animationOption:UIViewAnimationCurveEaseInOut withAnimation:^(){
        window.center = CGPointMake(160,rect.origin.y + rect.size.height/2);
    } ];
    
}


- (void)hideGroundButtonMenu{
     [[self.view viewWithTag:RECT_GROUND_BUTTON_MENU_TAG] removeFromSuperview];
}

/**
 
 @example
 
 in your viewController
 --- //init your buttons
 static NSArray * buttons = @[
    @{@"image":@"a.png"},
    @{@"title":@"click me",@"tintColor":[UIColor redColor],@"titleColor":[UIColor whiteColor]}
 ];
 
 --- //display
 [self showGroundMenu:buttons
    handler:@selector(groundButtonTapped:) onto:nil];
 
 --- //handle tap event
 -(void)groundButtonTapped:(UIButton*)btn{
    [self hideGroundButtonMenu];
    int idx =btn.tag-1;
    switch(idx){
        case 1: [self DO_SOMETHING:item]; break;
        ...
    }
 }
 
 */

- (void)showGroundButtonMenu:(NSArray*)buttons handler:(SEL)handler onto:(UIView*)subview{
    int btnH = 44;
    int btnW = 230;
    int marginH = 8;
    
    int count = [buttons count];
    if(count == 0)
        return;
    
    int winH = count * (btnH+3*marginH);
    
    int screenH = [self screenHeight];
    UIView * window = [[UIView alloc] initWithFrame:CGRectMake(0, screenH, 320, winH)];
    window.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.8];
    for (int i =0;i<count;i++) {
        NSDictionary *b = buttons[i];
        UIButton *btn;
        btn = [UIButton buttonWithType:UIButtonTypeCustom];
        btn.frame = CGRectMake((320-btnW)/2, i*(btnH+marginH*2)+marginH, btnW, btnH);
        btn.tag = i+1;
        [btn addTarget:self action:handler forControlEvents:UIControlEventTouchUpInside];
        if(b[@"image"]!=nil){
            [btn setBackgroundImage:[UIImage imageNamed:b[@"image"]] forState:UIControlStateNormal];
        }else{
            [btn setTitle:b[@"title"] forState:UIControlStateNormal];
            if(b[@"tintColor"]!=nil){
                [btn setTintColor:b[@"tintColor"]];
            }
            if(b[@"titleColor"]!=nil){
                [btn setTitleColor:b[@"titleColor"] forState:UIControlStateNormal];
            }
            btn.layer.cornerRadius = 5;
            btn.layer.borderColor = [UIColor blackColor].CGColor;
            btn.layer.borderWidth = 1;
            
            [btn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
            
            [self makeGradient:btn colors:@[
             (id)[UIColor colorWithRed:1 green:1 blue:1 alpha:1].CGColor,
             (id)[UIColor colorWithRed:0.7 green:0.7 blue:0.7 alpha:1].CGColor,
             (id)[UIColor colorWithRed:0.8 green:0.8 blue:0.8 alpha:1.0].CGColor
             ] locations:@[@0.1,@0.5,@0.9]];

        }
        
        
        [window addSubview:btn];
        
        
    }
    window.tag = RECT_GROUND_BUTTON_MENU_TAG;
    if(subview!=nil){
        [self.view insertSubview:window aboveSubview:subview];
    }else
        [self.view addSubview:window];
    [self showSubView:window to:self.view animationOption:UIViewAnimationCurveEaseInOut withAnimation:^(){
        window.center = CGPointMake(160,  screenH-winH/2-20);
    }];
}

- (void)hideTextInputMenu{
    [[self.view viewWithTag:TEXT_INPUT_MENU_TAG] removeFromSuperview];
}
- (void)showTextInputMenu:(int)windowHeight initText:(NSString*)defaultText onto:(UIView*)subview initFunc:(void (^)(UIView*))initFunc{
    int screenH = [self screenHeight];
    UIView * window = [[UIView alloc] initWithFrame:CGRectMake(0, screenH, 320, windowHeight)];
    window.backgroundColor = [UIColor scrollViewTexturedBackgroundColor];
    
    //UITextField *f = [[UITextField alloc] initWithFrame:CGRectMake(10, 10, 300, 60)];
    UITextView *f =[[UITextView alloc] initWithFrame:CGRectMake(10, 10, 300, 60)];
    f.backgroundColor = [UIColor whiteColor];
    f.layer.borderWidth = 1;
    f.layer.borderColor = [UIColor grayColor].CGColor;
    f.layer.shadowColor = [UIColor blackColor].CGColor;
    f.layer.shadowOffset = CGSizeMake(2, 2);
    f.layer.shadowOpacity = 0.4;
    f.layer.cornerRadius = 5;
    f.tag = TEXT_INPUT_VIEW_TAG;
    f.editable = YES;

    if(defaultText!=nil)
        f.text = defaultText;
    f.delegate = (id<UITextViewDelegate>) self;
    [window addSubview:f];
    
    
    UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
    btn.frame = CGRectMake(30, 90, 260, 40);
    btn.layer.cornerRadius = 5;
    btn.layer.borderColor = [UIColor blackColor].CGColor;
    btn.layer.borderWidth = 1;
    [btn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [btn setTitle:@"完　成" forState:UIControlStateNormal];
    [self makeGradient:btn colors:@[
     (id)[UIColor colorWithRed:1 green:1 blue:1 alpha:1].CGColor,
     (id)[UIColor colorWithRed:0.7 green:0.7 blue:0.7 alpha:1].CGColor,
     (id)[UIColor colorWithRed:0.8 green:0.8 blue:0.8 alpha:1.0].CGColor
     ] locations:@[@0.1,@0.5,@0.9]];
    [btn addTarget:self action:@selector(textViewEndEditing:) forControlEvents:UIControlEventTouchUpInside];
    [window addSubview:btn];
    
    initFunc(window);
    
    window.tag = TEXT_INPUT_MENU_TAG;
    if(subview!=nil){
        [self.view insertSubview:window aboveSubview:subview];
    }else
        [self.view addSubview:window];
    [self showSubView:window to:self.view animationOption:UIViewAnimationCurveEaseInOut withAnimation:^(){
        window.center = CGPointMake(160,  screenH-windowHeight/2-20);
        [f becomeFirstResponder];
    }];
}

-(void) textViewEndEditing:(UIButton*)btn{
    UITextView *tv = (UITextView *)  [btn.superview viewWithTag:TEXT_INPUT_VIEW_TAG];
    [tv resignFirstResponder];
}

- (void)hideSomeMenu{
    [[self.view viewWithTag:SOME_MENU_TAG] removeFromSuperview];
}
- (void)drawSomeMenu:(int)windowHeight bgColor:(UIColor*)bgcolor drawingHandler:(void (^)(UIView*))drawingHandler{
    int screenH = [self screenHeight];
    UIView * window = [[UIView alloc] initWithFrame:CGRectMake(0, screenH, 320, windowHeight)];
    window.backgroundColor = bgcolor!=nil? bgcolor: [UIColor colorWithRed:0 green:0 blue:0 alpha:0.8];
    
    drawingHandler(window);
    
    window.tag = SOME_MENU_TAG;
    [self.view addSubview:window];
    [self showSubView:window to:self.view animationOption:UIViewAnimationCurveEaseInOut withAnimation:^(){
        window.center = CGPointMake(160,  screenH-windowHeight/2-20);
    }];

}

- (void)hideColorPalette{
    [[self.view viewWithTag:COLOR_PALETTE_TAG] removeFromSuperview];
}
- (void)showColorPalette:(int)windowHeight bgColor:(UIColor*)bgcolor palette:(NSArray *)palette selectedHandler:(SEL)handler{
    
    if(palette == nil)
        palette = [UIViewController defaultColorPallete];
    
    int screenH = [self screenHeight];
    UIScrollView * window = [[UIScrollView alloc] initWithFrame:CGRectMake(0, screenH, 320, windowHeight)];
    window.backgroundColor = bgcolor!=nil? bgcolor: [UIColor colorWithRed:0 green:0 blue:0 alpha:0.8];
    
    int rows = [palette count];
    int cols = [palette[0] count];

    
    int cellW = 60;
    int margin = 2;
    float cellH = windowHeight/rows-2*margin;
    
    if(cellH<20)
        cellH = 20;
    
    [window setContentSize:CGSizeMake(320, (cellH+2*margin) * rows)];
    for(int row=0;row<rows;row++){
        for (int col=0; col<cols; col++) {
            NSArray *o = palette[row][col];
            float r = [o[0] floatValue]/255.0;
            float g = [o[1] floatValue]/255.0;
            float b = [o[2] floatValue]/255.0;
            
            UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
            btn.titleLabel.text = [NSString stringWithFormat:@"%d,%d",row,col];
            UIColor *color = [UIColor colorWithRed:r green:g blue:b alpha:1];
            btn.titleLabel.textColor = color;
            btn.frame = CGRectMake(col*80+(80-cellW)/2,row*(cellH+2*margin)+2,cellW,cellH);
            //[self logRect:btn.frame name:[NSString stringWithFormat:@"(r=%d,c=%d)",row,col]];
            btn.backgroundColor = color;
            btn.layer.borderColor = [UIColor lightGrayColor].CGColor;
            btn.layer.borderWidth = 1;
            [btn addTarget:self action:handler forControlEvents:UIControlEventTouchUpInside];
            [window addSubview:btn];
        }
    }
    
    window.tag = COLOR_PALETTE_TAG;
    [self.view addSubview:window];
    [self showSubView:window to:self.view animationOption:UIViewAnimationCurveEaseInOut withAnimation:^(){
        window.center = CGPointMake(160,  screenH-windowHeight/2-20);
    }];
}

@end
