//
//  BeizerView.m
//  RunMe!
//
//  Created by Riccardo Rizzo on 31/05/14.
//  Copyright (c) 2014 Riccardo Rizzo. All rights reserved.
//

#import "BeizerView.h"

#define UIColorFromRGB(rgbValue) [UIColor colorWithRed:((float)((rgbValue & 0xFF0000) >> 16))/255.0 green:((float)((rgbValue & 0xFF00) >> 8))/255.0 blue:((float)(rgbValue & 0xFF))/255.0 alpha:1.0]


@implementation BeizerView

@synthesize percent;
@synthesize lineWith,radius,maxValue;
@synthesize indicator;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor colorWithWhite:0.5 alpha:0.5];
        self.opaque = NO;
        
        startAngle = M_PI * 1.5;
        endAngle = startAngle + (M_PI * 2);
        radius = (frame.size.height/2) - 10;
        lineWith = 10;
        maxValue = 100;
        indicator = @"Km/h";
    }
    return self;
}


// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
    
    NSString * textContent = [NSString stringWithFormat:@"%.01f",percent];
    NSString* value = [NSString stringWithFormat:@"%@",indicator];


    UIBezierPath *bezierPathSfondo = [UIBezierPath bezierPath];
    
    [bezierPathSfondo addArcWithCenter:CGPointMake(rect.size.width/2, rect.size.height/2) radius:radius startAngle:startAngle endAngle:(endAngle-startAngle)*(maxValue / maxValue) + startAngle clockwise:YES];
    [[UIColor blueColor] setStroke];
    bezierPathSfondo.lineWidth = lineWith;
    [bezierPathSfondo stroke];
    
    UIBezierPath *bezierLato = [UIBezierPath bezierPath];
    
    [bezierLato addArcWithCenter:CGPointMake(rect.size.width/2, rect.size.height/2) radius:radius+6 startAngle:startAngle endAngle:(endAngle-startAngle)*(maxValue / maxValue) + startAngle clockwise:YES];
    [UIColorFromRGB(143234) setStroke];
    bezierLato.lineWidth = 2;
    [bezierLato stroke];
    
    
    UIBezierPath *bezierPath = [UIBezierPath bezierPath];
    
    [bezierPath addArcWithCenter:CGPointMake(rect.size.width/2, rect.size.height/2) radius:radius startAngle:startAngle endAngle:(endAngle-startAngle)*(percent / maxValue) + startAngle clockwise:YES];
    
    bezierPath.lineWidth = lineWith+3;
    [[UIColor redColor] setStroke];
    [bezierPath stroke];
    
    CGRect textRect = CGRectMake((rect.size.width/2.0) - 71/2.0, (rect.size.height / 3.0) -10/3.0, 71, 45);
    
    CGRect valueRect = CGRectMake((rect.size.width/2.0) - 71/2.0, (rect.size.height / 3.0) + 100/3.0, 71, 45);
    [[UIColor blackColor] setFill];
    //[textContent drawInRect:textRect withFont:[UIFont fontWithName:@"Helvetica-Bold" size:30.0] lineBreakMode:NSLineBreakByWordWrapping alignment:NSTextAlignmentCenter];
    
    UIFont *font = [UIFont fontWithName:@"Helvetica-Bold" size:30.0];
    /// Make a copy of the default paragraph style
    NSMutableParagraphStyle *paragraphStyle = [[NSParagraphStyle defaultParagraphStyle] mutableCopy];
    /// Set line break mode
    paragraphStyle.lineBreakMode = NSLineBreakByWordWrapping;
    /// Set text alignment
    paragraphStyle.alignment = NSTextAlignmentCenter;
    
    NSDictionary *attributes = @{ NSFontAttributeName: font,
                                  NSParagraphStyleAttributeName: paragraphStyle };
    [textContent drawInRect:textRect withAttributes:attributes];
    
  //  [value drawInRect:valueRect withFont:[UIFont fontWithName:@"Helvetica-Bold" size:10.0] lineBreakMode:NSLineBreakByWordWrapping alignment:NSTextAlignmentCenter];
    UIFont *font2 = [UIFont fontWithName:@"Helvetica-Bold" size:10.0];
    /// Make a copy of the default paragraph style
    NSMutableParagraphStyle *paragraphStyle2 = [[NSParagraphStyle defaultParagraphStyle] mutableCopy];
    /// Set line break mode
    paragraphStyle2.lineBreakMode = NSLineBreakByWordWrapping;
    /// Set text alignment
    paragraphStyle2.alignment = NSTextAlignmentCenter;
    
    NSDictionary *attributes2 = @{ NSFontAttributeName: font2,
                                  NSParagraphStyleAttributeName: paragraphStyle2 };
    [value drawInRect:valueRect withAttributes:attributes2];

}


@end
