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
#include "FileSupport.h"
#include "BeizerView.h"
#include <Social/Social.h>
#include "WildcardGestureRecognizer.h"
#include "Appirater.h"
#include "SessionData.h"

@interface ViewController : UIViewController <ADBannerViewDelegate,CLLocationManagerDelegate,MKMapViewDelegate,UIAlertViewDelegate>{
    BOOL STARTED;
    BOOL menuShowed;
    CLLocation *pos;
    CLLocation *oldPos;
    CLLocation *firstPoint;
    CLLocation *lastPoint;
    CLLocation *currPoint,*prevPoint;
    bool prevpoint;
    MKPointAnnotation *startPoint;
    MKPointAnnotation *endPoint;
    bool regionCreated;
    NSTimer *timeTimer;
    NSTimer *bannerTimer;
    NSTimer *hideMenuTimer;
    int iSec,iMin,iHr;
    float distance;
    float distance2;
    float ritmoMedio;
    NSUInteger num_of_point;
    BOOL isKmh;
    BOOL bannerGoShowed;
    BOOL bannerIsVisible;
    BOOL RUNNING;
    BOOL SESSION_ACTIVE;
    
    NSMutableArray *options;
    
    FileSupport* iCFile;
    NSMutableArray *iCloudArray;
    NSMutableArray *sessDate;
    NSString *iseDate;
    NSMutableArray *sessDistance;
    NSInteger iseDistance;
    NSMutableArray *sessMaxSpeed;
    NSInteger iseMaxSpeed;
    NSMutableArray *sessAvgSpeed;
    NSInteger iseAvgSpeed;
    NSInteger tempAvgSpeed;
    NSMutableArray *sessAltitude;
    NSInteger iseAltitude;
    NSMutableArray *savedPoint;
    UIImage *sessionImage;
    
    
    //test
    BeizerView *m_testView;
    NSTimer *m_timer;
    
    IBOutlet UISlider *slideToStart;
    IBOutlet UILabel *slideToStartLabel;
    IBOutlet UISwitch *runningSwitch;
    IBOutlet UISwitch *bikingSwitch;
    IBOutlet UISwitch *otherSwitch;
    
    IBOutlet UIWebView *backgroundVideoView;
    
}

@property (strong, nonatomic) IBOutlet UISwitch *runningSwitch;
@property (strong, nonatomic) IBOutlet UISwitch *bikingSwitch;
@property (strong, nonatomic) IBOutlet UISwitch *otherSwitch;
@property (strong, nonatomic) IBOutlet UILabel *slideToStartLabel;
@property (strong, nonatomic) IBOutlet UISlider *slideToStart;
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
@property (strong, nonatomic) IBOutlet UILabel *lblRitmoMedio;
@property (strong, nonatomic) IBOutlet UIView *bannerKM;
@property (strong, nonatomic) IBOutlet UILabel *labelKM;
@property (strong, nonatomic) IBOutlet UILabel *gpsLabel;
@property (strong, nonatomic) IBOutlet UILabel *statusLabel;
@property (weak, nonatomic) IBOutlet UIButton *btnUnits;
@property (strong, nonatomic) IBOutlet UIImageView *onOffImage;
@property(nonatomic, retain) CLLocationManager *locationManager;
@property (weak, nonatomic) IBOutlet UIView *viewTest;
@property (nonatomic) UIBackgroundTaskIdentifier backgroundTask;

//@property (strong) FileSupport *myFile;

- (IBAction)showOnOffPanel:(id)sender;
- (IBAction)closePanel:(id)sender;
- (IBAction)startByking:(id)sender;
- (IBAction)UnLockIt;
- (IBAction)fadeLabel;
- (IBAction)LockIt;


-(void)startLocation;
-(void)timer;
-(void)hideBanner;

@end
