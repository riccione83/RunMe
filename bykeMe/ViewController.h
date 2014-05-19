//
//  ViewController.h
//  bykeMe
//
//  Created by Riccardo Rizzo on 15/05/14.
//  Copyright (c) 2014 Riccardo Rizzo. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <iAd/iAd.h>
#import <MapKit/MapKit.h>
#include <math.h>

@interface ViewController : UIViewController <ADBannerViewDelegate,CLLocationManagerDelegate,MKMapViewDelegate>{
    BOOL STARTED;
    BOOL menuShowed;
    CLLocationManager *locationManager;
    CLLocation *pos;
    CLLocation *oldPos;
    bool regionCreated;
    NSTimer *timeTimer;
    NSTimer *bannerTimer;
    int iSec,iMin,iHr;
    float distance;
    BOOL isKmh;
    BOOL bannerGoShowed;
}
@property (strong, nonatomic) IBOutlet ADBannerView *banner;
@property (strong, nonatomic) IBOutlet MKMapView *myMap;
@property (strong, nonatomic) IBOutlet UIView *onOffView;
@property (strong, nonatomic) IBOutlet UIView *panelView;
@property (strong, nonatomic) IBOutlet UIButton *startBtn;
@property (strong, nonatomic) IBOutlet UIButton *btnShowPanel;
@property (strong, nonatomic) IBOutlet UIView *hint;
@property (strong, nonatomic) IBOutlet UILabel *lblTime;
@property (strong, nonatomic) IBOutlet UILabel *lblAltitude;
@property (strong, nonatomic) IBOutlet UILabel *lblDistance;
@property (strong, nonatomic) IBOutlet UILabel *lblSpeed;
@property (strong, nonatomic) IBOutlet UILabel *lblUnitSpeed;
@property (strong, nonatomic) IBOutlet UIView *bannerKM;
@property (strong, nonatomic) IBOutlet UILabel *labelKM;

- (IBAction)showOnOffPanel:(id)sender;
- (IBAction)closePanel:(id)sender;
- (IBAction)startByking:(id)sender;

-(void)startLocation;
-(void)timer;
-(void)hideBanner;

@end
