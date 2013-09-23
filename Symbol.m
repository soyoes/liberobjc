//
//  Symbol.m
//  common
//
//  Created by @soyoes on 11/1/12.
//  Copyright (c) 2012 Midaslink. All rights reserved.
//

#import "Symbol.h"
#import <QuartzCore/QuartzCore.h>
#import "UIVerticalLabel.h"

#define logRect(name,rect) (NSLog(@"--\nRECT:%@ = (%f,%f), (%f,%f) \n--",(name),(rect.origin.x),(rect.origin.y),(rect.size.width),(rect.size.height)))
#define logSize(name,size) (NSLog(@"--\nRECT:%@ = (%f,%f) \n--",(name),(size.width),(size.height)))
#define logPoint(name,p) (NSLog(@"--\nRECT:%@ = (%f,%f) \n--",(name),(p.x),(p.y)))

#define KNOB_TAG 20001001



static CGPoint lastDragPoint;
static int lastAngel=0;
static BOOL lock_0=YES;
static BOOL lock_3=YES;
static BOOL lock_6=YES;
static BOOL lock_9=YES;
static BOOL moving=NO;

@implementation Knob
- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer{
    //NSLog(@"ges");
    return YES;
}


@end
/*
@implementation Line

-(id) initWithPoints:(CGPoint)start end:(CGPoint)end color:(UIColor*)color width:(float)width{
    self = [super initWithFrame:MIN(start.x, end.x),MIN(start.y, end.y),MAX(start.x, end.x)-MIN(start.x, end.x),MAX(start.y, end.y)-MIN(start.y, end.y)];
    return self;
}

-(void)drawRect:(CGRect)rect{
    

}

@end
*/

@implementation Symbol

@synthesize orgFrame,ratio,panel,knobBtn,canvas,delegate;
@synthesize borderWidth = _borderWidth;
@synthesize borderColor = _borderColor;
@synthesize selected = _selected;
@synthesize content = _content;
@synthesize angel = _angel;
@synthesize selectable,movable,expandable,rotatable;

- (id) initWithContent:(UIView *) content canvas:(UIView*)_canvas delegate:(id<SymbolCanvasDelegate>)_delegate type:(NSString*)__type{
    
    ratio = 1;
    
    CGRect frame = CGRectMake(content.frame.origin.x-SYMBOL_BORDER,
                              content.frame.origin.y-SYMBOL_BORDER,
                              content.frame.size.width + 2 * SYMBOL_BORDER,
                              content.frame.size.height + 2 * SYMBOL_BORDER);
    
    self = [super initWithFrame:frame];
    self.canvas = _canvas;
    _borderWidth = 1.0;
    _borderColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.8];
    _content = content;
    self.type = __type;
    self.delegate = _delegate;
    self.backgroundColor = [UIColor clearColor];
    panel = [[UIView alloc] initWithFrame:CGRectMake(SYMBOL_BORDER, SYMBOL_BORDER, content.bounds.size.width, content.bounds.size.height)];
    panel.backgroundColor = [UIColor clearColor];
    _content.frame = panel.bounds;
    self.orgFrame = panel.bounds;//before rotate /expand
    self.selectable = YES;
    self.movable = YES;
    self.expandable = YES;
    self.rotatable = YES;
    _content.userInteractionEnabled = YES;
    self.data = [[NSMutableDictionary alloc] init];
    
    //self.backgroundColor = [UIColor purpleColor];

    return self;
}

- (void)drawRect:(CGRect)rect{
    [super drawRect:rect];
    
    //self.layer.borderColor = [UIColor clearColor].CGColor;
    //self.layer.borderWidth = _borderWidth;
    
    self.clipsToBounds = NO;
    
    self.panel.clipsToBounds = YES;
    //add subvies
    [self addSubview:panel];
    [panel addSubview:_content];

    
    if (self.selectable) {
        UITapGestureRecognizer *tap =[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(select)];
        [panel addGestureRecognizer:tap];
    }
    
    if (self.movable) {
        UIPanGestureRecognizer *drag =[[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(move:)];
        [panel addGestureRecognizer:drag];
    }
}

- (void) setAngel:(int)angel{
    _angel = angel;
    self.transform = CGAffineTransformMakeRotation(degree2radian(_angel));
}

- (void)select{
    //NSLog(@"set select");
    
    if(canvas != nil){
        for(UIView* v in canvas.subviews){
            if ([v isKindOfClass:[Symbol class]]) {
                [(Symbol *)v deselect];
            }
        }
    }
    
    if(_selected)
        return;
    
    //show borders
    self.panel.layer.borderColor = _borderColor.CGColor;
    self.panel.layer.borderWidth = _borderWidth;
    _selected = YES;
    
    //TODO show buttons
    if(delegate!=nil){
        [delegate symbolTapped:self];
    }
    
    if (self.expandable) {

        UIPinchGestureRecognizer *pinch = [[UIPinchGestureRecognizer alloc] initWithTarget:self action:@selector(pinch:)];
        [panel addGestureRecognizer:pinch];
        
        //TODO add crossbtn & knobbtn;

        knobBtn = [[Knob alloc] initWithFrame:CGRectMake(panel.frame.size.width,panel.frame.size.height,40, 40)];
        //knobBtn = [[Knob alloc] initWithFrame:CGRectMake(self.center.x + panel.frame.size.width/2-20,self.center.y+ panel.frame.size.height/2-20,40, 40)];
        knobBtn.backgroundColor = [UIColor clearColor];
        //knobBtn.backgroundColor = [UIColor colorWithRed:1 green:0 blue:0 alpha:0.1];

        CGAffineTransform scaled = CGAffineTransformMakeScale(1/ratio, 1/ratio);
        knobBtn.transform = CGAffineTransformRotate(scaled,0);

        knobBtn.contentMode = UIViewContentModeCenter;
        knobBtn.image =[UIImage imageNamed:@"ico_knob"];
        knobBtn.userInteractionEnabled = YES;
        //[knobBtn setBackgroundImage:[UIImage imageNamed:@"ico_knob"] forState:UIControlStateNormal];
        
        UIPanGestureRecognizer *expand =[[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(expand:)];
        [expand setMaximumNumberOfTouches:1];
        [expand setTranslation:CGPointMake(0, 0) inView:panel];
        [knobBtn addGestureRecognizer:expand];
        knobBtn.tag = KNOB_TAG;
        //[self addSubview:knobBtn];
        [self addSubview:knobBtn];

    }
}

-(void)deselect{
    self.panel.layer.borderColor = [UIColor clearColor].CGColor;
    _selected = NO;
    //TODO hide buttons
    
    if (self.expandable) {
        [[self viewWithTag:KNOB_TAG] removeFromSuperview];
    }
}

-(void)move:(UIGestureRecognizer*)sender{
    if(!_selected)
       [self select];
    CGPoint p = [(id)sender translationInView:self.superview];
    CGRect pr =CGRectMake(self.frame.origin.x+SYMBOL_BORDER, self.frame.origin.y+SYMBOL_BORDER, self.bounds.size.width-2*SYMBOL_BORDER, self.bounds.size.height-2*SYMBOL_BORDER);
    CGAffineTransform scaled = CGAffineTransformMakeScale(ratio, ratio);
    
    CGAffineTransform trans = CGAffineTransformRotate(scaled,degree2radian(_angel));
    CGRect pframe = CGRectApplyAffineTransform(pr,trans);
    pframe.origin.x = self.frame.origin.x+SYMBOL_BORDER*ratio;
    pframe.origin.y = self.frame.origin.y+SYMBOL_BORDER*ratio;
    
    //logRect(@"panel pframe = ",pframe);
    float left = pframe.origin.x+p.x;
    if(left<=0){
        if(lock_9){
            moving = YES;
            p.x = -1*pframe.origin.x;
            [NSTimer scheduledTimerWithTimeInterval:0.25 target:self selector:@selector(unlock:) userInfo:@9 repeats:NO];
        }
        [self showBorderLine:9];
    }
    
    float right = pframe.origin.x+pframe.size.width+p.x;
    if(right>=canvas.bounds.size.width+5){
        if(lock_3){
            moving = YES;
            p.x = canvas.bounds.size.width+5 - (pframe.origin.x+pframe.size.width);
            [NSTimer scheduledTimerWithTimeInterval:0.25 target:self selector:@selector(unlock:) userInfo:@3 repeats:NO];
        }
        [self showBorderLine:3];
    }
    
    float top = pframe.origin.y+p.y;
    if(top<=0){
        if(lock_0){
            moving = YES;
            p.y = -1*pframe.origin.y;
            [NSTimer scheduledTimerWithTimeInterval:0.25 target:self selector:@selector(unlock:) userInfo:@0 repeats:NO];
        }
        [self showBorderLine:0];
    }
    
    float bottom = pframe.origin.y+pframe.size.height+p.y;
    if(bottom>=canvas.bounds.size.height+5){
        if(lock_6){
            moving = YES;
            p.y = canvas.bounds.size.height+5 - (pframe.origin.y+pframe.size.height);
            [NSTimer scheduledTimerWithTimeInterval:0.5 target:self selector:@selector(unlock:) userInfo:@6 repeats:NO];
        }

        [self showBorderLine:6];
    }
    
    
    CGPoint movedPoint = CGPointMake(self.center.x + p.x, self.center.y + p.y);
    self.center = movedPoint;
    [(id)sender setTranslation:CGPointZero inView:self];
    
    if(sender.state == UIGestureRecognizerStateEnded){
        moving = NO;
        [self lock];
    }
    
}
-(void)lock{
    lock_0 = YES;
    lock_3 = YES;
    lock_6 = YES;
    lock_9 = YES;
}

-(void)unlock:(NSTimer*)timer{
    if(!moving)
        return;
    int way = [(NSNumber*)timer.userInfo intValue];
    switch (way) {
        case 0:lock_0=NO;break;
        case 3:lock_3=NO;break;
        case 6:lock_6=NO;break;
        case 9:lock_9=NO;break;
        default:
            break;
    }
}

-(IBAction)pinch:(UIGestureRecognizer *)sender{
    
    static CGRect initialBounds;
    
    if (sender.state == UIGestureRecognizerStateBegan){
        initialBounds = sender.view.bounds;
    }
    ratio  = [(UIPinchGestureRecognizer *)sender scale];

    //CGAffineTransform zt = CGAffineTransformScale(CGAffineTransformIdentity, factor, factor);

    CGAffineTransform scaled = CGAffineTransformMakeScale(ratio, ratio);
    
    CGAffineTransform trans = CGAffineTransformRotate(scaled,degree2radian(_angel));
    
    CGPoint orgCenter = panel.center;
    
    self.transform = trans;
    self.center = orgCenter;
    
    scaled = CGAffineTransformMakeScale(1/ratio, 1/ratio);
    self.knobBtn.transform = CGAffineTransformRotate(scaled,0);
    
    /*
    orgCenter = self.center;
    //self.bounds = CGRectApplyAffineTransform(initialBounds, zt);
    self.panel.bounds = CGRectApplyAffineTransform(initialBounds, zt);
    float newW = self.panel.bounds.size.width;
    float newH = self.panel.bounds.size.height;
    
    self.bounds = CGRectMake(0, 0,newW+2*SYMBOL_BORDER, newH+2*SYMBOL_BORDER);
    self.center = orgCenter;
    
    //float r = newW/self.orgFrame.size.width;
    //if(r>0)
    NSLog(@"ratio,factor=%f,%f",ratio,factor);
    ratio = factor;
    panel.frame = CGRectMake(SYMBOL_BORDER, SYMBOL_BORDER, (int)newW, (int)newH);
    self.content.bounds = CGRectMake(0, 0, (int)newW, (int)newH);
    self.content.center = CGPointMake((int)(newW/2), (int)(newH/2));
    self.knobBtn.bounds = CGRectMake(0, 0, 40/ratio, 40/ratio);
    self.knobBtn.contentMode = UIViewContentModeCenter;
    self.knobBtn.center = CGPointMake(panel.center.x+newW/2, panel.center.y+newH/2);
    */

}

-(void)expand:(UIGestureRecognizer*)sender{
    if(!_selected)
        [self select];
    
    CGPoint p = //[(id)sender translationInView:self];
            [(id)sender translationInView:self.superview];
    
    CGPoint p_a = self.center;
    CGPoint p_b = CGPointMake(p_a.x + panel.frame.size.width/2, p_a.y + panel.frame.size.height/2);
    CGPoint p_c = CGPointMake(p_b.x + p.x, p_b.y + p.y);
    if(lastDragPoint.x == 0 && lastDragPoint.y ==0){
        lastDragPoint = p_b;
    }
    
    //angel between pb & pa
    int alpha = (int) radian2degree(atan(-1*(p_b.y-p_a.y)/(p_b.x-p_a.x)));
    //angel between pc & pa
    int beta = p_c.x != p_a.x ? (int) radian2degree(atan(-1*(p_c.y-p_a.y)/(p_c.x-p_a.x)))
        :p_c.y<p_a.y ? 90:-90;
    
    int ang = alpha-beta;
    
    if(abs(ang-lastAngel)>90){
        ang = ang>0 ? ang-180 : ang+180;
    }
    //NSLog(@"(a=%.0f, b=%.0f, ang=%.0f) -\n (%.0f,%.0f)",alpha, beta, ang,p_c.x-p_a.x,p_a.y-p_c.y);
    
    //enlarge
    float orgRadius = sqrt(pow((p_b.x-p_a.x),2)+pow((p_b.y-p_a.y),2));
    float radius = sqrt(pow((p_a.x-p_c.x),2)+pow((p_a.y-p_c.y),2));
    ratio = radius/orgRadius;
    CGAffineTransform scaled = CGAffineTransformMakeScale(ratio, ratio);
    
    int a = (int)(ang+_angel);
    a -= a% 5;
    
    CGAffineTransform trans = CGAffineTransformRotate(scaled,degree2radian(a));
    
    self.transform = trans;
    
    if(sender.state == UIGestureRecognizerStateEnded){
        //_angel = (ang+_angel) % 360;
        _angel = (a) % 360;
    }
    
    lastDragPoint = p_c;
    lastAngel = ang;
    
    scaled = CGAffineTransformMakeScale(1/ratio, 1/ratio);
    self.knobBtn.transform = CGAffineTransformRotate(scaled,0);

}

-(IBAction)remove:(id)sender{
    [self removeFromSuperview];
}


-(void)drawImageAndFitToContetRect:(UIImage*)image{
    if([self.content isKindOfClass:[UIImageView class]]){
        [self.data setValue:image forKey:@"image"];
        UIImageView *iv = (UIImageView *)self.content;
        float corner = iv.layer.cornerRadius;
        self.transform = CGAffineTransformMakeRotation(0);
        //define new imageView size
        CGRect newRect;
        //NSLog(@"--\nSIZE:%@ = (%f,%f) \n--",@"frame",iv.frame.size.width,iv.frame.size.height);
        //NSLog(@"--\nSIZE:%@ = (%f,%f) \n--",@"image",image.size.width,image.size.height);
        if(image.size.width/image.size.height
           >= iv.frame.size.width/iv.frame.size.height){ //image is wider
            float w = iv.frame.size.width * (image.size.height/iv.frame.size.height);
            newRect = CGRectMake((image.size.width-w)/2, 0, w, image.size.height);
            //newSize = CGSizeMake(image.size.width * (iv.frame.size.height/image.size.height), iv.frame.size.height);
        }else{
            float h = iv.frame.size.height * (image.size.width/iv.frame.size.width);
            newRect = CGRectMake(0, (image.size.height-h)/2, image.size.width,h);
            //newSize = CGSizeMake(iv.frame.size.width,  image.size.height * (iv.frame.size.width/image.size.width));
        }
        
        CGImageRef imageRef = CGImageCreateWithImageInRect([image CGImage], newRect);
        [iv setImage:[UIImage imageWithCGImage:imageRef]];
        iv.clipsToBounds = YES;
        iv.layer.cornerRadius = corner;
        CGImageRelease(imageRef);
        self.transform = CGAffineTransformMakeRotation(degree2radian(_angel));
    }

}

-(void) showBorderLine:(int)way{
    CGRect rect;
    switch (way) {
        case 0://north
            rect = CGRectMake(-20, 0, canvas.bounds.size.width+40, 2);
            break;
        case 3://east
            rect = CGRectMake(canvas.bounds.size.width, -20, 2, canvas.bounds.size.height+40);
            break;
        case 6://south
            rect = CGRectMake(-20, canvas.bounds.size.height, canvas.bounds.size.width+40, 2);
            break;
        case 9://west
            rect = CGRectMake(0, -20, 2, canvas.bounds.size.height+40);
            break;
        default:
            break;
    }
    UIView *lineView = [[UIView alloc] initWithFrame:rect];
    lineView.backgroundColor = [UIColor colorWithRed:0.2 green:1 blue:1 alpha:1];
    [canvas addSubview:lineView];
    [NSTimer scheduledTimerWithTimeInterval:0.5 target:self selector:@selector(hideBorderLine:) userInfo:lineView repeats:NO];
}

-(void)hideBorderLine:(NSTimer*)theTimer{
    UIView *lineView = (UIView*) theTimer.userInfo;
    [lineView removeFromSuperview];
}


-(void)adjustContentSize:(CGSize)size{
    self.transform = CGAffineTransformRotate(CGAffineTransformMakeScale(1, 1),degree2radian(0));
    CGPoint orgCenter = self.center;
    self.frame = CGRectMake(0, 0, size.width+2*SYMBOL_BORDER,size.height+2*SYMBOL_BORDER);
    self.panel.frame = CGRectMake(SYMBOL_BORDER, SYMBOL_BORDER, size.width,size.height);
    self.center = orgCenter;
    self.orgFrame = self.panel.bounds;
    if(self.knobBtn!=nil){
        self.knobBtn.center= CGPointMake(size.width+SYMBOL_BORDER, size.height+SYMBOL_BORDER);
        if (self.angel!=0 || self.ratio!=1) {
            self.transform = self.transform = CGAffineTransformRotate(CGAffineTransformMakeScale(ratio, ratio),degree2radian(self.angel));
        }
    }
}


-(void)setContentValue:(id)value toRect:(CGSize)newSize{
    if([value isKindOfClass:[UIImage class]]){
        UIImageView * iv = (UIImageView *) self.content;
        iv.frame = CGRectMake(0, 0, newSize.width, newSize.height);
        iv.image = (UIImage*)value;
    }else if([self.content isKindOfClass:[UIVerticalLabel class]]){
        UIVerticalLabel * lb = (UIVerticalLabel *) self.content;
        lb.text = value;
        newSize = lb.frame.size;
    }else if([self.content isKindOfClass:[UILabel class]]){
        UILabel * lb = (UILabel *) self.content;
        lb.text = value;
        newSize = [lb.text sizeWithFont:lb.font];
    }
    self.content.center = CGPointMake(newSize.width/2, newSize.height/2);
    [self adjustContentSize:newSize];
}

@end


