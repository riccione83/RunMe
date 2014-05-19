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
        float distance2 = distance/1000;
        unit = @"km";
        lblDistance.text = [NSString stringWithFormat:@"%.02f %@",distance2,unit];
        
        if((distance2 > 1.0) && (distance2<1.1) && bannerGoShowed==false)
        {
            bannerGoShowed = true;
            [bannerKM setHidden:false];
            bannerTimer = [NSTimer scheduledTimerWithTimeInterval:2 target:self selector:@selector(hideBanner) userInfo:nil repeats:NO];
        }
        
        if( ((distance2 == 10.0)||(distance2 == 20.0)||(distance2 == 30.0)||(distance2 == 40.0)||(distance2 == 50.0)||(distance2 == 60.0)||(distance2 == 70.0)||(distance2 == 80.0)||(distance2 == 90.0)||(distance2 == 100.0))  && bannerGoShowed==false)
        {
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
    
    STARTED = false;
    menuShowed = FALSE;
    isKmh = true;
    bannerGoShowed = false;
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
    }
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
    
    
    if(!menuShowed)
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
    }
    
}

- (IBAction)startByking:(id)sender {
        if(!STARTED)
        {
            [UIView animateWithDuration:0.5 animations:^{
                CGAffineTransform trasform = CGAffineTransformMakeRotation(DEGREES_TO_RADIANS(-90));
                startBtn.transform = trasform;
            }];
            
            STARTED = true;
            myMap.showsUserLocation=true;
            oldPos = nil;
            distance = 0.0;
            [self startLocation];
            timeTimer = [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(timer) userInfo:nil repeats:YES];
            
        }
    else
    {
        [UIView animateWithDuration:0.5 animations:^{
            CGAffineTransform trasform = CGAffineTransformMakeRotation(DEGREES_TO_RADIANS(0));
            startBtn.transform = trasform;
        }];
        [locationManager stopUpdatingLocation];
        [bannerKM setHidden:true];
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
    }
}


@end
