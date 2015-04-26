//
//  BeizerView.h
//  RunMe!
//
//  Created by Riccardo Rizzo on 31/05/14.
//  Copyright (c) 2014 Riccardo Rizzo. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface BeizerView : UIView {
    CGFloat startAngle;
    CGFloat endAngle;
    double percent;
    NSInteger radius;
    NSInteger lineWith;
    NSUInteger maxValue;
    NSString *indicator;
}

@property (nonatomic) double percent;
@property (nonatomic) NSInteger radius;
@property (nonatomic) NSInteger lineWith;
@property (nonatomic) NSUInteger maxValue;
@property (nonatomic) NSString *indicator;

@end
