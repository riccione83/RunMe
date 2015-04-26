//
//  ViewController.m
//  bykeMe
//
//  Created by Riccardo Rizzo on 15/05/14.
//  Copyright (c) 2014 Riccardo Rizzo. All rights reserved.
//

//#define M_PI 3.14159265359

#define DEGREES_TO_RADIANS(angle)  (angle / 180.0 * M_PI)
#define IS_OS_8_OR_LATER ([[[UIDevice currentDevice] systemVersion] floatValue] >= 8.0)

#import "ViewController.h"

@interface ViewController ()
  
@end

@implementation ViewController

@synthesize musicPlayer;
@synthesize slideToStartLabel;
@synthesize slideToStart;
@synthesize banner;
@synthesize myMap;
@synthesize panelView;
@synthesize onOffView;
@synthesize startBtn;
@synthesize hint;
@synthesize lblAltitude,lblDistance,lblSpeed,lblTime,lblUnitSpeed;
@synthesize bannerKM,labelKM;
@synthesize statusLabel,gpsLabel;
@synthesize lblRitmoMedio;
@synthesize musicLabel;
@synthesize voiceSwitch,musicSwitch;
@synthesize playMusicButton;


BOOL UNLOCKED = NO;

-(UIImage *)prepareBackgroundImage {
    
    NSArray* posArray = [[NSArray alloc] initWithObjects:startPoint,endPoint, nil];
    MKCoordinateRegion region = [self regionForAnnotations:posArray];
    [myMap setRegion:region animated:NO];
    UIGraphicsBeginImageContext(myMap.frame.size);
    [myMap.layer renderInContext:UIGraphicsGetCurrentContext()];
    UIImage * image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return image;
}

- (IBAction)postOnFacebook:(id)sender {
    
 //   if(distance>100 || distance2>1.0)
  //  {
        UIImage *image = [self prepareBackgroundImage];
        
        if([SLComposeViewController isAvailableForServiceType:SLServiceTypeFacebook]) {
            NSString *temp;
        
            SLComposeViewController *controller = [SLComposeViewController composeViewControllerForServiceType:SLServiceTypeFacebook];
            
            if(distance<1000)
                temp = [NSString stringWithFormat:NSLocalizedString(@"RUNNING_MT", nil),distance];
            else
                temp = [NSString stringWithFormat:NSLocalizedString(@"RUNNING_KM", nil),distance2];
        
            [controller setInitialText:temp];
            //[controller add]
            [controller addImage:image];
            [self presentViewController:controller animated:YES completion:Nil];
        }
        else
        {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"SHARE_ON_FACEBOOK", nil) message:NSLocalizedString(@"NO_FACEBOOK_ACCOUNT", nil) delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
        
            [alert show];
        }
 /*   }
    else
    {
        UIAlertView *al = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"SHARE_ON_FACEBOOK",nil) message:NSLocalizedString(@"RUN_AT_LEAST_100",nil) delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [al show];
    }
  */
}

-(void) registerMediaPlayerNotification {
    NSNotificationCenter *notificationCenter = [NSNotificationCenter defaultCenter];
    
    [notificationCenter addObserver: self
                           selector: @selector (handle_NowPlayingItemChanged:)
                               name: MPMusicPlayerControllerNowPlayingItemDidChangeNotification
                             object: musicPlayer];
    
    [notificationCenter addObserver: self
                           selector: @selector (handle_PlaybackStateChanged:)
                               name: MPMusicPlayerControllerPlaybackStateDidChangeNotification
                             object: musicPlayer];
    
    [notificationCenter addObserver: self
                           selector: @selector (handle_VolumeChanged:)
                               name: MPMusicPlayerControllerVolumeDidChangeNotification
                             object: musicPlayer];
    
    
    [musicPlayer beginGeneratingPlaybackNotifications];
    
}

- (void) handle_NowPlayingItemChanged: (id) notification
{
    MPMediaItem *currentItem = [musicPlayer nowPlayingItem];
    NSString *title,*artist;
    
    NSString *titleString = [currentItem valueForProperty:MPMediaItemPropertyTitle];
    if (titleString) {
        title = [NSString stringWithFormat:@"Play: %@",titleString];
    } else {
        title = @"";
    }
    
    NSString *artistString = [currentItem valueForProperty:MPMediaItemPropertyArtist];
    if (artistString) {
        artist = [NSString stringWithFormat:@"Artist: %@",artistString];
    } else {
        artist = @"";
    }
    
    musicLabel.text = [NSString stringWithFormat:@"[%@] - %@",artist, title];
}

- (void) handle_PlaybackStateChanged: (id) notification
{
    MPMusicPlaybackState playbackState = [musicPlayer playbackState];
    
    if (playbackState == MPMusicPlaybackStatePaused) {
        [playMusicButton setTitle:@"Play" forState:UIControlStateNormal];
        
    } else if (playbackState == MPMusicPlaybackStatePlaying) {
        [playMusicButton setTitle:@"Pause" forState:UIControlStateNormal];
  
    } else if (playbackState == MPMusicPlaybackStateStopped) {
        
        [playMusicButton setTitle:@"Play" forState:UIControlStateNormal];
        [musicPlayer stop];
        
    }
    
}

- (void) mediaPicker: (MPMediaPickerController *) mediaPicker didPickMediaItems: (MPMediaItemCollection *) mediaItemCollection
{
    if (mediaItemCollection) {
        
        [musicPlayer setQueueWithItemCollection: mediaItemCollection];
        [musicPlayer play];
    }
    
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void) mediaPickerDidCancel: (MPMediaPickerController *) mediaPicker
{
    [self dismissViewControllerAnimated: YES completion:nil];
    [musicSwitch setOn:NO];
    isMusicON = NO;
}

- (void) handle_VolumeChanged: (id) notification
{
    //[volumeSlider setValue:[musicPlayer volume]];
}

-(IBAction)selectVoiceSwitch:(id)sender
{
    isVoiceON = (voiceSwitch.isOn);
    [self saveOptions];
}

-(IBAction)selectMusicSwitch:(id)sender
{
    if(musicSwitch.isOn) {
        
        MPMediaPickerController *mediaPicker = [[MPMediaPickerController alloc] initWithMediaTypes:MPMediaTypeAny];
    
        mediaPicker.delegate = self;
        mediaPicker.allowsPickingMultipleItems = YES;
        mediaPicker.prompt = NSLocalizedString(@"SELECT_SONG_TO_PLAY", nil);
    
        [self presentViewController:mediaPicker animated:YES completion:nil];
        
        [self saveOptions];
    }
    else
    {
        [musicPlayer stop];
    }
}

-(IBAction)playMusic:(id)sender {
    if([musicPlayer playbackState] == MPMusicPlaybackStatePlaying)
    {
        [musicPlayer pause];
    }
    else
    {
        if(([musicPlayer playbackState] == MPMusicPlaybackStatePaused) || ([musicPlayer playbackState]  == MPMusicPlaybackStateStopped))
        {
            [musicPlayer play];
            if(!isMusicON)
            {
                isMusicON = true;
                [musicSwitch setOn:YES];
                [self saveOptions];
            }
        }
    }

}

-(IBAction)nextSong:(id)sender {
    [musicPlayer skipToNextItem];
}

-(IBAction)prevSong:(id)sender {
   [musicPlayer skipToPreviousItem];
}

-(IBAction)selectOtherMode:(id)sender {
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
    
    MKCoordinateRegion reg = MKCoordinateRegionMake(pos.coordinate, MKCoordinateSpanMake(0.0001, 0.0001));
    
    if(!regionCreated) {
        [myMap setRegion:reg];
        regionCreated = true;
    }
    [self.locationManager startUpdatingLocation];
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
        [_btnUnits setTitle:NSLocalizedString(@"Units mph",nil) forState:UIControlStateNormal];
        m_testView.indicator = @"mph";
    }
    else
    {
        isKmh = YES;
        [_btnUnits setTitle:NSLocalizedString(@"Units Km/h",nil) forState:UIControlStateNormal];
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
    
        [myMap setCenterCoordinate:pos.coordinate];
        
        if(!prevpoint) {
            currPoint = pos;
            prevpoint = true;
        }
        else
        {
            prevPoint = pos;
            prevpoint = false; }
        
    [self updateLines];

    
        
    if(firstPoint==nil)
    {
        firstPoint = pos;
        [self setInitialPoint:firstPoint];
    }
    else
        lastPoint = pos;
        
        
    if(pos.verticalAccuracy<=100.0)
    {
        if(![statusLabel.text isEqualToString:NSLocalizedString(@"Running...",nil)])
        {
            statusLabel.text =NSLocalizedString(@"Running...",nil);
            
        }
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
        
        //NSLog(@"Accuracy: %f",pos.verticalAccuracy);
    
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
        
            /*if((distance2 > 1.0) && (distance2<1.1) && bannerGoShowed==false)
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
            }*/
        }
    
    
        if(isKmh) {
            speed = pos.speed * kph;
        }
        else {
            speed = pos.speed * mph;
        }
    
        if(speed<0) speed=0.0;
    
        lastSpeed = speed;
        
        lblAltitude.text = [NSString stringWithFormat:@"%.01f mt",pos.altitude];
        lblSpeed.text = [NSString stringWithFormat:@"%.01f", speed];
    
        oldPos = pos;
    
        
        if(iseAltitude==0) {
            iseAltitude = pos.altitude;
        }
        else {
                if(pos.altitude>iseAltitude)
                    iseAltitude = pos.altitude;
        }
    
        if(distance<1000)
            iseDistance = distance;
        else
            iseDistance = distance2;

        
        if(speed<=50)
            m_testView.maxValue = 50;
        else if(speed>50 && speed<=100)
            m_testView.maxValue = 100;
        else if(speed>100 && speed<=200)
            m_testView.maxValue = 200;
        else if(speed>200)
            m_testView.maxValue = 400;
        
        if(iseMaxSpeed==0)
            iseMaxSpeed = speed;
        else {
            if(speed>iseMaxSpeed) {
                iseMaxSpeed = speed;
        }
        
        m_testView.percent = speed;
        [m_testView setNeedsDisplay];
            
        //Calcolo del ritmo medio
        lblRitmoMedio.text = [self calcRitmoMedio];
    }
    
    
    num_of_point++;
    tempAvgSpeed += speed;
    iseAvgSpeed = (tempAvgSpeed/num_of_point);
        
    }
    else
    {
        gpsLabel.textColor = [UIColor redColor];
        statusLabel.text =NSLocalizedString(@"Waiting for a better gps signal...",nil);
        [self speechText:NSLocalizedString(@"Waiting for a better gps signal...", nil)];
        [timeTimer invalidate];
        timeTimer = nil;
        if(self.backgroundTask != UIBackgroundTaskInvalid) {
            [[UIApplication sharedApplication] endBackgroundTask:self.backgroundTask];
            self.backgroundTask = UIBackgroundTaskInvalid;
        }

    }
  }
    
}

-(void)loadOptions {
    FileSupport *myFile = [[FileSupport alloc] init];
    
    NSMutableArray *testArray = [myFile readDataFromFile:@"options.plist"];
    
    if(testArray!=nil)
    {
        options  = [myFile readDataFromFile:@"options.plist"];
        if([options count]>=1)
        {
            isKmh = [[options objectAtIndex:0] boolValue];
            if(isKmh) {
            m_testView.indicator = @"Km/h";
            [_btnUnits setTitle:NSLocalizedString(@"Units Km/h",nil) forState:UIControlStateNormal];
        }
        else {
            m_testView.indicator = @"mph";
            [_btnUnits setTitle:NSLocalizedString(@"Units mph",nil) forState:UIControlStateNormal];
        }
                        }
        
        if([options count]>1) {
            if([[options objectAtIndex:1] boolValue]) {
                [voiceSwitch setOn:YES];
                isVoiceON = YES;
            }
            else
            {
                [voiceSwitch setOn:NO];
                isVoiceON = NO;
            }
            if([[options objectAtIndex:2] boolValue]) {
                if([musicLabel.text length] > 0)
                    [musicSwitch setOn:YES];
                else
                    [musicSwitch setOn:NO];
            }
            else
            {
                [musicSwitch setOn:NO];
                isMusicON = NO;
            }
        }
        else
        {
            [voiceSwitch setOn:YES];
            isVoiceON = YES;
            [musicSwitch setOn:NO];
            isMusicON = NO;
        }

    }
    else
    {
        [voiceSwitch setOn:YES];
        isVoiceON = YES;
        [musicSwitch setOn:NO];
        isMusicON = NO;
    }
    
}

-(void)saveOptions {
    
    if(options!=nil && [options count]== 1)
    {
        [options addObject:[NSNumber numberWithBool:voiceSwitch.isOn]];
        [options addObject:[NSNumber numberWithBool:musicSwitch.isOn]];
    }
    else if([options count] == 3) {
        [options replaceObjectAtIndex:1 withObject:[NSNumber numberWithBool:voiceSwitch.isOn]];
        [options replaceObjectAtIndex:2 withObject:[NSNumber numberWithBool:musicSwitch.isOn]];
    }
    
    FileSupport *myFile = [[FileSupport alloc] init];
    [myFile writeDataToFile:options fileToWrite:@"options.plist"];
}


-(void)locationManager:(CLLocationManager *)manager didChangeAuthorizationStatus:(CLAuthorizationStatus)status {
    if(IS_OS_8_OR_LATER) {
    [self.locationManager requestAlwaysAuthorization];
    }
}

-(IBAction)LockIt {
    slideToStart.hidden = NO;
    slideToStartLabel.hidden = NO;
    slideToStartLabel.alpha = 1.0;
    UNLOCKED = NO;
    slideToStart.value = 0.0;
}

-(IBAction)fadeLabel {
    slideToStartLabel.alpha = 1.0 - slideToStart.value;
}

-(IBAction)UnLockIt {

    
    if (!UNLOCKED) {
        if (slideToStart.value ==1.0) {  // if user slide far enough, stop the operation
            // Put here what happens when it is unlocked
        
            if(RUNNING)
                slideToStartLabel.text = NSLocalizedString(@"Slide to start", nil);
            else
                slideToStartLabel.text = NSLocalizedString(@"Slide to stop", nil);
            UNLOCKED = YES;
            [self closePanel:nil];
            [self startByking:nil];
        } else {
            // user did not slide far enough, so return back to 0 position
            [UIView beginAnimations: @"SlideCanceled" context: nil];
            [UIView setAnimationDelegate: self];
            [UIView setAnimationDuration: 0.35];
            // use CurveEaseOut to create "spring" effect
            [UIView setAnimationCurve: UIViewAnimationCurveEaseOut];	
            slideToStart.value = 0.0;
            slideToStartLabel.alpha = 1.0;
            [UIView commitAnimations];
            
            
        }
    }
}

-(void)startBackgroundAnimation {
    NSString *filePath = [[NSBundle mainBundle] pathForResource:@"sport" ofType:@"gif"];
    NSData *gif = [NSData dataWithContentsOfFile:filePath];
    
    [backgroundVideoView loadData:gif MIMEType:@"image/gif" textEncodingName:nil baseURL:nil];
    backgroundVideoView.userInteractionEnabled = NO;
}

-(void)initLocalizationUI {
    [mySessionsLabel setTitle:NSLocalizedString(@"My Sessions", nil) forState:UIControlStateNormal];
    [shareLabel setTitle:NSLocalizedString(@"Share", nil) forState:UIControlStateNormal];
    [unitsLabel setTitle:NSLocalizedString(@"Units Km/h", nil) forState:UIControlStateNormal];
    lblVoice.text = NSLocalizedString(@"Voice", nil);
    lblMusic.text = NSLocalizedString(@"Music", nil);
    slideToStartLabel.text = NSLocalizedString(@"Slide to start", nil);
    lblTimeB.text = NSLocalizedString(@"Time", nil);
    lblDistanceB.text = NSLocalizedString(@"Distance", nil);
    lblAltitudeB.text = NSLocalizedString(@"Altitude", nil);
    lblTapHere.text = NSLocalizedString(@"Tap here for menù", nil);
}


- (void)viewDidLoad
{
    [super viewDidLoad];
    [self initLocalizationUI];
    
    [self startBackgroundAnimation];
    
    
    UIImage *stetchLeftTrack= [[UIImage imageNamed:@"Nothing.png"]
                               stretchableImageWithLeftCapWidth:30.0 topCapHeight:0.0];
    UIImage *stetchRightTrack= [[UIImage imageNamed:@"Nothing.png"]
                                stretchableImageWithLeftCapWidth:30.0 topCapHeight:0.0];
    [slideToStart setThumbImage: [UIImage imageNamed:@"SlideToStop.png"] forState:UIControlStateNormal];
    [slideToStart setMinimumTrackImage:stetchLeftTrack forState:UIControlStateNormal];
    [slideToStart setMaximumTrackImage:stetchRightTrack forState:UIControlStateNormal];

    
    
    myMap.delegate = self;

    self.locationManager = [[CLLocationManager alloc] init];
    self.locationManager.delegate = self;
    self.locationManager.distanceFilter = kCLDistanceFilterNone; // whenever we move
    self.locationManager.desiredAccuracy = kCLLocationAccuracyBestForNavigation; // 100
    
    if(IS_OS_8_OR_LATER) {
        [self.locationManager requestAlwaysAuthorization];
    }
    [self.locationManager startUpdatingLocation];
    
    bannerIsVisible = TRUE;
    
    WildcardGestureRecognizer * tapInterceptor = [[WildcardGestureRecognizer alloc] init];
    tapInterceptor.touchesBeganCallback = ^(NSSet * touches, UIEvent * event) {
        [self closePanel:nil];
    };
    [myMap addGestureRecognizer:tapInterceptor];
    
    
    m_testView = [[BeizerView alloc] initWithFrame:self.viewTest.bounds];
    m_testView.percent = 0.0;
    m_testView.lineWith = 10;
    m_testView.maxValue = 200;
    [self.viewTest addSubview:m_testView];
    
     MKCoordinateRegion reg = MKCoordinateRegionMake(myMap.userLocation.coordinate, MKCoordinateSpanMake(0.0001, 0.0001));
     
     if(!regionCreated) {
     [myMap setRegion:reg];
     regionCreated = true;
     }
    
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
    
    [self startLocation];
    
    banner.delegate = self;
    [self hideBannerAD];
    [[UIApplication sharedApplication] setIdleTimerDisabled:YES];
    
    speechCore = [[TextToSpeechSupport alloc] init];
    speechCore.delegate = (id)self;
    
    musicPlayer = [MPMusicPlayerController iPodMusicPlayer];
    [self registerMediaPlayerNotification];
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
    [self LockIt];
    [self startBackgroundAnimation];
}

- (IBAction)closePanel:(id)sender {
    
    [backgroundVideoView stopLoading];
    backgroundVideoView = nil;
    
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


-(NSString *)calcRitmoMedio {
    NSString *temp = @"";
    float secondi,metri,tempo,velocitaKMH;
    secondi = iHr * 60 * 60 + iMin * 60 + iSec;
    metri = distance;
    velocitaKMH = metri * 3600 / secondi;
    tempo = metri / secondi;
    tempo = 1000 / tempo;
    secondi = floor(((tempo/60)-floor(tempo/60))*60);
    tempo = floor(tempo/60);
    if(secondi==60) {
        secondi = 0;
        tempo = tempo + 1;
    }
    temp = [NSString stringWithFormat:@"%.0f:%.0f",tempo,secondi];
    return temp;
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
}

-(void)resetData {
    
    [self.locationManager stopUpdatingLocation];
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
    lblRitmoMedio.text = @"0:0";
    lastSpeed = 0.0f;
    num_of_point = 0;
    iseAvgSpeed = 0;
    iseDistance = 0;
    iseMaxSpeed = 0;
    iseAltitude = 0;
    tempAvgSpeed = 0;
    distance2 =0;
    statusLabel.text = NSLocalizedString(@"Stopped",nil);
    RUNNING = false;
    m_testView.maxValue = 50;
    m_testView.percent = 0.0;
    [m_testView setNeedsDisplay];
    
    NSArray *pointArray = [myMap overlays];
    [myMap removeOverlays:pointArray];
    
    NSArray *pointAnn = [myMap annotations];
    [myMap removeAnnotations:pointAnn];
}

-(void)speechThisSessionData {
      
    NSString *sessionToSpeech = @"";
    sessionToSpeech  = NSLocalizedString(@"SPEECH_SESSION_DATA",nil);
    
    NSString *unit = @"";
    if(distance2 == 0) unit = NSLocalizedString(@"meters",nil);
    else unit = NSLocalizedString(@"Km",nil);
    
    sessionToSpeech = [NSString stringWithString:[NSString stringWithFormat:NSLocalizedString(@"SPEECH_DISTANCE",nil),sessionToSpeech,(long)iseDistance, unit]];
    
    sessionToSpeech = [NSString stringWithString:[NSString stringWithFormat:NSLocalizedString(@"SPEECH_AVG_SPEED",nil),sessionToSpeech, [NSNumber numberWithFloat:iseAvgSpeed]]];
    
    sessionToSpeech = [NSString stringWithString:[NSString stringWithFormat:NSLocalizedString(@"SPEECH_RYTHM",nil),sessionToSpeech,lblRitmoMedio.text]];
    
    sessionToSpeech = [NSString stringWithString:[NSString stringWithFormat:NSLocalizedString(@"SPEECH_SPEED",nil),sessionToSpeech,lastSpeed]];
    
    [self speechText:sessionToSpeech];
}

-(void)saveSession {
    double currDistance;
    NSMutableArray *sessionData = [NSMutableArray new];
    SessionData *sessionToSave = [[SessionData alloc] init];
    
    sessionImage = [self prepareBackgroundImage];
    if(distance2==0)
        currDistance = (float)iseDistance / (float)1000;
    else
        currDistance = distance2;
    
    [sessionData addObject:[NSNumber numberWithInteger:iseAltitude]];
    [sessionData addObject:[NSNumber numberWithInteger:iseAvgSpeed]];
    [sessionData addObject:[NSNumber numberWithFloat:currDistance]];
    [sessionData addObject:[NSNumber numberWithInteger:iseMaxSpeed]];
    [sessionData addObject:lblRitmoMedio.text];
    [sessionData addObject:sessionImage];
    
    if(![sessionToSave saveNewSession:sessionData])
        NSLog(@"Dati non salvati");
}

-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    
    if(alertView.tag!=100) {
        if(buttonIndex==2)
        {
            [self resetData];
            [timerSpeechSession invalidate];
            timerSpeechSession = nil;
            //[self speechText:@"Session cancelled."];
            [self speechText:NSLocalizedString(@"SPEECH_SESSION_CANCELLED",nil)];
        }
        if(buttonIndex==1)
        {
           // [speechCore speech:@"Session saved"];
            [timerSpeechSession invalidate];
            timerSpeechSession = nil;
            [self saveSession];
            [self setFinalPoint];
            [self.locationManager stopUpdatingLocation];
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
            
            statusLabel.text = NSLocalizedString(@"Stopped",nil);
            RUNNING = false;
            m_testView.maxValue = 50;
            m_testView.percent = 0.0;
            [m_testView setNeedsDisplay];
            NSArray* posArray = [[NSArray alloc] initWithObjects:startPoint,endPoint, nil];
            MKCoordinateRegion region = [self regionForAnnotations:posArray];
            [myMap setRegion:region animated:YES];
        }
    }
    else
    {
        if (buttonIndex == 1) {
            // Send the user to the Settings for this app
            NSURL *settingsURL = [NSURL URLWithString:UIApplicationOpenSettingsURLString];
            [[UIApplication sharedApplication] openURL:settingsURL];
        }

    }
}

-(void) setInitialPoint:(CLLocation*)start_loc {
    MKPointAnnotation *point = [[MKPointAnnotation alloc]init];
    point.coordinate = start_loc.coordinate;
    point.title = NSLocalizedString(@"Start",nil);
    firstPoint = start_loc;
    startPoint = point;
    [myMap addAnnotation:point];
    [myMap selectAnnotation:point animated:TRUE];
}

-(void) setFinalPoint{
    MKPointAnnotation *point = [[MKPointAnnotation alloc]init];
    point.coordinate = lastPoint.coordinate;
    point.title = NSLocalizedString(@"End",nil);;
    endPoint = point;
    [myMap addAnnotation:point];

    [myMap selectAnnotation:point animated:TRUE];
}

-(void)speechText:(NSString *)TTS {
    
    if(isMusicON)
        [musicPlayer pause];
    
    if(isVoiceON) {
        [speechCore speech:TTS];
    }
}

- (void)restartMusic {
      if(isMusicON)
          [musicPlayer play];
}

- (IBAction)startByking:(id)sender {
        if(!STARTED)
        {
            //[self speechText:@"Session started"];
            [self speechText:NSLocalizedString(@"SPEECH_START_SESSION",nil)];
            if(SESSION_ACTIVE)
                [self resetData];
            statusLabel.text = NSLocalizedString(@"Running...",nil);
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
            
            timerSpeechSession =  [NSTimer scheduledTimerWithTimeInterval:30 target:self selector:@selector(speechThisSessionData) userInfo:nil repeats:YES];
            if(gpsLabel.textColor == [UIColor redColor])
                [self speechText:@"Waiting for a better gps signal..."];
            
        }
    else
    {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"New session",nil) message:NSLocalizedString(@"NEW_SESSION_QUESTION",nil) delegate:self cancelButtonTitle:NSLocalizedString(@"Cancel",nil) otherButtonTitles:NSLocalizedString(@"Save session",nil),NSLocalizedString(@"Cancel session",nil), nil];
            [alert show];
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
