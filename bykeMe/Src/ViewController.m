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
#define TIME_TO_SPEECH_SESSION  30
#define SAVE_FOR_FACEBOOK   1
#define SAVE_FOR_FILE       2

#import "ViewController.h"

@interface ViewController ()

@end



@implementation ViewController

BOOL UNLOCKED = NO;

/*************************
  ATTENDE CHE LA MAPPA SI SIA AGGIORNATA CON LO ZOOM A 2 PUNTI
  AL COMPLETAMENTO CONTROLLA CHI HA CHIAMATO IL SAVATAGGIO DELL'IMMAGINE
  SE E' STATO RICHIESTO PER UNA SHARE SU FACEBOOK CHIAMA LA  FUNZIONE APPOSITA
  ALTRIMENTI SALVA SU FILE
 **************************/
-(void) mapView:(MKMapView *)mapView regionDidChangeAnimated:(BOOL)animated {
    
    if(imageSaveType > 0) {
        UIGraphicsBeginImageContext(myMap.frame.size);
        [myMap.layer renderInContext:UIGraphicsGetCurrentContext()];
        UIImage * image = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
    
        if(imageSaveType == SAVE_FOR_FACEBOOK) {
            [self postImageOnFacebook:image];
        }
        else if (imageSaveType == SAVE_FOR_FILE) {
            [self saveSessionWithImage:image];
        }
        imageSaveType = 0;
    }
}


/**********************
 QUESTA FUNZIONE VIENE RICHIAMATA DAL CALLBACK DELLA MAPPA regionDidChangeAnimated
 PRENDE  L'IMMAGINE PRECEDENTEMENTE CREATA E LA PRAPERA PER LA CONDIVIZIONE SU FACEBOOK
 ***********************/
-(void)postImageOnFacebook:(UIImage*)image_src {
    
    UIImage *image = image_src;
    
    if([SLComposeViewController isAvailableForServiceType:SLServiceTypeFacebook]) {
        NSString *temp;
        
        SLComposeViewController *controller = [SLComposeViewController composeViewControllerForServiceType:SLServiceTypeFacebook];
        
        if(distanceInMeters<1000)
            temp = [NSString stringWithFormat:NSLocalizedString(@"RUNNING_MT", nil),distanceInMeters];
        else
            temp = [NSString stringWithFormat:NSLocalizedString(@"RUNNING_KM", nil),distanceInKM];
        
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

}

/*********************************
 PREPARA LA MAPPA FACENDO LO ZOOM TRA DUE PUNTI E SETTANDO LA REGIONE
 AL TERMINE VERRA' RICHIAMATO IL MEDOTO DELEGATE regionDidChangeAnimated
 *********************************/
-(void) prepareBackgroundImage {
    CLLocationCoordinate2D topLeftCoord;
    topLeftCoord.latitude = -90;
    topLeftCoord.longitude = 180;
    
    CLLocationCoordinate2D bottomRightCoord;
    bottomRightCoord.latitude = 90;
    bottomRightCoord.longitude = -180;
   
    if([myMap.annotations count]>=2) {
    
    for(MKPointAnnotation *annotation in myMap.annotations)
    {
        topLeftCoord.longitude = fmin(topLeftCoord.longitude, annotation.coordinate.longitude);
        topLeftCoord.latitude = fmax(topLeftCoord.latitude, annotation.coordinate.latitude);
        
        bottomRightCoord.longitude = fmax(bottomRightCoord.longitude, annotation.coordinate.longitude);
        bottomRightCoord.latitude = fmin(bottomRightCoord.latitude, annotation.coordinate.latitude);
    }
    
    MKCoordinateRegion region;
    region.center.latitude = topLeftCoord.latitude - (topLeftCoord.latitude - bottomRightCoord.latitude) * 0.5;
    region.center.longitude = topLeftCoord.longitude + (bottomRightCoord.longitude - topLeftCoord.longitude) * 0.5;
    region.span.latitudeDelta = fabs(topLeftCoord.latitude - bottomRightCoord.latitude) * 1.1; // Add a little extra space on the sides
    region.span.longitudeDelta = fabs(bottomRightCoord.longitude - topLeftCoord.longitude) * 1.1; // Add a little extra space on the sides
    
    region = [myMap regionThatFits:region];
    [myMap setRegion:region animated:NO];
    }
}


/************************
 L'UTENTE HA SELEZIONATO IL PULSANTE CONDIVIDI
 *************************/
- (IBAction)postOnFacebook:(id)sender {
    
    imageSaveType = SAVE_FOR_FACEBOOK;
    [self prepareBackgroundImage];
}

/*************************
 REGISTRAZIONE DELLE NOTIFICHE DEL MEDIA PLAYER
 **************************/
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

/**************************
 METODO RICHIAMATO QUANDO VIENE ESEGUITA UN'ALTRA CANZONE 
 **************************/
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

/**************************
 METODO RICHIAMATO QUANDO VIENE PREMUTO IL PULSANTE PLAY/PAUSE
 **************************/
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

/**************************
 QUANDO VENGONO SELEZIONATE DELLE MUSICHE E VIENE DISMESSO IL CONTROLLER
 **************************/
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

/**************************
 RICHIAMATA QUANDO VIENE SELEZIONATO IL PULSANTE "VOCE" DALLA UI
 DECIDE SE FAR SENTIRE LA VOCE E SALVA I DATI NELLE OPZIONI
 **************************/
-(IBAction)selectVoiceSwitch:(id)sender
{
    isVoiceON = (voiceSwitch.isOn);
    [self saveOptions];
}

/**************************
 RICHIAMATA QUANDO VIENE SELEZIONATO IL PULSANTE "MUSICA" DALLA UI
 SE VIENE ATTIVATO CREA IL CONTROLLER PER SELEZIONARE LA MUSICA E SALVA I DATI 
 NELLE OPZIONI, ALTRIMENTI FERMA LA RIPRODUZIONE
 **************************/
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

/**************************
 SE VIENE PREMUTO IL PULSANTE "PLAY" DALLA UI
 SE NON E' AVVIATA, AVVIA LA RIPRODUZIONE,
 ALTRIMENTI METTE IN PAUSA
 **************************/
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

/**************************
 PULSANTE >> PER PROSSIMA CANZONE
  **************************/
-(IBAction)nextSong:(id)sender {
    [musicPlayer skipToNextItem];
}

/***************************
 PULSANTE << PER PRECEDENTE CANZONE
  ***************************/
-(IBAction)prevSong:(id)sender {
   [musicPlayer skipToPreviousItem];
}

 /**************************
  SE VI E' LA POSSIBILITA' VISUALIZZA IL BANNER PUBBLICITARIO
   **************************/
-(void) showBannerAd:(BOOL)Visible {
    if(Visible)
    {
        [UIView beginAnimations:@"animateAdBannerOff" context:NULL];
        banner.frame = CGRectOffset(banner.frame, 0, -banner.frame.size.height);
        myMap.frame = CGRectMake(myMap.frame.origin.x, myMap.frame.origin.y, myMap.frame.size.width, myMap.frame.size.height - banner.frame.size.height);
        viewSpeed.frame = CGRectOffset(viewSpeed.frame, 0, -banner.frame.size.height);
        [UIView commitAnimations];
    }
    else
    {
        [UIView beginAnimations:@"animateAdBannerOff" context:NULL];
        banner.frame = CGRectOffset(banner.frame, 0, +banner.frame.size.height);
        myMap.frame = CGRectMake(myMap.frame.origin.x, myMap.frame.origin.y, myMap.frame.size.width, myMap.frame.size.height + banner.frame.size.height);
        viewSpeed.frame = CGRectOffset(viewSpeed.frame, 0, +banner.frame.size.height);
        [UIView commitAnimations];
    }
}

-(void)bannerViewDidLoadAd:(ADBannerView *)banner{
    [self showBannerAd:YES];
   }

-(void)bannerView:(ADBannerView *)banner didFailToReceiveAdWithError:(NSError *)error {
    [self showBannerAd:NO];
  }


/***************************
 AVVIA LA LOCALIZZAZIONE ED EFFETTUA UNO ZOOM
 ***************************/
-(void)startLocation {

    [locationManager startUpdatingLocation];
}

/***************************
 SE VIENE SELEZIONATO DALLA UI IL CAMBIO DI UNITà DA MIGLIA A KM/H
 CAMBIA L'INTERFACCIA E SALVA I DATI NELLE OPZIONI 
 ***************************/
- (IBAction)changeUnits:(id)sender {
    if(isKmh)
    {
        isKmh = NO;
        [btnUnits setTitle:NSLocalizedString(@"Units mph",nil) forState:UIControlStateNormal];
        viewSpeed.indicator = @"mph";
    }
    else
    {
        isKmh = YES;
        [btnUnits setTitle:NSLocalizedString(@"Units Km/h",nil) forState:UIControlStateNormal];
        viewSpeed.indicator = @"Km/h";
    }
    [viewSpeed setNeedsDisplay];
    
    if([options count]==0)
        [options addObject:[NSNumber numberWithBool:isKmh]];
    else
        [options replaceObjectAtIndex:0 withObject:[NSNumber numberWithBool:isKmh]];
    
    [self saveOptions];
}


/***************************
 IL CUORE DEL PROGRAMMA
 SETTA ALCUNE VARIABILI COME COSTANTI
 CENTRA LA VISUALIZZAZIONE DELLA POSIZIONE DELL'UTENTE
 CONTROLLA SE LA SESSIONE E' ATTIVA E CALCOLA TUTTI I PARAMETRI
 ***************************/
-(void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations{
    
    float const kph = 3.6;
    float const mph = 2.23693629;
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
        [self updateLines:pos];
        
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
                statusLabel.text =NSLocalizedString(@"Running...",nil);
            
            gpsLabel.textColor = [UIColor greenColor];
            
            if(timeTimer==nil)
            {
                timeTimer = [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(timer) userInfo:nil repeats:YES];
            
                backgroundTask = [[UIApplication sharedApplication] beginBackgroundTaskWithExpirationHandler:^{
                NSLog(@"Background handle called, Not running background task anymore");
                [[UIApplication sharedApplication] endBackgroundTask:backgroundTask];
                backgroundTask = UIBackgroundTaskInvalid;
            }];
        }
    
    
        if(oldPos!=nil)
        {
            CLLocationDistance meters = [pos distanceFromLocation:oldPos];
            distanceInMeters += meters;
        }
        oldPos = pos;
    
        if(distanceInMeters<1000)
        {
            unit = @"mt";
            lblDistance.text = [NSString stringWithFormat:@"%.01f %@",distanceInMeters,unit];
        }
        else
        {
            distanceInKM = distanceInMeters/1000;
            unit = @"km";
            lblDistance.text = [NSString stringWithFormat:@"%.02f %@",distanceInKM,unit];
        }
        
        if(distanceInMeters<1000)
                iseDistance = distanceInMeters;
        else
                iseDistance = distanceInKM;
            
    
        if(isKmh) {
            speed = pos.speed * kph;
        }
        else {
            speed = pos.speed * mph;
        }
    
        if(speed<0) speed=0.0;
    
        lastSpeed = speed;
        lblAltitude.text = [NSString stringWithFormat:@"%.0f mt",pos.altitude];
        lblSpeed.text = [NSString stringWithFormat:@"%.0f", speed];
        
        
        //DA VERIFICARE se il codice sotto è valido
        iseAltitude = pos.altitude;
        /*if(iseAltitude==0)
        {
            iseAltitude = pos.altitude;
        }
        else if(pos.altitude>iseAltitude)
        {
                    iseAltitude = pos.altitude;
        }
         */
            
        //Verifica la velocità attuale e cambia il massimo
        //per rappresentarlo in basso nella UI
        if(speed<=50)
            viewSpeed.maxValue = 50;
        else if(speed>50 && speed<=100)
            viewSpeed.maxValue = 100;
        else if(speed>100 && speed<=200)
            viewSpeed.maxValue = 200;
        else if(speed>200)
            viewSpeed.maxValue = 400;
        
        //Viene verificato se la velocità attuale è > della velocità massima
        //se è così viene aggiornata la variabile
        if(iseMaxSpeed==0)
            iseMaxSpeed = speed;
        else if(speed>iseMaxSpeed)
        {
                iseMaxSpeed = speed;
        }

        viewSpeed.percent = speed;
        [viewSpeed setNeedsDisplay];
            
        //Calcolo del ritmo medio
        lblRitmoMedio.text = [self calcRitmoMedio];
    
        //Calcolo della velocità media
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
        if(backgroundTask != UIBackgroundTaskInvalid) {
            [[UIApplication sharedApplication] endBackgroundTask:backgroundTask];
            backgroundTask = UIBackgroundTaskInvalid;
        }

    }
  }
    
}



/*******************
 VENGONO CARICATE LE OPZIONI DEL PROGRAMMA
 UNITA' DI MISURA
 SE LA VOCE E' ATTIVA
 SE LA MUSICA E' ATTIVA
 **********************/
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
            viewSpeed.indicator = @"Km/h";
            [btnUnits setTitle:NSLocalizedString(@"Units Km/h",nil) forState:UIControlStateNormal];
        }
        else {
            viewSpeed.indicator = @"mph";
            [btnUnits setTitle:NSLocalizedString(@"Units mph",nil) forState:UIControlStateNormal];
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

/*********
 SE SI UTILIZZA UNA VERSIONE DI IOS >= 8
 RICHIEDE L'AUTORIZZAZIONE ALLA LOCALIZZAZIONE
 */
-(void)locationManager:(CLLocationManager *)manager didChangeAuthorizationStatus:(CLAuthorizationStatus)status {
    if(IS_OS_8_OR_LATER) {
    [locationManager requestAlwaysAuthorization];
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
            [self hideMenuPanel:nil];
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

-(void)initLocalizationAndUI {
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
    
    
    /*******************
    UI CUSTOMIZATION
     ********************/
    UIImage *stetchLeftTrack= [[UIImage imageNamed:@"Nothing.png"]
                               stretchableImageWithLeftCapWidth:30.0 topCapHeight:0.0];
    UIImage *stetchRightTrack= [[UIImage imageNamed:@"Nothing.png"]
                                stretchableImageWithLeftCapWidth:30.0 topCapHeight:0.0];
    [slideToStart setThumbImage: [UIImage imageNamed:@"SlideToStop.png"] forState:UIControlStateNormal];
    [slideToStart setMinimumTrackImage:stetchLeftTrack forState:UIControlStateNormal];
    [slideToStart setMaximumTrackImage:stetchRightTrack forState:UIControlStateNormal];
}


- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self initLocalizationAndUI];
    [self startBackgroundAnimation];
    
    banner.delegate = self;
    myMap.delegate = self;
    myMap.showsUserLocation = YES;
    
    /**************************
     GPS INITIALIZATION
     *************************/
    locationManager = [[CLLocationManager alloc] init];
    locationManager.delegate = self;
    locationManager.distanceFilter = kCLDistanceFilterNone; // whenever we move
    locationManager.desiredAccuracy = kCLLocationAccuracyBestForNavigation; // 100
    if(IS_OS_8_OR_LATER) {
        [locationManager requestAlwaysAuthorization];
    }
    [locationManager startUpdatingLocation];

    /**************************
     tap gesture for close menu panel
     **************************/
    WildcardGestureRecognizer * tapInterceptor = [[WildcardGestureRecognizer alloc] init];
    tapInterceptor.touchesBeganCallback = ^(NSSet * touches, UIEvent * event) {
        [self hideMenuPanel:nil];
    };
    [myMap addGestureRecognizer:tapInterceptor];
    
    
    /**************************
     init view for speed controller
     ***************************/
    viewSpeed = [[BeizerView alloc] initWithFrame:viewTest.bounds];
    viewSpeed.percent = 0.0;
    viewSpeed.lineWith = 10;
    viewSpeed.maxValue = 200;
    [viewTest addSubview:viewSpeed];

 
    /****************************
     HIDE THE HINT PANEL
     ****************************/
    [UIView animateWithDuration:0.0 animations:^{
        CGAffineTransform trasform = CGAffineTransformMakeScale(0, 0);
        hintView.transform = trasform;
    }];
    
    /***************************
     INITIALIZE VARS
     ***************************/
    num_of_point = 0;
    iseAvgSpeed = 0;
    iseDistance = 0;
    iseMaxSpeed = 0;
    iseAltitude = 0;
    tempAvgSpeed = 0;
    hintViewHasShowed = FALSE;
    isKmh = true;
    RUNNING = false;
    savedPoint   = [[NSMutableArray alloc] init];
    options = [[NSMutableArray alloc] init];
    
    
    // Load options
    [self loadOptions];
    
    //Hide AD Banner
    [self showBannerAd:NO];
    
    //Turn off display light saver
    [[UIApplication sharedApplication] setIdleTimerDisabled:YES];
    
    //Initialize the speech engine
    speechCore = [[TextToSpeechSupport alloc] init];
    speechCore.delegate = (id)self;
    
    //Initialize che music engine
    musicPlayer = [MPMusicPlayerController iPodMusicPlayer];
    [self registerMediaPlayerNotification];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


/******************************
 VISUALIZZA IL PANNELLO DEL MENU
 ******************************/
- (IBAction)showMenuPanel:(id)sender {
    [UIView animateWithDuration:0.5 animations:^{
        CGAffineTransform trasform = CGAffineTransformMakeTranslation(0, 0);
        menuView.transform = trasform;
    }];
    hintViewHasShowed = true;
    [UIView animateWithDuration:0.5 animations:^{
        CGAffineTransform trasform = CGAffineTransformMakeScale(0, 0);
        hintView.transform = trasform;
    }];

    [hintView setHidden:true];
    [self LockIt];
    [self startBackgroundAnimation];
}

/******************************
 NASCONDE IL PANNELLO DEL MENU
 ******************************/
- (IBAction)hideMenuPanel:(id)sender {
    
    [backgroundVideoView stopLoading];
    backgroundVideoView = nil;
    
    [UIView animateWithDuration:0.5 animations:^{
        CGAffineTransform trasform = CGAffineTransformMakeTranslation(0, -400);
        menuView.transform = trasform;
    }];
    
    if(!hintViewHasShowed)
    {
        [hintView setHidden:false];
        [UIView animateWithDuration:0.5 animations:^{
            CGAffineTransform trasform = CGAffineTransformMakeScale(1, 1);
            hintView.transform = trasform;
        }];
        
        hideMenuTimer = [NSTimer scheduledTimerWithTimeInterval:5 target:self selector:@selector(hideBannerMenu) userInfo:nil repeats:NO];
    }
    
}

/******************************
 NASCONDE LA VIEW CON IL SUGGERIMENTO PER IL MENU
 ******************************/
-(void)hideBannerMenu{
            hintViewHasShowed = true;
            [UIView animateWithDuration:0.5 animations:^{
                CGAffineTransform trasform = CGAffineTransformMakeScale(0, 0);
                hintView.transform = trasform;
            } completion:^(BOOL finished) {
                [hintView setHidden:YES];
            }];
    [hideMenuTimer invalidate];
    hideMenuTimer=nil;
}

/******************************
 CALCOLA IL RITMO MEDIO
 OVVERO IL TEMPO MEDIO PER FARE 1 KM
 ******************************/
-(NSString *)calcRitmoMedio {
    NSString *temp = @"";
    float secondi,metri,tempo,velocitaKMH;
    secondi = iHr * 60 * 60 + iMin * 60 + iSec;
    metri = distanceInMeters;
    velocitaKMH = lastSpeed; //metri * 3600 / secondi;
    tempo = metri / secondi;
    tempo = 1000 / tempo;
    secondi = floor(((tempo/60)-floor(tempo/60))*60);
    tempo = floor(tempo/60);
    if(secondi==60) {
        secondi = 0;
        tempo = tempo + 1;
    }
    if(tempo<=99.0)
        temp = [NSString stringWithFormat:@"%.0f:%.0f",tempo,secondi];
    else
        temp = @"0:0";
    return temp;
}

/******************************
 TIMER RICHIAMATO OGNI SECONDO
 CALCOLA I TEMPI DELLE VARIABILI E AGGIORNA 
 LA LABEL TEMPO
 ******************************/
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

/******************************
 RESETTA TUTTE LE VARIABILI
 INIZIALIZZANDOLE
 ******************************/
-(void)resetData {
    
    [locationManager stopUpdatingLocation];
    myMap.showsUserLocation = false;
    [timeTimer invalidate];
    timeTimer = nil;
    if(backgroundTask != UIBackgroundTaskInvalid)
    {
        [[UIApplication sharedApplication] endBackgroundTask:backgroundTask];
        backgroundTask = UIBackgroundTaskInvalid;
    }
    oldPos = nil;
    firstPoint = nil;
    lastPoint = nil;
    startPoint = nil;
    endPoint = nil;
    savedPoint = [NSMutableArray new];
    distanceInMeters = 0.0;
    distanceInKM =0;
    lastSpeed = 0.0f;
    num_of_point = 0;
    iseAvgSpeed = 0;
    iseDistance = 0;
    iseMaxSpeed = 0;
    iseAltitude = 0;
    tempAvgSpeed = 0;
    iSec = 0; iMin=0; iHr = 0;
    lblTime.text = [NSString stringWithFormat:@"%02d:%02d:%02d",iHr,iMin,iSec];
    lblDistance.text = @"0.0";
    lblSpeed.text = @"0.0";
    lblAltitude.text = @"0.0";
    lblRitmoMedio.text = @"0:0";
    statusLabel.text = NSLocalizedString(@"Stopped",nil);
    RUNNING = false;
    viewSpeed.maxValue = 50;
    viewSpeed.percent = 0.0;
    [viewSpeed setNeedsDisplay];
    
    NSArray *pointArray = [myMap overlays];
    [myMap removeOverlays:pointArray];
    
    NSArray *pointAnn = [myMap annotations];
    [myMap removeAnnotations:pointAnn];
}

/******************************
 COMUNICA I DATI DELLA SESSIONE
 CON IL TTS
 ******************************/
-(void)speechThisSessionData {
    
    float temp_distance = 0.0;
    NSString *sessionToSpeech = @"";
    sessionToSpeech  = NSLocalizedString(@"SPEECH_SESSION_DATA",nil);
    
    NSString *unit = @"";
    if(distanceInKM == 0) { unit = NSLocalizedString(@"meters",nil); temp_distance = distanceInMeters; }
    else { unit = NSLocalizedString(@"Km",nil); temp_distance = distanceInKM; }
    
    sessionToSpeech = [NSString stringWithString:[NSString stringWithFormat:NSLocalizedString(@"SPEECH_DISTANCE",nil),sessionToSpeech,temp_distance, unit]];
    
    sessionToSpeech = [NSString stringWithString:[NSString stringWithFormat:NSLocalizedString(@"SPEECH_AVG_SPEED",nil),sessionToSpeech, [NSNumber numberWithFloat:iseAvgSpeed]]];
    
    sessionToSpeech = [NSString stringWithString:[NSString stringWithFormat:NSLocalizedString(@"SPEECH_RYTHM",nil),sessionToSpeech,lblRitmoMedio.text]];
    
    sessionToSpeech = [NSString stringWithString:[NSString stringWithFormat:NSLocalizedString(@"SPEECH_SPEED",nil),sessionToSpeech,lastSpeed]];
    
    [self speechText:sessionToSpeech];
}

/******************************
 SALVA I DATI DELLA SESSIONE
 NECESSITA DI UN'IMMAGINE COME PARAMETRO
 ******************************/
-(void)saveSessionWithImage:(UIImage*) image_src {
    double currDistance;
    NSMutableArray *sessionData = [NSMutableArray new];
    SessionData *sessionToSave = [[SessionData alloc] init];
    
    sessionImage = image_src;
    if(distanceInKM==0)
        currDistance = (float)iseDistance / (float)1000;
    else
        currDistance = distanceInKM;
    
    [sessionData addObject:[NSNumber numberWithInteger:iseAltitude]];
    [sessionData addObject:[NSNumber numberWithInteger:iseAvgSpeed]];
    [sessionData addObject:[NSNumber numberWithFloat:currDistance]];
    [sessionData addObject:[NSNumber numberWithInteger:iseMaxSpeed]];
    [sessionData addObject:lblRitmoMedio.text];
    [sessionData addObject:sessionImage];
    
    if(![sessionToSave saveNewSession:sessionData])
        NSLog(@"Dati non salvati");
    
}

/******************************
 RICHIAMA LE FUNZIONI PER SALVARE LA SESSIONE CORRENTE
 ******************************/
-(void)saveSession {
    imageSaveType = SAVE_FOR_FILE;
    [self prepareBackgroundImage];
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
            [self setFinalPoint];
            [locationManager stopUpdatingLocation];
            myMap.showsUserLocation = false;
            [timeTimer invalidate];
            timeTimer = nil;
            if(backgroundTask != UIBackgroundTaskInvalid)
            {
                [[UIApplication sharedApplication] endBackgroundTask:backgroundTask];
                backgroundTask = UIBackgroundTaskInvalid;
            }
            statusLabel.text = NSLocalizedString(@"Stopped",nil);
            RUNNING = false;
            viewSpeed.maxValue = 50;
            viewSpeed.percent = 0.0;
            [viewSpeed setNeedsDisplay];
            [self saveSession];
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
        if(!RUNNING)
        {
            [self resetData];
            [self speechText:NSLocalizedString(@"SPEECH_START_SESSION",nil)];
            statusLabel.text = NSLocalizedString(@"Running...",nil);
            myMap.showsUserLocation=true;
            /*oldPos = nil;
            firstPoint = nil;
            lastPoint = nil;
            distanceInMeters = 0.0;
            distanceInKM = 0.0;
            num_of_point = 0;
            iseAvgSpeed = 0;
            iseDistance = 0;
            iseMaxSpeed = 0;
            iseAltitude = 0;*/
            RUNNING=true;
            [self startLocation];
            
            timerSpeechSession =  [NSTimer scheduledTimerWithTimeInterval:TIME_TO_SPEECH_SESSION target:self selector:@selector(speechThisSessionData) userInfo:nil repeats:YES];
            
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

-(void)updateLines:(CLLocation *)newPoint {
    //Add drawing of route line
    [savedPoint addObject:newPoint];
    
    NSInteger numberOfSteps = savedPoint.count;
    
    CLLocationCoordinate2D coordinates[numberOfSteps];
    
    int i=0;
    for (CLLocation *loc in savedPoint)
    {
        CLLocationCoordinate2D l = loc.coordinate;
        coordinates[i] = l;
        i++;
    }
    
    MKPolyline *route = [MKPolyline polylineWithCoordinates:coordinates count:[savedPoint count]];
    [myMap addOverlay:route];
    
    //}
}


@end
