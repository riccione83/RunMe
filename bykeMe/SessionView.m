//
//  sessions.m
//  bykeMe
//
//  Created by Riccardo Rizzo on 20/05/14.
//  Copyright (c) 2014 Riccardo Rizzo. All rights reserved.
//

#import "SessionView.h"
#import "FileSupport.h"
#import "myDoc.h"
#import <Social/Social.h>

@interface SessionView ()

@end

@implementation SessionView
FileSupport *iCFile;
@synthesize sessionTable;

#pragma mark LoadSession

- (IBAction)returnToMainView:(id)sender {
        [self dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)postOnFacebook:(id)sender {
    
        NSIndexPath *position = [sessionTable indexPathForSelectedRow];
    
       // myCell cell = [sessionTable cellForRowAtIndexPath:position];
    
        UIImage *image = [sessions.imagesSession objectAtIndex:position.row];
    
        if([SLComposeViewController isAvailableForServiceType:SLServiceTypeFacebook])
        {
            NSString *temp;
            
            SLComposeViewController *controller = [SLComposeViewController composeViewControllerForServiceType:SLServiceTypeFacebook];
            
            temp = [NSString stringWithFormat:@"I'm running %.02f Km with RunMe! for iPhone",[[sessions.Distances objectAtIndex:position.row] floatValue]];
            
            [controller setInitialText:temp];
            //[controller add]
            [controller addImage:image];
            [self presentViewController:controller animated:YES completion:Nil];
        }
        else
        {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Share on Facebook" message:@"Sorry but you don't have a Facebook account on your iPhone. Please add one and try again. Thankyou." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
            
            [alert show];
        }
    }


#pragma mark TableViewDelegate

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    return YES;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        //remove the deleted object from your data source.
        //If your data source is an NSMutableArray, do this
        
        [sessions.Dates removeObjectAtIndex:indexPath.row];
        [sessions.Distances removeObjectAtIndex:indexPath.row];
        [sessions.Altitudes removeObjectAtIndex:indexPath.row];
        [sessions.AvgSpeeds removeObjectAtIndex:indexPath.row];
        [sessions.MaxSpeeds removeObjectAtIndex:indexPath.row];
        
        //[self saveSessions];
        [sessions saveSessions];
        
        [sessionTable reloadData]; // tell table to refresh now
    }
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [sessions.Dates count];
}

-(UITableViewCell *) tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *simpleTableIdentifier = @"customCell";
    
    myCell *cell = (myCell *)[tableView dequeueReusableCellWithIdentifier:simpleTableIdentifier];
    if (cell == nil)
    {
        NSArray *nib = [[NSBundle mainBundle] loadNibNamed:@"customCell" owner:self options:nil];
        cell = [nib objectAtIndex:0];
    }
    
    /*cell.nameLabel.text = [tableData objectAtIndex:indexPath.row];
    cell.thumbnailImageView.image = [UIImage imageNamed:[thumbnails objectAtIndex:indexPath.row]];
    cell.prepTimeLabel.text = [prepTime objectAtIndex:indexPath.row];*/
    
    cell.lblDate.text = [NSString stringWithFormat:@"DATE %@",[sessions.Dates objectAtIndex:indexPath.row]];
    cell.lblMaxSpeed.text =[NSString stringWithFormat:@"Speed %@ Km/h Max",[sessions.MaxSpeeds objectAtIndex:indexPath.row]];
    cell.lblAltitude.text =[NSString stringWithFormat:@"Altitude %@ mt Max",[sessions.Altitudes objectAtIndex:indexPath.row]];
    cell.lblAvgSpeed.text =[NSString stringWithFormat:@"%@ Km/h Avg",[sessions.AvgSpeeds objectAtIndex:indexPath.row]];
    cell.lblDistance.text = [NSString stringWithFormat:@"Distance %@ Km",[sessions.Distances objectAtIndex:indexPath.row]];
    cell.lblRythm.text = [NSString stringWithFormat:@"Rythm: %@/Km",[sessions.Rythms objectAtIndex:indexPath.row]];
    
    return cell;
}

#pragma mark Program

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    sessions = [[SessionData alloc] init];
    [sessions loadSession];
    
    
//    iCFile = [[FileSupport alloc] init];
//    iCFile.delegate = self;
 //   [iCFile initiCloudFile:@"RunMeData.data"];
    //[self loadSessions];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
