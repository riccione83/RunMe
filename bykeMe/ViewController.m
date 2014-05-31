//
//  ViewController.m
//  bykeMe
//
//  Created by Riccardo Rizzo on 15/05/14.
//  Copyright (c) 2014 Riccardo Rizzo. All rights reserved.
//

//#define M_PI 3.14159265359

#define DEGREES_TO_RADIANS(angle)  (angle / 180.0 * M_PI)



#import "ViewController.h"

@interface ViewController ()
  
@end

@implementation ViewController

@synthesize banner;
@synthesize myMap;
@synthesize panelView;
@synthesize onOffView;
@synthesize startBtn;
@synthesize hint;
@synthesize lblAltitude,lblDistance,lblSpeed,lblTime,lblUnitSpeed;
@synthesize bannerKM,labelKM;
@synthesize statusLabel,gpsLabel;


- (IBAction)postOnFacebook:(id)sender {
    
    if(distance>100 || distance2>1.0)
    {
        UIGraphicsBeginImageContext(myMap.frame.size);
        [myMap.layer renderInContext:UIGraphicsGetCurrentContext()];
        UIImage * image = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
        
        if([SLComposeViewController isAvailableForServiceType:SLServiceTypeFacebook]) {
            NSString *temp;
        
            SLComposeViewController *controller = [SLComposeViewController composeViewControllerForServiceType:SLServiceTypeFacebook];
            if(distance<1000)
                temp = [NSString stringWithFormat:@"I'm running %.01f m with RunMe! for iPhone",distance];
            else
                temp = [NSString stringWithFormat:@"I'm running %.02f Km with RunMe! for iPhone",distance2];
        
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
    else
    {
        UIAlertView *al = [[UIAlertView alloc] initWithTitle:@"Share on Facebook" message:@"Sorry, for share on facebook you need to run at least 100 meters." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [al show];
    }
}

-(void)startLocation {
    locationManager = [[CLLocationManager alloc] init];
    locationManager.delegate = self;
    locationManager.distanceFilter = kCLDistanceFilterNone; // whenever we move
    locationManager.desiredAccuracy = kCLLocationAccuracyBest; // 100 m
    [locationManager startUpdatingLocation];
}

-(void)hideBanner{
    
    [bannerTimer invalidate];
    bannerTimer = nil;
    [bannerKM setHidden:YES];
    bannerGoShowed = false;
}

-(void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations{
    
    
    float kph = 3.6;
    float mph = 2.23693629;
    float speed = 0.0;
        
    NSString *unit = @"";
    
    pos = [locations lastObject];
    
    if(pos.verticalAccuracy<=10.0)
    {
        statusLabel.text =@"Running...";
        gpsLabel.textColor = [UIColor greenColor];
       
        if(timeTimer==nil)
        {
            timeTimer = [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(timer) userInfo:nil repeats:YES];
        }
        
    NSLog(@"Accuracy: %f",pos.verticalAccuracy);
    
    
    if(oldPos!=nil)
    {
        CLLocationDistance meters = [pos distanceFromLocation:oldPos];
        distance += meters;
    }
    
    if(distance<1000)
    {
        unit = @"mt";
        lblDistance.text = [NSString stringWithFormat:@"%.01f %@",distance,unit];
    }
    else
    {
        distance2 = distance/1000;
        unit = @"km";
        lblDistance.text = [NSString stringWithFormat:@"%.02f %@",distance2,unit];
        
        if((distance2 > 1.0) && (distance2<1.1) && bannerGoShowed==false)
        {
            bannerGoShowed = true;
            [bannerKM setHidden:false];
            labelKM.text = @"1 Km";
            bannerTimer = [NSTimer scheduledTimerWithTimeInterval:5 target:self selector:@selector(hideBanner) userInfo:nil repeats:NO];
        }
        
        if( ((distance2 == 10.0)||(distance2 == 20.0)||(distance2 == 30.0)||(distance2 == 40.0)||(distance2 == 50.0)||(distance2 == 60.0)||(distance2 == 70.0)||(distance2 == 80.0)||(distance2 == 90.0)||(distance2 == 100.0))  && bannerGoShowed==false)
        {
            labelKM.text = [NSString stringWithFormat:@"%01f Km",distance];
            bannerGoShowed = true;
            [bannerKM setHidden:false];
            bannerTimer = [NSTimer scheduledTimerWithTimeInterval:2 target:self selector:@selector(hideBanner) userInfo:nil repeats:NO];
        }
    }
    
    
    if(isKmh) {
        speed = pos.speed * kph;
        lblUnitSpeed.text = @"Km/h";
    }
    else {
        speed = pos.speed * mph;
        lblUnitSpeed.text = @"mph";
    }
    
    if(speed<0) speed=0.0;
    
    lblAltitude.text = [NSString stringWithFormat:@"%.01f mt",pos.altitude];
    lblSpeed.text = [NSString stringWithFormat:@"%.01f", speed];
    
    MKCoordinateRegion reg = MKCoordinateRegionMake(pos.coordinate, MKCoordinateSpanMake(0.001, 0.001));
    
    if(!regionCreated) {
        [myMap setRegion:reg];
        regionCreated = true;
    }
    
    [myMap setCenterCoordinate:pos.coordinate];
    
    oldPos = pos;
    
    if(iseAltitude==0)
        iseAltitude = pos.altitude;
    else {
        if(pos.altitude>iseAltitude)
            iseAltitude = pos.altitude;
    }
    
    if(distance<1000)
        iseDistance = distance;
    else
        iseDistance = distance2;
    
    if(iseMaxSpeed==0)
        iseMaxSpeed = speed;
    else {
        if(speed>iseMaxSpeed)
            iseMaxSpeed = speed;
    }
    
    num_of_point++;
    tempAvgSpeed += speed;
    iseAvgSpeed = (tempAvgSpeed/num_of_point);
    }
    else
    {
        gpsLabel.textColor = [UIColor redColor];
        statusLabel.text =@"Waiting for a better gps signal...";
        [timeTimer invalidate];
        timeTimer = nil;
    }

    
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    //banner = [[ADBannerView alloc] init];
    [banner setDelegate:self];

    
    [UIView animateWithDuration:0.0 animations:^{
        CGAffineTransform trasform = CGAffineTransformMakeScale(0, 0);
        hint.transform = trasform;
    }];
    
    num_of_point = 0;
    iseAvgSpeed = 0;
    iseDistance = 0;
    iseMaxSpeed = 0;
    iseAltitude = 0;
    tempAvgSpeed = 0;
    
    STARTED = false;
    menuShowed = FALSE;
    isKmh = true;
    bannerGoShowed = false;
    
    
    sessDate     = [[NSMutableArray alloc] init];
    sessDistance = [[NSMutableArray alloc] init];
    sessAltitude = [[NSMutableArray alloc] init];
    sessAvgSpeed = [[NSMutableArray alloc] init];
    sessMaxSpeed = [[NSMutableArray alloc] init];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)showOnOffPanel:(id)sender {
    [UIView animateWithDuration:0.5 animations:^{
        CGAffineTransform trasform = CGAffineTransformMakeTranslation(0, 0);
        onOffView.transform = trasform;
    }];
    menuShowed = true;
    [UIView animateWithDuration:0.5 animations:^{
        CGAffineTransform trasform = CGAffineTransformMakeScale(0, 0);
        hint.transform = trasform;
    }];
    [hint setHidden:true];
}

- (IBAction)closePanel:(id)sender {
    
    [UIView animateWithDuration:0.5 animations:^{
        CGAffineTransform trasform = CGAffineTransformMakeTranslation(0, -400);
        onOffView.transform = trasform;
    }];
    
    if(!menuShowed)
    {
        [hint setHidden:false];
        [UIView animateWithDuration:0.5 animations:^{
            CGAffineTransform trasform = CGAffineTransformMakeScale(1, 1);
            hint.transform = trasform;
        }];
        
        hideMenuTimer = [NSTimer scheduledTimerWithTimeInterval:5 target:self selector:@selector(hideBannerMenu) userInfo:nil repeats:NO];
    }
    
}

-(void)hideBannerMenu{
            menuShowed = true;
            [UIView animateWithDuration:0.5 animations:^{
                CGAffineTransform trasform = CGAffineTransformMakeScale(0, 0);
                hint.transform = trasform;
            } completion:^(BOOL finished) {
                [hint setHidden:YES];
            }];
       //     [hint setHidden:true];
    [hideMenuTimer invalidate];
    hideMenuTimer=nil;
}


-(void)timer {
    
    iSec++;
    if(iSec==60) {
        iSec = 0;
        iMin++;
    }
    
    if(iMin == 60)
    {
        iMin = 0;
        iHr++;
    }
    
    lblTime.text = [NSString stringWithFormat:@"%02d:%02d:%02d",iHr,iMin,iSec];
    
    
  /*  if(!menuShowed)
    {
        if(iSec>=5)
        {
            menuShowed = true;
            [UIView animateWithDuration:0.5 animations:^{
                CGAffineTransform trasform = CGAffineTransformMakeScale(0, 0);
                hint.transform = trasform;
            }];
            [hint setHidden:true];
        }
    }*/
    
}

-(void)resetData {
    [UIView animateWithDuration:0.5 animations:^{
        CGAffineTransform trasform = CGAffineTransformMakeRotation(DEGREES_TO_RADIANS(0));
        startBtn.transform = trasform;
    }];
    [locationManager stopUpdatingLocation];
    [bannerKM setHidden:true];
    myMap.showsUserLocation = false;
    STARTED = false;
    [timeTimer invalidate];
    timeTimer = nil;
    oldPos = nil;
    distance = 0.0;
    iSec = 0; iMin=0; iHr = 0;
    lblTime.text = [NSString stringWithFormat:@"%02d:%02d:%02d",iHr,iMin,iSec];
    lblDistance.text = @"0.0";
    lblSpeed.text = @"0.0";
    lblAltitude.text = @"0.0";
    num_of_point = 0;
    iseAvgSpeed = 0;
    iseDistance = 0;
    iseMaxSpeed = 0;
    iseAltitude = 0;
    tempAvgSpeed = 0;
    distance2 =0;
    statusLabel.text = @"Stopped";
}

-(void)loadSession {
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

-(void)saveSession {
    [self loadSession];
    
    
    
    NSDate *currDate = [NSDate date];
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc]init];
    [dateFormatter setDateFormat:@"dd/MM/YY"];
    NSString *dateString = [dateFormatter stringFromDate:currDate];
    
    NSLog(@"%@",dateString);
    
    iseDate = dateString;
    
    
       
    [sessDate addObject:iseDate];
    [sessAltitude addObject:[NSNumber numberWithInteger:iseAltitude]];
    [sessAvgSpeed addObject:[NSNumber numberWithInteger:iseAvgSpeed]];
    [sessDistance addObject:[NSNumber numberWithInteger:iseDistance]];
    [sessMaxSpeed addObject:[NSNumber numberWithInteger:iseMaxSpeed]];
    
    FileSupport *myFile = [[FileSupport alloc] init];
    
    [myFile writeDataToFile:sessDate fileToWrite:@"sessionDate.txt"];
    [myFile writeDataToFile:sessAltitude fileToWrite:@"sessionAltitude.txt"];
    [myFile writeDataToFile:sessAvgSpeed fileToWrite:@"sessionAvgSpeed.txt"];
    [myFile writeDataToFile:sessDistance fileToWrite:@"sessionDistance.txt"];
    [myFile writeDataToFile:sessMaxSpeed fileToWrite:@"sessionMaxSpeed.txt"];
}

-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    
        if(buttonIndex==2)
            [self resetData];
        if(buttonIndex==1)
        {
            [self saveSession];
            [self resetData];
            //UIAlertView *al2 = [[UIAlertView alloc] initWithTitle:@"TEST" message:@"Salvo i dati" delegate:nil cancelButtonTitle:@"Cancel" otherButtonTitles: nil];
            //[al2 show];
        }
    
    
}


- (IBAction)startByking:(id)sender {
        if(!STARTED)
        {
            [UIView animateWithDuration:0.5 animations:^{
                CGAffineTransform trasform = CGAffineTransformMakeRotation(DEGREES_TO_RADIANS(-90));
                startBtn.transform = trasform;
            }];
            statusLabel.text = @"Running...";
            STARTED = true;
            myMap.showsUserLocation=true;
            oldPos = nil;
            distance = 0.0;
            distance2 = 0.0;
            num_of_point = 0;
            iseAvgSpeed = 0;
            iseDistance = 0;
            iseMaxSpeed = 0;
            iseAltitude = 0;
            
            [self startLocation];
          //  timeTimer = [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(timer) userInfo:nil repeats:YES];
            
        }
    else
    {
        if(distance>100)
        {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Sessione" message:@"Una sessione è attualmente attiva. Cosa desideri fare?" delegate:self cancelButtonTitle:@"Annulla" otherButtonTitles:@"Salva sessione",@"Annulla sessione", nil];
            
            [alert show];
        }
        else
        {
            [self resetData];
        }
    }
}


@end
