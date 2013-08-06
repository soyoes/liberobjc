//
//  UIVerticalLabel.h
//  common
//
//  Created by Tsai on 11/20/12.
//  Copyright (c) 2012 soyoes. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIVerticalLabel : UILabel

@property (nonatomic) BOOL isVertical;
@property (nonatomic) int margin;
@property (nonatomic, retain) NSArray *lines;


-(id) initWithText:(NSString*)str font:(UIFont *)f center:(CGPoint)c margin:(int)margin;


@end
