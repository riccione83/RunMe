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
#import "TextToSpeechSupport.h"
#import <MediaPlayer/MediaPlayer.h>

@interface ViewController : UIViewController <ADBannerViewDelegate,CLLocationManagerDelegate,MKMapViewDelegate,UIAlertViewDelegate,MPMediaPickerControllerDelegate>{
    
    BOOL hintViewHasShowed;
    CLLocation *pos;
    CLLocation *oldPos;
    CLLocation *firstPoint;
    CLLocation *lastPoint;
    CLLocationManager *locationManager;

    MKPointAnnotation *startPoint;
    MKPointAnnotation *endPoint;
    
    bool regionCreated;
    
    NSTimer *timeTimer;
    NSTimer *hideMenuTimer;
    NSTimer *timerSpeechSession;
    
    int iSec,iMin,iHr;
    int imageSaveType;
    float distanceInMeters;
    float distanceInKM;
    float ritmoMedio;
    float lastSpeed;
    NSUInteger num_of_point;
    
    BOOL isKmh;
    BOOL RUNNING;
    
    NSMutableArray *options;
    NSMutableArray *savedPoint;
    
    NSString *iseDate;
    NSInteger iseDistance;
    NSInteger iseMaxSpeed;
    NSInteger iseAvgSpeed;
    NSInteger tempAvgSpeed;
    NSInteger iseAltitude;

    UIImage *sessionImage;
    BOOL isVoiceON;
    BOOL isMusicON;
    
    //Speed view
    BeizerView *viewSpeed;
    TextToSpeechSupport *speechCore;
    
    
    MPMusicPlayerController *musicPlayer;
    UIBackgroundTaskIdentifier backgroundTask;
    
    IBOutlet UISlider *slideToStart;
    IBOutlet UILabel *slideToStartLabel;
    IBOutlet UISwitch *voiceSwitch;
    IBOutlet UISwitch *musicSwitch;
    IBOutlet UIWebView *backgroundVideoView;
    IBOutlet UILabel *musicLabel;
    IBOutlet UIButton *playMusicButton;
    IBOutlet UIButton *mySessionsLabel;
    IBOutlet UIButton *shareLabel;
    IBOutlet UIButton *unitsLabel;
    IBOutlet UILabel *lblVoice;
    IBOutlet UILabel *lblMusic;
    IBOutlet UILabel *lblTimeB;
    IBOutlet UILabel *lblDistanceB;
    IBOutlet UILabel *lblAltitudeB;
    IBOutlet UILabel *lblTapHere;
    IBOutlet MKMapView *myMap;
    IBOutlet UIView *menuView;
    IBOutlet UIView *panelView;
    IBOutlet UIButton *startBtn;
    IBOutlet UIButton *btnShowPanel;
    IBOutlet UIView *hintView;
    IBOutlet UILabel *lblTime;
    IBOutlet UILabel *lblAltitude;
    IBOutlet UILabel *lblDistance;
    IBOutlet UILabel *lblSpeed;
    IBOutlet UILabel *lblUnitSpeed;
    IBOutlet UILabel *lblRitmoMedio;
    IBOutlet UILabel *labelKM;
    IBOutlet UILabel *gpsLabel;
    IBOutlet UILabel *statusLabel;
    IBOutlet UIButton *btnUnits;
    IBOutlet UIImageView *onOffImage;
    IBOutlet ADBannerView *banner;
    IBOutlet UIView *viewTest;
}

- (IBAction)showMenuPanel:(id)sender;
- (IBAction)hideMenuPanel:(id)sender;
- (IBAction)startByking:(id)sender;
- (IBAction)UnLockIt;
- (IBAction)fadeLabel;
- (IBAction)LockIt;

-(void)restartMusic;
-(void)startLocation;
-(void)timer;

@end
