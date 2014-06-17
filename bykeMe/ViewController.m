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
        
        NSArray* posArray = [[NSArray alloc] initWithObjects:startPoint,endPoint, nil];
        MKCoordinateRegion region = [self regionForAnnotations:posArray];
        [myMap setRegion:region animated:YES];
        
        UIGraphicsBeginImageContext(myMap.frame.size);
        [myMap.layer renderInContext:UIGraphicsGetCurrentContext()];
        UIImage * image = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
        
        if([SLComposeViewController isAvailableForServiceType:SLServiceTypeFacebook]) {
            NSString *temp;
        
            SLComposeViewController *controller = [SLComposeViewController composeViewControllerForServiceType:SLServiceTypeFacebook];
            
            if(distance<1000)
                temp = [NSString stringWithFormat:@"I'm running %.01f m with RunMe! - development version - for iPhone",distance];
            else
                temp = [NSString stringWithFormat:@"I'm running %.02f Km with RunMe! - development version - for iPhone",distance2];
        
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

-(MKCoordinateRegion)regionForAnnotations:(NSArray*)annotations {

    MKCoordinateRegion region;
    
    if([annotations count] == 0)
    {
        region = MKCoordinateRegionMakeWithDistance(myMap.userLocation.coordinate, 1000, 1000);
    }
    else if ([annotations count] == 1)
    {
        id<MKAnnotation> annotation = [annotations lastObject];
        region = MKCoordinateRegionMakeWithDistance(annotation.coordinate, 1000, 1000);
    }
    else
    {
        CLLocationCoordinate2D topLeftCoord;
        topLeftCoord.latitude = -90;
        topLeftCoord.longitude = 180;
        
        CLLocationCoordinate2D bottomRighCoord;
        bottomRighCoord.latitude = 90;
        bottomRighCoord.longitude = -180;
        
        for( id <MKAnnotation> annotation in annotations)
        {
            topLeftCoord.latitude = fmax(topLeftCoord.latitude, annotation.coordinate.latitude);
            topLeftCoord.longitude = fmin(topLeftCoord.longitude, annotation.coordinate.longitude);
            bottomRighCoord.latitude = fmin(bottomRighCoord.latitude, annotation.coordinate.latitude);
            bottomRighCoord.longitude = fmax(bottomRighCoord.longitude, annotation.coordinate.longitude);
        }
        
        const double extraSpace = 1.12;
        
        region.center.latitude = topLeftCoord.latitude - (topLeftCoord.latitude-bottomRighCoord.latitude)/2.0;
        region.center.longitude = topLeftCoord.longitude - (topLeftCoord.longitude-bottomRighCoord.longitude)/2.0;
        region.span.latitudeDelta = fabs(topLeftCoord.latitude-bottomRighCoord.latitude)*extraSpace;
        region.span.longitudeDelta = fabs(topLeftCoord.longitude-bottomRighCoord.longitude)* extraSpace;
    }
    
    return [myMap regionThatFits:region];
}

-(void) showBannerAd {
    if(!bannerIsVisible)
    {
        bannerIsVisible = true;
        [UIView beginAnimations:@"animateAdBannerOff" context:NULL];
        banner.frame = CGRectOffset(banner.frame, 0, -banner.frame.size.height);
        myMap.frame = CGRectMake(myMap.frame.origin.x, myMap.frame.origin.y, myMap.frame.size.width, myMap.frame.size.height - banner.frame.size.height);
        m_testView.frame = CGRectOffset(m_testView.frame, 0, -banner.frame.size.height);
        [UIView commitAnimations];
    }

}

-(void) hideBannerAD {
      if(bannerIsVisible)
      {
    [UIView beginAnimations:@"animateAdBannerOff" context:NULL];
    banner.frame = CGRectOffset(banner.frame, 0, +banner.frame.size.height);
    myMap.frame = CGRectMake(myMap.frame.origin.x, myMap.frame.origin.y, myMap.frame.size.width, myMap.frame.size.height + banner.frame.size.height);
    m_testView.frame = CGRectOffset(m_testView.frame, 0, +banner.frame.size.height);
    [UIView commitAnimations];
    bannerIsVisible = NO;
      }

}

-(void)bannerViewDidLoadAd:(ADBannerView *)banner{
    [self showBannerAd];
   }

-(void)bannerView:(ADBannerView *)banner didFailToReceiveAdWithError:(NSError *)error {
    [self hideBannerAD];
  }

-(void)startLocation {
    locationManager = [[CLLocationManager alloc] init];
    locationManager.delegate = self;
    locationManager.distanceFilter = kCLDistanceFilterNone; // whenever we move
    locationManager.desiredAccuracy = kCLLocationAccuracyBestForNavigation; // 100 m
    [locationManager startUpdatingLocation];
}

-(void)hideBanner{
    
    [bannerTimer invalidate];
    bannerTimer = nil;
    [bannerKM setHidden:YES];
    bannerGoShowed = false;
}

- (IBAction)changeUnits:(id)sender {
    if(isKmh)
    {
        isKmh = NO;
        [_btnUnits setTitle:@"Units mph" forState:UIControlStateNormal];

//      [sender setTitle:@"Units mph" forState:UIControlStateNormal];
        m_testView.indicator = @"mph";
    }
    else
    {
        isKmh = YES;
        [_btnUnits setTitle:@"Units Km/h" forState:UIControlStateNormal];
        m_testView.indicator = @"Km/h";
    }
    [m_testView setNeedsDisplay];
    
    if([options count]==0)
        [options addObject:[NSNumber numberWithBool:isKmh]];
    else
        [options replaceObjectAtIndex:0 withObject:[NSNumber numberWithBool:isKmh]];
    
    [self saveOptions];
}

-(void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations{
    
    
    float kph = 3.6;
    float mph = 2.23693629;
    float speed = 0.0;
        
    NSString *unit = @"";
    
    pos = [locations lastObject];
    
    MKCoordinateRegion reg = MKCoordinateRegionMake(pos.coordinate, MKCoordinateSpanMake(0.0001, 0.0001));
    
    if(!regionCreated) {
        [myMap setRegion:reg];
        regionCreated = true;
    }
    
    [myMap setCenterCoordinate:pos.coordinate];
    
    if(RUNNING) {
    
        if(!prevpoint) {
            currPoint = pos;
            prevpoint = true;
        }
        else
        {
            prevPoint = pos;
            prevpoint = false; }
        
    //[savedPoint addObject:pos];
    [self updateLines];

        lastPoint = pos;
        
    if(firstPoint==nil)
    {
        firstPoint = pos;
        [self setInitialPoint:firstPoint];
    }
        
        
    if(pos.verticalAccuracy<=100.0)
    {
        statusLabel.text =@"Running...";
        gpsLabel.textColor = [UIColor greenColor];
       
        if(timeTimer==nil)
        {
            timeTimer = [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(timer) userInfo:nil repeats:YES];
            
            self.backgroundTask = [[UIApplication sharedApplication] beginBackgroundTaskWithExpirationHandler:^{
                NSLog(@"Background handle called, Not running background task anymore");
                [[UIApplication sharedApplication] endBackgroundTask:self.backgroundTask];
                self.backgroundTask = UIBackgroundTaskInvalid;
            }];

            
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
        m_testView.indicator = @"Km/h";
        //lblUnitSpeed.text = @"Km/h";
    }
    else {
        speed = pos.speed * mph;
       // lblUnitSpeed.text = @"mph";
        m_testView.indicator = @"mph";
    }
    
    if(speed<0) speed=0.0;
    
    lblAltitude.text = [NSString stringWithFormat:@"%.01f mt",pos.altitude];
    lblSpeed.text = [NSString stringWithFormat:@"%.01f", speed];
    
    oldPos = pos;
    
        
    if(iseAltitude==0)
        iseAltitude = pos.altitude;
    else {
        if(pos.altitude>iseAltitude)
            iseAltitude = pos.altitude;
        
      //  viewAltitude.percent = (100*pos.altitude)/iseAltitude;
        
    }
    
    if(distance<1000)
        iseDistance = distance;
    else
        iseDistance = distance2;

        
    if(speed<=50)
        m_testView.maxValue = 50;
    if(speed>50 && speed<=100)
        m_testView.maxValue = 100;
    if(speed>100 && speed<=200)
        m_testView.maxValue = 200;
    if(speed>200)
        m_testView.maxValue = 400;
        
    if(iseMaxSpeed==0)
        iseMaxSpeed = speed;
    else {
        if(speed>iseMaxSpeed)
        {
            iseMaxSpeed = speed;
        }
        
        m_testView.percent = speed;
        [m_testView setNeedsDisplay];
        
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
        if(self.backgroundTask != UIBackgroundTaskInvalid)
        {
            [[UIApplication sharedApplication] endBackgroundTask:self.backgroundTask];
            self.backgroundTask = UIBackgroundTaskInvalid;
        }

    }
    }
    
}

-(void)decrementSpeed
{
    if(m_testView.percent > 0)
    {
        m_testView.percent = m_testView.percent - 1;
        [m_testView setNeedsDisplay];
    }
    else
    {
        [m_timer invalidate];
        m_timer = nil;
    }
    
}

-(void)loadOptions {
    FileSupport *myFile = [[FileSupport alloc] init];
    
    NSMutableArray *testArray = [myFile readDataFromFile:@"options.plist"];
    
    if(testArray!=nil)
    {
        options  = [myFile readDataFromFile:@"options.plist"];
        
        isKmh = [[options objectAtIndex:0] boolValue];
        if(isKmh) {
            m_testView.indicator = @"Km/h";
            [_btnUnits setTitle:@"Units Km/h" forState:UIControlStateNormal];
        }
        else {
            m_testView.indicator = @"mph";
            [_btnUnits setTitle:@"Units mph" forState:UIControlStateNormal];
        }
        
    }
    
}

-(void)saveOptions {
    //[self loadOptions];

    FileSupport *myFile = [[FileSupport alloc] init];
    
    [myFile writeDataToFile:options fileToWrite:@"options.plist"];
}


- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    //if(banner == nil)
    //    banner = [[ADBannerView alloc] init];
    //banner.delegate = self;
    //[banner setDelegate:self];
    bannerIsVisible = TRUE;
    
    //test
    
    m_testView = [[BeizerView alloc] initWithFrame:self.viewTest.bounds];
    m_testView.percent = 0.0;
    m_testView.lineWith = 10;
    m_testView.maxValue = 200;
    [self.viewTest addSubview:m_testView];
  //  m_timer = [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(decrementSpeed) userInfo:nil repeats:YES];
    myMap.showsUserLocation = YES;
    
    
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
    RUNNING = false;
    
    options = [[NSMutableArray alloc] init];
    [self loadOptions];
    
    
    sessDate     = [[NSMutableArray alloc] init];
    sessDistance = [[NSMutableArray alloc] init];
    sessAltitude = [[NSMutableArray alloc] init];
    sessAvgSpeed = [[NSMutableArray alloc] init];
    sessMaxSpeed = [[NSMutableArray alloc] init];
    savedPoint   = [[NSMutableArray alloc] init];
    
    //iCFile = [[FileSupport alloc] init];
    //iCFile.delegate = self;
   // [iCFile initiCloudFile:@"RunMeData.data"];
     [self startLocation];
    
    banner.delegate = self;
    [self hideBannerAD];
    [[UIApplication sharedApplication] setIdleTimerDisabled:YES];
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
    @autoreleasepool {
        
    
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
    
    }
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
   /* [UIView animateWithDuration:0.5 animations:^{
        CGAffineTransform trasform = CGAffineTransformMakeRotation(DEGREES_TO_RADIANS(0));
        startBtn.transform = trasform;
    }];*/
    [locationManager stopUpdatingLocation];
    [bannerKM setHidden:true];
    myMap.showsUserLocation = false;
    STARTED = false;
    [timeTimer invalidate];
    timeTimer = nil;
    if(self.backgroundTask != UIBackgroundTaskInvalid)
    {
        [[UIApplication sharedApplication] endBackgroundTask:self.backgroundTask];
        self.backgroundTask = UIBackgroundTaskInvalid;
    }
    oldPos = nil;
    firstPoint = nil;
    lastPoint = nil;
    startPoint = nil;
    endPoint = nil;
    savedPoint = [[NSMutableArray alloc] init];
    SESSION_ACTIVE = false;
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
    RUNNING = false;
    m_testView.maxValue = 50;
    m_testView.percent = 0.0;
    [m_testView setNeedsDisplay];
    
    NSArray *pointArray = [myMap overlays];
    [myMap removeOverlays:pointArray];
    
    NSArray *pointAnn = [myMap annotations];
    [myMap removeAnnotations:pointAnn];
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
    
 //   iCloudArray = [[NSMutableArray alloc] initWithObjects:sessDate,sessAltitude,sessAvgSpeed,sessDistance,sessMaxSpeed, nil];
 //   [iCFile saveFile:iCloudArray];

    
}

-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    
        if(buttonIndex==2)
        {
            [self resetData];
             [UIView animateWithDuration:0.5 animations:^{
             CGAffineTransform trasform = CGAffineTransformMakeRotation(DEGREES_TO_RADIANS(0));
             startBtn.transform = trasform;
             }];
        }
        if(buttonIndex==1)
        {
            [self saveSession];
            [self setFinalPoint];
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
            if(self.backgroundTask != UIBackgroundTaskInvalid)
            {
                [[UIApplication sharedApplication] endBackgroundTask:self.backgroundTask];
                self.backgroundTask = UIBackgroundTaskInvalid;
            }
            
            statusLabel.text = @"Stopped";
            RUNNING = false;
            m_testView.maxValue = 50;
            m_testView.percent = 0.0;
            [m_testView setNeedsDisplay];
            NSArray* posArray = [[NSArray alloc] initWithObjects:startPoint,endPoint, nil];
            MKCoordinateRegion region = [self regionForAnnotations:posArray];
            [myMap setRegion:region animated:YES];

        }
}



-(void) setInitialPoint:(CLLocation*)start_loc {
    MKPointAnnotation *point = [[MKPointAnnotation alloc]init];
    point.coordinate = start_loc.coordinate;
    point.title = @"Start";
    firstPoint = start_loc;
    startPoint = point;
    [myMap addAnnotation:point];
    [myMap selectAnnotation:point animated:TRUE];
}

-(void) setFinalPoint{
    MKPointAnnotation *point = [[MKPointAnnotation alloc]init];
    point.coordinate = lastPoint.coordinate;
    point.title = @"End";
    //end_point = lastPoint;
    endPoint = point;
    [myMap addAnnotation:point];

    //NSArray* annotations_array = [[NSArray alloc] initWithObjects:firstPoint, point, nil];
    [myMap selectAnnotation:point animated:TRUE];
}

- (IBAction)startByking:(id)sender {
        if(!STARTED)
        {
            [UIView animateWithDuration:0.5 animations:^{
                CGAffineTransform trasform = CGAffineTransformMakeRotation(DEGREES_TO_RADIANS(-90));
                startBtn.transform = trasform;
            }];
            if(SESSION_ACTIVE)
                [self resetData];
            statusLabel.text = @"Running...";
            STARTED = true;
            myMap.showsUserLocation=true;
            oldPos = nil;
            firstPoint = nil;
            lastPoint = nil;
            distance = 0.0;
            distance2 = 0.0;
            num_of_point = 0;
            iseAvgSpeed = 0;
            iseDistance = 0;
            iseMaxSpeed = 0;
            iseAltitude = 0;
            RUNNING=true;
            [self startLocation];
            SESSION_ACTIVE = true;
            
        }
    else
    {
       // if(distance>100)
       // {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"New session" message:@"A session is active. What would you like to do?" delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"Save session",@"Cancel session", nil];
            
            [alert show];
     /*   }
        else
        {
            [self resetData];
        }*/
    }
    
}

#pragma mark Map delegate
- (MKOverlayView *) mapView:(MKMapView *)mapView viewForOverlay:(id<MKOverlay>)overlay
{
    if([overlay isKindOfClass:[MKPolyline class]])
    {
        MKPolylineView *aView = [[MKPolylineView alloc] initWithPolyline:overlay];
        aView.fillColor = [[UIColor blackColor] colorWithAlphaComponent:0.2];
        aView.strokeColor = [[UIColor blueColor] colorWithAlphaComponent:0.7];
        aView.lineWidth = 10;
        return aView;
    }
    else {
        return nil;
    }
}

-(void)updateLines {
    //Add drawing of route line
 
    if(prevpoint && prevPoint!=nil && currPoint!=nil) {
    [savedPoint addObject:prevPoint];
    [savedPoint addObject:currPoint];
    
    NSInteger numberOfSteps = savedPoint.count;
    
    CLLocationCoordinate2D coordinates[numberOfSteps];
    
    int i=0;
    for (CLLocation *loc in savedPoint)
    {
        CLLocationCoordinate2D l = loc.coordinate;
        coordinates[i] = l;
        i++;
    }
    
    MKPolyline *route = [MKPolyline polylineWithCoordinates:coordinates count:i];
    [myMap addOverlay:route];
    }
}


@end
