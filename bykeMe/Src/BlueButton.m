//
//  BlueButton.m
//  RunMe!
//
//  Created by Riccardo Rizzo on 11/07/16.
//  Copyright © 2016 Riccardo Rizzo. All rights reserved.
//

#import "BlueButton.h"
#import "RunMeButton.h"

@implementation BlueButton


// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
    [RunMeButton drawBlueButton: rect];
}


@end
