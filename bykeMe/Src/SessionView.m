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
    
    if(position != nil) {
    
        UIImage *image = [sessions.imagesSession objectAtIndex:position.row];
    
        if([SLComposeViewController isAvailableForServiceType:SLServiceTypeFacebook]) {
            NSString *temp;
            
            SLComposeViewController *controller = [SLComposeViewController composeViewControllerForServiceType:SLServiceTypeFacebook];
            
            temp = [NSString stringWithFormat:NSLocalizedString(@"RUNNING_MT", nil),[[sessions.Distances objectAtIndex:position.row] floatValue]];
            
            [controller setInitialText:temp];
            [controller addImage:image];
            [self presentViewController:controller animated:YES completion:Nil];
           }
        }
        else
        {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"SHARE_ON_FACEBOOK",nil) message:NSLocalizedString(@"NO_FACEBOOK_ACCOUNT",nil) delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
            
            [alert show];
        }
    }


#pragma mark TableViewDelegate


-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
/*    
    NSIndexPath *position = [sessionTable indexPathForSelectedRow];
    
    if(position != nil) {
        
        UIImage *image = [sessions.imagesSession objectAtIndex:position.row];
        backgroundImage.image = image;
    }
    else {
        backgroundImage.image = [UIImage imageNamed:@"background.png"];
    }
 */
}

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
        [sessions.Rythms removeObjectAtIndex:indexPath.row];
        [sessions.imagesSession removeObjectAtIndex:indexPath.row];
        [sessions.Calories removeObjectAtIndex:indexPath.row];
        
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
    
    float Distance = [[sessions.Distances objectAtIndex:indexPath.row] floatValue];
    
    cell.lblDate.text = [NSString stringWithFormat:NSLocalizedString(@"DATE %@",nil),[sessions.Dates objectAtIndex:indexPath.row]];
    cell.lblMaxSpeed.text =[NSString stringWithFormat:NSLocalizedString(@"Speed %@ Km/h Max",nil),[sessions.MaxSpeeds objectAtIndex:indexPath.row]];
    cell.lblAltitude.text =[NSString stringWithFormat:NSLocalizedString(@"Altitude %@ mt Max",nil),[sessions.Altitudes objectAtIndex:indexPath.row]];
    cell.lblAvgSpeed.text =[NSString stringWithFormat:NSLocalizedString(@"%@ Km/h Avg",nil),[sessions.AvgSpeeds objectAtIndex:indexPath.row]];
    if(Distance<1)
        cell.lblDistance.text = [NSString stringWithFormat:NSLocalizedString(@"Distance %.0f mt",nil),Distance*1000];
    else
        cell.lblDistance.text = [NSString stringWithFormat:NSLocalizedString(@"Distance %.2f Km",nil),Distance];
    
    cell.lblRythm.text = [NSString stringWithFormat:NSLocalizedString(@"Rythm: %@/Km",nil),[sessions.Rythms objectAtIndex:indexPath.row]];
    cell.lblCalorie.text = [NSString stringWithFormat:NSLocalizedString(@"Calories %@", nil),[sessions.Calories objectAtIndex:indexPath.row]];
    
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

-(void)setupUI {
    [navigationItemTitle setTitle:NSLocalizedString(@"My Sessions", nil)];
  //  [btnShare setTitle:NSLocalizedString(@"Share", nil)];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    [self setupUI];
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
