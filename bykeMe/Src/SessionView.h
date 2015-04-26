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
#import "SessionData.h"

@interface SessionView : UIViewController <UITableViewDataSource,UITableViewDelegate> {
    
    SessionData *sessions;    
    IBOutlet UINavigationItem *navigationItemTitle;
    IBOutlet UIBarButtonItem *btnShare;
}

@property (strong, nonatomic) IBOutlet UITableView *sessionTable;
@property (strong,nonatomic) myDoc *document_titles;

@end
