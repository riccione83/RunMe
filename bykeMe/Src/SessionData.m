//
//  SessionFile.m
//  RunMe!
//
//  Created by Riccardo Rizzo on 19/04/15.
//  Copyright (c) 2015 Riccardo Rizzo. All rights reserved.
//

#import "SessionData.h"
#import "FileSupport.h"

@implementation SessionData

NSString *fileName = @"RunMeSessionData.data";

@synthesize Altitudes,  Dates, Rythms, imagesSession, Distances, MaxSpeeds, AvgSpeeds;

-(id)init {
    self = [super init];
    if (self) {
        // Initialization code
    
    
    }
    return self;
}


-(void) inizializeVars {
    Dates = [NSMutableArray new];
    Date = @"";
    Distances  = [NSMutableArray new];
    Distance = 0;
    MaxSpeeds = [NSMutableArray new];
    MaxSpeed = 0;
    AvgSpeeds = [NSMutableArray new];
    AvgSpeed = 0;
    Altitudes = [NSMutableArray new];
    Altitude = 0;
    Rythms = [NSMutableArray new];
    Rythm = @"0:0";
    imagesSession = [NSMutableArray new];
    imageSession = nil;
}

-(BOOL)loadSession {
    
    FileSupport *myFile = [[FileSupport alloc] init];
    NSMutableArray *sessions = [myFile readObjectFromFile:fileName];
    
    if(sessions!=nil)
    {
        if([sessions count] == 7) {
            Dates       = [sessions objectAtIndex:0];
            Altitudes   = [sessions objectAtIndex:1];
            AvgSpeeds   = [sessions objectAtIndex:2];
            Distances   = [sessions objectAtIndex:3];
            MaxSpeeds   = [sessions objectAtIndex:4];
            Rythms      = [sessions objectAtIndex:5];
            imagesSession   = [sessions objectAtIndex:6];
            return true;
        }
    }
    return false;
}



/*******************
 Save the session
 Format:
 
 | ALTITUDE INTEGER | AVG_SPEED INTEGER | DISTANCE INTEGER | MAX_SPEED INTEGER | RYHTM STRING | IMAGE SESSION |
 
 Date is automatic calculated
 
 *******************/
-(BOOL)saveNewSession:(NSMutableArray*)data {
    
   if(Dates== nil || [Dates count] ==0 )
        [self inizializeVars];
    
    [self loadSession];
    
    if([data count] == 6) {                                             // Is a valid data - Store it.
        NSMutableArray *sessionToSave = [NSMutableArray new];
        
        NSDate *currDate = [NSDate date];
        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc]init];
        [dateFormatter setDateFormat:@"dd/MM/YY"];
        NSString *dateString = [dateFormatter stringFromDate:currDate];
        Date = dateString;
        
        Altitude = [[data objectAtIndex:0] integerValue];   //Altitude
        AvgSpeed = [[data objectAtIndex:1] integerValue];   //AvgSpeed
        Distance = [[data objectAtIndex:2] floatValue];   //Distance
        MaxSpeed = [[data objectAtIndex:3] integerValue];   //MaxSpeed
        Rythm    = [data objectAtIndex:4];                  //Rythm
        imageSession = [data objectAtIndex:5];              //imageSession
        
        [Dates addObject:Date];
        [Altitudes addObject:[NSNumber numberWithInteger:Altitude]];
        [AvgSpeeds addObject:[NSNumber numberWithInteger:AvgSpeed]];
        [Distances addObject:[NSNumber numberWithFloat: Distance]];
        [MaxSpeeds addObject:[NSNumber numberWithInteger:MaxSpeed]];
        [Rythms addObject:Rythm];
        [imagesSession addObject:imageSession];
    
        [sessionToSave addObject:Dates];
        [sessionToSave addObject:Altitudes];
        [sessionToSave addObject:AvgSpeeds];
        [sessionToSave addObject:Distances];
        [sessionToSave addObject:MaxSpeeds];
        [sessionToSave addObject:Rythms];
        [sessionToSave addObject:imagesSession];

        FileSupport *myFile = [[FileSupport alloc] init];
        [myFile writeObjectToFile:sessionToSave fileToWrite:fileName];
        return true;
    }
    return false;
}

-(BOOL)saveSessions {
    
    NSMutableArray *sessionToSave = [NSMutableArray new];
    
    [sessionToSave addObject:Dates];
    [sessionToSave addObject:Altitudes];
    [sessionToSave addObject:AvgSpeeds];
    [sessionToSave addObject:Distances];
    [sessionToSave addObject:MaxSpeeds];
    [sessionToSave addObject:Rythms];
    [sessionToSave addObject:imagesSession];
    
    FileSupport *myFile = [[FileSupport alloc] init];
    [myFile writeObjectToFile:sessionToSave fileToWrite:fileName];
    return true;
}


@end
