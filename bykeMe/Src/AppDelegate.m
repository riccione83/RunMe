//
//  AppDelegate.m
//  bykeMe
//
//  Created by Riccardo Rizzo on 15/05/14.
//  Copyright (c) 2014 Riccardo Rizzo. All rights reserved.
//

#import "AppDelegate.h"
#import "Appirater.h"

@import GoogleMobileAds;

@implementation AppDelegate

-(void)welcomeScreen {
    
    UIImageView *welcome = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"splashScreen.png"]];
    //welcome.image = [UIImage imageNamed:@"sky2.jpg"];
    welcome.contentMode = UIViewContentModeScaleAspectFill;
    welcome.frame = self.window.bounds;
    
    [self.window addSubview:welcome];
    [self.window bringSubviewToFront:welcome];
    
    //Animation
    [UIView beginAnimations:nil context:nil];
    [UIView setAnimationDuration:2.0];
    [UIView setAnimationTransition:UIViewAnimationTransitionNone forView:self.window cache:YES];
    [UIView setAnimationDelegate:welcome];
    [UIView setAnimationDidStopSelector:@selector(removeFromSuperview)];
    
    welcome.alpha = 0.0;
    welcome.frame = CGRectMake(-60, -60, self.window.bounds.size.width+120, self.window.bounds.size.height+120);
    
    [UIView commitAnimations];
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    // Override point for customization after application launch.
 
    [self.window makeKeyAndVisible];
    [self welcomeScreen];

 
    [GADMobileAds configureWithApplicationID:@"ca-app-pub-9863377756867598~4332502667"];
    
    [Appirater setAppId:@"880673984"];
    [Appirater setDaysUntilPrompt:7];
    [Appirater setUsesUntilPrompt:5];
    [Appirater setSignificantEventsUntilPrompt:-1];
    //[Appirater setTimeBeforeReminding:0];
    [Appirater setDebug:NO];
    [Appirater appLaunched:YES];
    
    [[HKManager sharedManager] authorizeWithCompletion:^(NSError *error) {
        
        
       /* UIAlertView *av = [UIAlertView alertWithTitle:@"HealthKit" message:error.hkManagerErrorMessage];
        [av addButtonWithTitle:@"OK"];
        [av show];
        */
    }];
    
    return YES;
}
							
- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

@end
