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
    NSMutableArray *iCloudArray;
}

@property (strong, nonatomic) IBOutlet UITableView *sessionTable;
@property (strong,nonatomic) myDoc *document_titles;

-(void)loadSessions;
-(void)loadSessions:(BOOL)iCloudSupport;
-(void)saveSessions;
-(void)updateFilesFromiCloud:(NSMutableArray *) _title_ ar2:(NSMutableArray*)_creation ar3:(NSMutableArray*) _descriptions ar4:(NSMutableArray*)_checked ar5:(NSMutableArray*)_notifications_;

@end
