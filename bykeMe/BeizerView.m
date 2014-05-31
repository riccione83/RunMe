//
//  BeizerView.m
//  RunMe!
//
//  Created by Riccardo Rizzo on 31/05/14.
//  Copyright (c) 2014 Riccardo Rizzo. All rights reserved.
//

#import "BeizerView.h"

@implementation BeizerView

@synthesize percent;
@synthesize lineWith,radius,maxValue;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor whiteColor];
        
        startAngle = M_PI * 1.5;
        endAngle = startAngle + (M_PI * 2);
        radius = (frame.size.height/2) - 10;
        lineWith = 10;
        maxValue = 100;
    }
    return self;
}


// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
    
    NSString * textContent = [NSString stringWithFormat:@"%.01f",percent];
    
    UIBezierPath *bezierPathSfondo = [UIBezierPath bezierPath];
    
    [bezierPathSfondo addArcWithCenter:CGPointMake(rect.size.width/2, rect.size.height/2) radius:radius startAngle:startAngle endAngle:(endAngle-startAngle)*(100 / 100.0) + startAngle clockwise:YES];
    [[UIColor blueColor] setStroke];
    bezierPathSfondo.lineWidth = lineWith;
    [bezierPathSfondo stroke];
    
    UIBezierPath *bezierPath = [UIBezierPath bezierPath];
    
    [bezierPath addArcWithCenter:CGPointMake(rect.size.width/2, rect.size.height/2) radius:radius startAngle:startAngle endAngle:(endAngle-startAngle)*(percent / 100.0) + startAngle clockwise:YES];
    
    bezierPath.lineWidth = lineWith;
    [[UIColor redColor] setStroke];
    [bezierPath stroke];
    
    CGRect textRect = CGRectMake((rect.size.width/2.0) - 71/2.0, (rect.size.height / 2.0) -45/2.0, 71, 45);
    [[UIColor blackColor] setFill];
    [textContent drawInRect:textRect withFont:[UIFont fontWithName:@"Helvetica-Bold" size:30.0] lineBreakMode:NSLineBreakByWordWrapping alignment:NSTextAlignmentCenter];
    
}


@end
