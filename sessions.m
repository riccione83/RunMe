//
//  sessions.m
//  bykeMe
//
//  Created by Riccardo Rizzo on 20/05/14.
//  Copyright (c) 2014 Riccardo Rizzo. All rights reserved.
//

#import "sessions.h"

@interface sessions ()

@end

@implementation sessions

@synthesize sessionTable;

#pragma mark LoadSession

- (IBAction)returnToMainView:(id)sender {
        [self dismissViewControllerAnimated:YES completion:nil];
}


-(void)saveSessions {
    
    FileSupport *myFile = [[FileSupport alloc] init];
    
    [myFile writeDataToFile:sessDate fileToWrite:@"sessionDate.txt"];
    [myFile writeDataToFile:sessAltitude fileToWrite:@"sessionAltitude.txt"];
    [myFile writeDataToFile:sessAvgSpeed fileToWrite:@"sessionAvgSpeed.txt"];
    [myFile writeDataToFile:sessDistance fileToWrite:@"sessionDistance.txt"];
    [myFile writeDataToFile:sessMaxSpeed fileToWrite:@"sessionMaxSpeed.txt"];
}

-(void)loadSessions {
    FileSupport *myFile = [[FileSupport alloc] init];
    
    NSMutableArray *testArray = [myFile readDataFromFile:@"sessionDate.txt"];
    
    if(testArray!=nil)
    {
        sessDate     = [myFile readDataFromFile:@"sessionDate.txt"];
        sessDistance = [myFile readDataFromFile:@"sessionDistance.txt"];
        sessAltitude = [myFile readDataFromFile:@"sessionAltitude.txt"];
        sessAvgSpeed = [myFile readDataFromFile:@"sessionAvgSpeed.txt"];
        sessMaxSpeed = [myFile readDataFromFile:@"sessionMaxSpeed.txt"];
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
        
        [sessDate removeObjectAtIndex:indexPath.row];
        [sessDistance removeObjectAtIndex:indexPath.row];
        [sessAltitude removeObjectAtIndex:indexPath.row];
        [sessAvgSpeed removeObjectAtIndex:indexPath.row];
        [sessMaxSpeed removeObjectAtIndex:indexPath.row];
        
        [self saveSessions];
        
        [sessionTable reloadData]; // tell table to refresh now
    }
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [sessDate count];
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
    
    cell.lblDate.text = [NSString stringWithFormat:@"DATE %@",[sessDate objectAtIndex:indexPath.row]];
    cell.lblMaxSpeed.text =[NSString stringWithFormat:@"Speed %@ Km/h Max",[sessMaxSpeed objectAtIndex:indexPath.row]];
    cell.lblAltitude.text =[NSString stringWithFormat:@"Altitude %@ mt Max",[sessAltitude objectAtIndex:indexPath.row]];
    cell.lblAvgSpeed.text =[NSString stringWithFormat:@"%@ Km/h Avg",[sessAvgSpeed objectAtIndex:indexPath.row]];
    cell.lblDistance.text = [NSString stringWithFormat:@"Distance %@ Km",[sessDistance objectAtIndex:indexPath.row]];
    
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
    [self loadSessions];
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