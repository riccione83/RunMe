//
//  sessions.h
//  bykeMe
//
//  Created by Riccardo Rizzo on 20/05/14.
//  Copyright (c) 2014 Riccardo Rizzo. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FileSupport.h"
#import "myCell.h"

@interface sessions : UIViewController <UITableViewDataSource,UITableViewDelegate> {
    NSMutableArray *sessDate;
    NSMutableArray *sessDistance;
    NSMutableArray *sessMaxSpeed;
    NSMutableArray *sessAvgSpeed;
    NSMutableArray *sessAltitude;
}

@property (strong, nonatomic) IBOutlet UITableView *sessionTable;

@end
