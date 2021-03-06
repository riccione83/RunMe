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
#define TIME_TO_SPEECH_SESSION  120
#define SAVE_FOR_FACEBOOK   1
#define SAVE_FOR_FILE       2

#define MODE_RUNNING             1
#define MODE_BIKING              2
#define MODE_WALKING             3

@import GoogleMobileAds;

#import "ViewController.h"

@interface ViewController () <UIPageViewControllerDataSource, GADBannerViewDelegate>

@property (weak, nonatomic) IBOutlet GADBannerView *bannerView;
@property (nonatomic, strong) NSArray *contentImages;
@property (nonatomic, strong) UIPageViewController *pageViewController;
@property (nonatomic, strong) UITapGestureRecognizer *singleTap;

@end

@implementation ViewController

@synthesize contentImages;
@synthesize singleTap;

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
        [self resetData];
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
    NSString *title;
    
    NSString *titleString = [currentItem valueForProperty:MPMediaItemPropertyTitle];
    if (titleString) {
        title = [NSString stringWithFormat:@"%@",titleString];
    } else {
        title = @"";
    }
    
  /*  NSString *artistString = [currentItem valueForProperty:MPMediaItemPropertyArtist];
    if (artistString) {
        artist = [NSString stringWithFormat:@"Artist: %@",artistString];
    } else {
        artist = @"";
    }
    */
    musicLabel.text = [NSString stringWithFormat:@"%@",title];
}

/**************************
 METODO RICHIAMATO QUANDO VIENE PREMUTO IL PULSANTE PLAY/PAUSE
 **************************/
- (void) handle_PlaybackStateChanged: (id) notification
{
    MPMusicPlaybackState playbackState = [musicPlayer playbackState];
    MPMediaItem *currentItem = [musicPlayer nowPlayingItem];
    UIImage *artworkImage = nil;
    MPMediaItemArtwork *artwork = [currentItem valueForProperty:MPMediaItemPropertyArtwork];
    
    if(artwork) {
        artworkImage = [artwork imageWithSize:CGSizeMake(70, 70)];
        imageArtworkUI.image = artworkImage;
    }
    else
        imageArtworkUI.image = [UIImage imageNamed:@"musicBackgroud.png"];
    
    if (playbackState == MPMusicPlaybackStatePaused) {
        //[playMusicButton setTitle:@"Play" forState:UIControlStateNormal];
        [playMusicButton setImage:[UIImage imageNamed:@"playBtn.png"] forState:UIControlStateNormal];
        
    } else if (playbackState == MPMusicPlaybackStatePlaying) {
        [playMusicButton setImage:[UIImage imageNamed:@"pauseBtn.png"] forState:UIControlStateNormal];
  
    } else if (playbackState == MPMusicPlaybackStateStopped) {
        //[playMusicButton setTitle:@"Play" forState:UIControlStateNormal];
        [playMusicButton setImage:[UIImage imageNamed:@"playBtn.png"] forState:UIControlStateNormal];
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
        //[musicPlayer play];
    }
    [mediaPicker dismissViewControllerAnimated:true completion:NULL];
   // [musicPlayer play];
 //   [self dismissViewControllerAnimated:YES completion:nil];
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
    //if(!isMusicON) {
        
        MPMediaPickerController *mediaPicker = [[MPMediaPickerController alloc] initWithMediaTypes:MPMediaTypeAny];
    
        mediaPicker.delegate = self;
        mediaPicker.allowsPickingMultipleItems = YES;
        mediaPicker.prompt = NSLocalizedString(@"SELECT_SONG_TO_PLAY", nil);
    
        [self presentViewController:mediaPicker animated:YES completion:nil];
        
        [self saveOptions];
    /*}
    else
    {
        [musicPlayer stop];
    }*/
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



-(void)adViewDidReceiveAd:(GADBannerView *)bannerView{
    if(!adIsShowed)
    {
        [UIView beginAnimations:@"animateAdBannerOff" context:NULL];
        bannerView.frame = CGRectOffset(bannerView.frame, 0, -bannerView.frame.size.height);
        myMap.frame = CGRectMake(myMap.frame.origin.x, myMap.frame.origin.y, myMap.frame.size.width, myMap.frame.size.height - bannerView.frame.size.height);
        viewTest.frame = CGRectOffset(viewTest.frame, 0, -bannerView.frame.size.height);
        [UIView commitAnimations];
        adIsShowed = YES;
    }
}

-(void) adView:(GADBannerView *)bannerView didFailToReceiveAdWithError:(GADRequestError *)error {
    if(adIsShowed) {
        [UIView beginAnimations:@"animateAdBannerOff" context:NULL];
        bannerView.frame = CGRectOffset(bannerView.frame, 0, +bannerView.frame.size.height);
        myMap.frame = CGRectMake(myMap.frame.origin.x, myMap.frame.origin.y, myMap.frame.size.width, myMap.frame.size.height + bannerView.frame.size.height);
        viewTest.frame = CGRectOffset(viewTest.frame, 0, +bannerView.frame.size.height);
        [UIView commitAnimations];
        adIsShowed = NO;
    }

}

 /**************************
  SE VI E' LA POSSIBILITA' VISUALIZZA IL BANNER PUBBLICITARIO
   **************************/

/***************************
 AVVIA LA LOCALIZZAZIONE ED EFFETTUA UNO ZOOM
 ***************************/
-(void)startLocation {

    [locationManager startUpdatingLocation];
}

/***************************
 SE VIENE SELEZIONATO DALLA UI IL CAMBIO DI UNITà DA MIGLIA A KM/H
 CAMBIA L'INTERFACCIA E SALVA I DATI NELLE OPZIONI 
 NON C'E' il salvataggio finale
 perchè già salva la changeWeight
 ***************************/
- (IBAction)changeUnits:(id)sender {
    if(isKmh)
    {
        isKmh = NO;
        [btnUnits setTitle:NSLocalizedString(@"Units mph",nil) forState:UIControlStateNormal];
        viewSpeed.indicator = @"mph";
        lblWeightUnits.text = NSLocalizedString(@"Lbs", nil);
    }
    else
    {
        isKmh = YES;
        [btnUnits setTitle:NSLocalizedString(@"Units Km/h",nil) forState:UIControlStateNormal];
        viewSpeed.indicator = @"Km/h";
        lblWeightUnits.text = NSLocalizedString(@"Kg", nil);
    }
    [viewSpeed setNeedsDisplay];
    [self changeWeight:nil];
  //  [self saveOptions];
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
    
    MKCoordinateRegion reg = MKCoordinateRegionMake(pos.coordinate, MKCoordinateSpanMake(0.002, 0.002));
    
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
    
        distanceInKM = distanceInMeters/1000;
        if(distanceInMeters<1000)
        {
            unit = @"mt";
            lblDistance.text = [NSString stringWithFormat:@"%.01f %@",distanceInMeters,unit];
            
        }
        else
        {
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
            
            
        //Visualizza le calorie bruciate
        [self getCalorieForSession];
        
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
            if(isKmh)
            {
                viewSpeed.indicator = @"Km/h";
                [btnUnits setTitle:NSLocalizedString(@"Units Km/h",nil) forState:UIControlStateNormal];
                lblWeightUnits.text = NSLocalizedString(@"Kg", nil);
            }
            else
            {
                viewSpeed.indicator = @"mph";
                [btnUnits setTitle:NSLocalizedString(@"Units mph",nil) forState:UIControlStateNormal];
                lblWeightUnits.text = NSLocalizedString(@"Lbs", nil);
            }
        }
        
        if([options count]>=3)
        {
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
               /* if([musicLabel.text length] > 0)
                    [musicSwitch setOn:YES];
                else
                    [musicSwitch setOn:NO];*/
                isMusicON = YES;
            }
            else
            {
              //  [musicSwitch setOn:NO];
                isMusicON = NO;
            }
        }
        else
        {
            [voiceSwitch setOn:YES];
            isVoiceON = YES;
            //[musicSwitch setOn:NO];
            isMusicON = NO;
        }
        
        if([options count]>=5)
        {
            SESSION_MODE = [[options objectAtIndex:3] intValue];
            userWeight   = [[options objectAtIndex:4] integerValue];
            if(SESSION_MODE == 0) SESSION_MODE = MODE_RUNNING;
            [self setSessionModeImage];
        }
        else
        {
            SESSION_MODE = MODE_RUNNING;
            userWeight = 70;
        }
        if(SESSION_MODE == 0) SESSION_MODE = MODE_RUNNING;
        [self setSessionModeImage];
        
        weightStepper.value = userWeight;
        if(!isKmh) {  //FOR NON EU MUSURATIONS
            userWeight = userWeight * 2.2046;
        }
        lblWeight.text = [NSString stringWithFormat:@"%lu",(unsigned long)userWeight];
    }
    else
    {
        [voiceSwitch setOn:YES];
        isVoiceON = YES;
        isMusicON = NO;
        userWeight = 70;
        weightStepper.value = userWeight;
        SESSION_MODE = MODE_RUNNING;
        [self setSessionModeImage];
    }
    
}


/********************
 SALVA LE OPZIONI
 **********************/
-(void)saveOptions {
        options = [NSMutableArray new];
        [options addObject:[NSNumber numberWithBool:isKmh]];
        [options addObject:[NSNumber numberWithBool:voiceSwitch.isOn]];
        [options addObject:[NSNumber numberWithBool:musicSwitch.isOn]];
        [options addObject:[NSNumber numberWithInt:SESSION_MODE]];
        [options addObject:[NSNumber numberWithInteger:[weightStepper value]]];
    
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
            if(RUNNING)
               [startAndStopButton setTitle:NSLocalizedString(@"Start", nil) forState:UIControlStateNormal];
            else
                [startAndStopButton setTitle:NSLocalizedString(@"Stop", nil) forState:UIControlStateNormal];
            UNLOCKED = YES;
            [self hideMenuPanel:nil];
            [self startByking:nil];
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
    [lblMusic setTitle:NSLocalizedString(@"Music", nil) forState:UIControlStateNormal];
    slideToStartLabel.text = NSLocalizedString(@"Slide to start", nil);
    lblTimeB.text = NSLocalizedString(@"Time", nil);
    lblDistanceB.text = NSLocalizedString(@"Distance", nil);
    lblAltitudeB.text = NSLocalizedString(@"Altitude", nil);
    lblTapHere.text = NSLocalizedString(@"Tap here for menù", nil);
    lblCalories.text = NSLocalizedString(@"Calories", nil);
    [btnSessionMode setTitle:NSLocalizedString(@"Running", nil) forState:UIControlStateNormal];
    sessionModeImage.image = [UIImage imageNamed:@"Run.png"];
    
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
    
    viewMusic.hidden = YES;
    [self initSwipeforUIView];

}

-(void)initSwipeforUIView {
    /***************
     CUSTOM GESTURE RECOGNITION
     ****************/
    UISwipeGestureRecognizer * swipeleft=[[UISwipeGestureRecognizer alloc]initWithTarget:self action:@selector(swipeleftMenuPanel:)];
    swipeleft.direction=UISwipeGestureRecognizerDirectionLeft;
    [menuView addGestureRecognizer:swipeleft];
    
    UISwipeGestureRecognizer * swiperight=[[UISwipeGestureRecognizer alloc]initWithTarget:self action:@selector(swiperightMenuPanel:)];
    swiperight.direction=UISwipeGestureRecognizerDirectionRight;
    [menuView addGestureRecognizer:swiperight];
    
    UISwipeGestureRecognizer * swipeleftMusic=[[UISwipeGestureRecognizer alloc]initWithTarget:self action:@selector(swipeleftMusicPanel:)];
    swipeleftMusic.direction=UISwipeGestureRecognizerDirectionLeft;
    [viewMusic addGestureRecognizer:swipeleftMusic];
    
    UISwipeGestureRecognizer * swiperightMusic=[[UISwipeGestureRecognizer alloc]initWithTarget:self action:@selector(swiperightMusicPanel:)];
    swiperightMusic.direction=UISwipeGestureRecognizerDirectionRight;
    [viewMusic addGestureRecognizer:swiperightMusic];
    
    canAnimate = true;
}

-(void)swipeleftMusicPanel:(UISwipeGestureRecognizer*)gestureRecognizer
{
    //Do what you want here
    NSLog(@"Swipe to left");
   [self animatePanel:viewMusic withPanel:menuView rightToLeft:YES];
    [pageController setCurrentPage:0];
}

-(void)swiperightMusicPanel:(UISwipeGestureRecognizer*)gestureRecognizer
{
    //Do what you want here
    NSLog(@"Swipe to right");
    
    [self animatePanel:viewMusic withPanel:menuView rightToLeft:NO];
    [pageController setCurrentPage:0];
}


-(void)swipeleftMenuPanel:(UISwipeGestureRecognizer*)gestureRecognizer
{
    //Do what you want here
    NSLog(@"Swipe to left");

    [self animatePanel:menuView withPanel:viewMusic rightToLeft:YES];
    [pageController setCurrentPage:1];
    
}

-(void)swiperightMenuPanel:(UISwipeGestureRecognizer*)gestureRecognizer
{
    //Do what you want here
    NSLog(@"Swipe to right");
    
    [self animatePanel:menuView withPanel:viewMusic rightToLeft:NO];
    [pageController setCurrentPage:1];
}

-(void)animatePanel:(UIView*)mainPanel withPanel:(UIView*)secondPanel rightToLeft:(BOOL)rightToLeft {
    
    float width = mainPanel.frame.size.width;
    float height = mainPanel.frame.size.height;
    
    if(canAnimate) {
    canAnimate = false;
    if(rightToLeft) {
        [secondPanel setFrame:CGRectMake(width, 0.0, width, height)];
         secondPanel.hidden = NO;
        [UIView animateWithDuration:0.3f
                          delay:0.0f
                        options:UIViewAnimationOptionCurveEaseInOut | UIViewAnimationOptionAllowUserInteraction
                     animations:^{
                         [secondPanel setFrame:mainPanel.frame];
                         [mainPanel setFrame:CGRectMake(-width, -7.0, width, height)];
                     }
                     completion:^(BOOL finished){
                         // do whatever post processing you want (such as resetting what is "current" and what is "next")
                         mainPanel.hidden = YES;
                         canAnimate = true;
                     }];
    }
    else
    {
        [secondPanel setFrame:CGRectMake(-width, 0.0, width, height)];
        secondPanel.hidden = NO;
        [UIView animateWithDuration:0.3f
                              delay:0.0f
                            options:UIViewAnimationOptionCurveEaseInOut | UIViewAnimationOptionAllowUserInteraction
                         animations:^{
                             [secondPanel setFrame:mainPanel.frame];
                             [mainPanel setFrame:CGRectMake(width, -7.0, width, height)];
                         }
                         completion:^(BOOL finished){
                             // do whatever post processing you want (such as resetting what is "current" and what is "next")
                             mainPanel.hidden = YES;
                             canAnimate = true;
                         }];

    }
}

}

#pragma mark -
#pragma mark UIPageViewControllerDataSource

- (UIViewController *) pageViewController: (UIPageViewController *) pageViewController viewControllerBeforeViewController:(UIViewController *) viewController
{
    PageItemController *itemController = (PageItemController *) viewController;
    
    if (itemController.itemIndex > 0)
    {
        return [self itemControllerForIndex: itemController.itemIndex-1];
    }
    
    return nil;
}

- (UIViewController *) pageViewController: (UIPageViewController *) pageViewController viewControllerAfterViewController:(UIViewController *) viewController
{
    
    PageItemController *itemController = (PageItemController *) viewController;
 
    NSInteger index = itemController.itemIndex;
    
    if(index == NSNotFound)
        return nil;
    
    index++;
    
    
    if (itemController.itemIndex+1 < [contentImages count])
    {
        return [self itemControllerForIndex: itemController.itemIndex+1];
    }
    else if (itemController.itemIndex+1 == [contentImages count])
    {
        pageViewController.view.userInteractionEnabled = YES;
        pageViewController.view.contentMode = UIViewContentModeScaleAspectFit;
        singleTap = [[UITapGestureRecognizer alloc]
                     initWithTarget:self
                     action:@selector(closePageViewControllerForHelp)];
        singleTap.numberOfTapsRequired=1;
        [self.pageViewController.view addGestureRecognizer:singleTap];
    }
    return nil;
}

-(void)closePageViewControllerForHelp
{
    
    NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
    
    // saving the preference that init screen has been viewed
    [prefs setInteger:1 forKey:@"initScreen"];
    // This is suggested to synch prefs, but is not needed (I didn't put it in my tut)
    [prefs synchronize];

    //[self.view removeGestureRecognizer:singleTap];
    [self.pageViewController.view removeGestureRecognizer:singleTap];
    
    
    [UIView beginAnimations:@"curldown" context:nil];
    [UIView setAnimationDelegate:self];
    [UIView setAnimationDuration:1];
    [UIView setAnimationTransition:UIViewAnimationTransitionCurlDown forView:self.view cache:YES];
    [self.pageViewController.view removeFromSuperview];
    [UIView commitAnimations];
    

}

- (PageItemController *) itemControllerForIndex: (NSUInteger) itemIndex
{
    if (itemIndex < [contentImages count])
    {
        PageItemController *pageItemController = [self.storyboard instantiateViewControllerWithIdentifier: @"ItemController"];
        pageItemController.itemIndex = itemIndex;
        pageItemController.imageName = contentImages[itemIndex];
        return pageItemController;
    }
    return nil;
}

#pragma mark -
#pragma mark Page Indicator

- (NSInteger) presentationCountForPageViewController: (UIPageViewController *) pageViewController
{
    return [contentImages count];
}

- (NSInteger) presentationIndexForPageViewController: (UIPageViewController *) pageViewController
{
    return 0;
}

- (void) createPageViewController
{
    
    NSString * language = NSLocalizedString(@"LANGUAGE", nil);
    if([language compare:@"it-IT"] == NSOrderedSame)
    {
        contentImages = @[@"0_ita.gif",
                          @"1_ita.gif",
                          @"2_ita.gif",
                          @"3_ita.gif",
                          @"4_ita.gif",
                          @"5_ita.gif",
                          @"6_ita.gif",
                          @"7_ita.gif"];
    }
    else
    {
        contentImages = @[@"0.gif",
                          @"1.gif",
                          @"2.gif",
                          @"3.gif",
                          @"4.gif",
                          @"5.gif",
                          @"6.gif",
                          @"7.gif"];

    }
    
    UIPageViewController *pageController = [self.storyboard instantiateViewControllerWithIdentifier: @"PageController"];
    pageController.dataSource = self;
    
    if([contentImages count])
    {
        NSArray *startingViewControllers = @[[self itemControllerForIndex: 0]];
        [pageController setViewControllers: startingViewControllers
                                 direction: UIPageViewControllerNavigationDirectionForward
                                  animated: NO
                                completion: nil];
    }
    
    self.pageViewController = pageController;

    [self addChildViewController: self.pageViewController];
    [self.view addSubview: self.pageViewController.view];
    [self.pageViewController didMoveToParentViewController: self];
}

- (void) setupPageControl
{
    [[UIPageControl appearance] setPageIndicatorTintColor: [UIColor grayColor]];
    [[UIPageControl appearance] setCurrentPageIndicatorTintColor: [UIColor whiteColor]];
    [[UIPageControl appearance] setBackgroundColor: [UIColor darkGrayColor]];
}


-(void)startHB
{
    NSDate *startDate;
    NSDate *endDate;
    
    double beatsPerMinute;// = averageCollector.average;
    [[HKManager sharedManager]
     storeHeartBeatsAtMinute:beatsPerMinute
     startDate:startDate endDate:endDate
     completion:^(NSError *error) {
         if(error) {
          /*   UIAlertView *av = [UIAlertView alertWithTitle:@"HealthStore"
                                                   message:error.hkManagerErrorMessage];
             [av addButtonWithTitle:@"Cancel"];
             [av addButtonWithTitle:@"Repeat" handler:^{
                 [self tapHKLogB:b];
             }];
             [av show];
           */
         } else {
            // [averageCollector removeAllDoubles];
            // [self updateLogUI];
           
             NSString *str = [NSString stringWithFormat:@"%@ B/m have been logged!", @((int)beatsPerMinute)];
             
             NSLog(str);
             
            /* NSString *message = [NSString stringWithFormat:@"%@ B/m have been logged!", @((int)beatsPerMinute)];
             UIAlertView *av = [UIAlertView alertWithTitle:@"HealthStore"
                                                   message:message];
             [av addButtonWithTitle:@"Ok"];
             [av show];
             */
         }
     }];
}


-(void) viewWillAppear:(BOOL)animated {
    [musicPlayer stop];
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    GADRequest *request = [GADRequest request];
    NSLog(@"Google Mobile Ads SDK version: %@", [GADRequest sdkVersion]);
    self.bannerView.adUnitID = @"ca-app-pub-9863377756867598/1239435462";
    self.bannerView.rootViewController = self;
    self.bannerView.delegate = self;
    request.testDevices = @[ kGADSimulatorID ];
    [self.bannerView loadRequest:request];
    
    
    NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
    
    // Check if the initScreen has been appared
    NSInteger initScreen = [prefs integerForKey:@"initScreen"];
    
    
     //uncomment this if you want check the wellcome screen
    //initScreen = 0;
    
    
    if(initScreen == 0) {
   //     [self createPageViewController];
   //     [self setupPageControl];
    }
    
    userWeight = 90;
    iHr = 0; iMin= 10; iSec = 0;
    lastSpeed = 40.0;
    [self getCalorieForBike];
    
    
    [self initLocalizationAndUI];
    [self startBackgroundAnimation];

    myMap.delegate = self;
    myMap.showsUserLocation = YES;
    
    
    CGFloat theHeight = self.view.frame.size.height;
    self.bannerView.frame = CGRectMake(0, theHeight - 50, self.view.frame.size.width, 50);
    
    [UIView beginAnimations:@"animateAdBannerOff" context:NULL];
    self.bannerView.frame = CGRectOffset(self.bannerView.frame, 0, self.bannerView.frame.size.height);
    myMap.frame = CGRectMake(myMap.frame.origin.x, myMap.frame.origin.y, myMap.frame.size.width, myMap.frame.size.height + self.bannerView.frame.size.height);
    viewTest.frame = CGRectOffset(viewTest.frame, 0, self.bannerView.frame.size.height);
    [UIView commitAnimations];
    adIsShowed = NO;
    
    
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
        if(!menuView.hidden)
            menuView.transform = trasform;
        else
            viewMusic.transform = trasform;
    }];
    hintViewHasShowed = true;
    [UIView animateWithDuration:0.5 animations:^{
        CGAffineTransform trasform = CGAffineTransformMakeScale(0, 0);
        hintView.transform = trasform;
    }];

    [pageController setHidden:false];
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
    [pageController setHidden:true];
    
    [UIView animateWithDuration:0.5 animations:^{
        CGAffineTransform trasform = CGAffineTransformMakeTranslation(0, -400);
        if(!menuView.hidden)
            menuView.transform = trasform;
        else
            viewMusic.transform = trasform;
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
    valCaloriesLabel.text = @"0";
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
    [sessionData addObject:valCaloriesLabel.text];  //Calories
    
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

-(void)setSessionModeImage {
    if(SESSION_MODE == MODE_RUNNING)
    {
        [btnSessionMode setTitle:NSLocalizedString(@"Running", nil) forState:UIControlStateNormal];
        sessionModeImage.image = [UIImage imageNamed:@"Run.png"];
    }
    else if (SESSION_MODE == MODE_BIKING)
    {
        [btnSessionMode setTitle:NSLocalizedString(@"Biking", nil) forState:UIControlStateNormal];
        sessionModeImage.image = [UIImage imageNamed:@"Bike.png"];
    }
    else if (SESSION_MODE == MODE_WALKING)
    {
        [btnSessionMode setTitle:NSLocalizedString(@"Walking", nil) forState:UIControlStateNormal];
        sessionModeImage.image = [UIImage imageNamed:@"walk.png"];
    }

}

-(IBAction)selectSessionMode:(id)sender {
    
    if(SESSION_MODE == MODE_WALKING)
    {
        SESSION_MODE = MODE_RUNNING;
        [btnSessionMode setTitle:NSLocalizedString(@"Running", nil) forState:UIControlStateNormal];
        sessionModeImage.image = [UIImage imageNamed:@"Run.png"];
    }
    else if (SESSION_MODE == MODE_RUNNING)
    {
        SESSION_MODE = MODE_BIKING;
        [btnSessionMode setTitle:NSLocalizedString(@"Biking", nil) forState:UIControlStateNormal];
        sessionModeImage.image = [UIImage imageNamed:@"Bike.png"];
    }
    else if (SESSION_MODE == MODE_BIKING)
    {
        SESSION_MODE = MODE_WALKING;
        [btnSessionMode setTitle:NSLocalizedString(@"Walking", nil) forState:UIControlStateNormal];
        sessionModeImage.image = [UIImage imageNamed:@"walk.png"];
    }
    [self saveOptions];
}

- (IBAction)changeWeight:(id)sender {
    userWeight = [weightStepper value];
    if(!isKmh) {  //FOR NON EU MUSURATIONS
        userWeight = userWeight * 2.2046;
    }
    lblWeight.text = [NSString stringWithFormat:@"%lu",(unsigned long)userWeight];
    [self saveOptions];
}


-(void) getCalorieForSession {
    float current_calories = 0.0;
    
    if(SESSION_MODE == MODE_WALKING)
    {
        current_calories = [self getCalorieForWalking];
    }
    else if (SESSION_MODE == MODE_RUNNING)
    {
        current_calories = [self getCalorieForRunning];
    }
    else if (SESSION_MODE == MODE_BIKING)
    {
        current_calories = [self getCalorieForBike];
    }
    
    valCaloriesLabel.text = [NSString stringWithFormat:@"%.0f",current_calories];
}

-(float)getCalorieForRunning {
    float KCal = 0.9 * distanceInKM * userWeight;
    return KCal;
}

-(float)getCalorieForWalking {
    float KCal = 0.45 * distanceInKM * userWeight;
    return KCal;
}

-(float)getCalorieForBike {
    float value_table = 0.0;
    float seconds = iHr * 60 * 60 + iMin * 60 + iSec;
    float minutes = (seconds / 60) / 60;
    if(lastSpeed < 16.0) {
        value_table = 4.0;
    }
    else if ((lastSpeed>=16) && (lastSpeed<19)) {
        value_table = 6.0;
    }
    else if ((lastSpeed>=19) && (lastSpeed<22)) {
        value_table = 8.0;
    }
    else if ((lastSpeed>=22) && (lastSpeed<25)) {
        value_table = 10.0;
    }
    else if ((lastSpeed>=25) && (lastSpeed<32)) {
        value_table = 12.0;
    }
    else if (lastSpeed>32) {
        value_table = 16.0;
    }
    float KCal = roundf((userWeight*value_table)*minutes);
    
    return KCal;
}

@end
