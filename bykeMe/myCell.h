//
//  myCell.h
//  bykeMe
//
//  Created by Riccardo Rizzo on 20/05/14.
//  Copyright (c) 2014 Riccardo Rizzo. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface myCell : UITableViewCell
@property (strong, nonatomic) IBOutlet UILabel *lblDate;
@property (strong, nonatomic) IBOutlet UILabel *lblDistance;
@property (strong, nonatomic) IBOutlet UILabel *lblMaxSpeed;
@property (strong, nonatomic) IBOutlet UILabel *lblAvgSpeed;
@property (strong, nonatomic) IBOutlet UILabel *lblAltitude;
@property (strong, nonatomic) IBOutlet UILabel *lblRythm;

@end
